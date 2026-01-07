//
//  NFCReader.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 07/02/2025.
//

import Foundation
import CoreNFC

private func selectAID(_ tag: NFCISO7816Tag, _ aidData: Data) async throws -> String {
    let apdu = NFCISO7816APDU.init(instructionClass: 0x00, instructionCode: 0xA4, p1Parameter: 0x04, p2Parameter: 0x00, data: aidData, expectedResponseLength: -1)
    print("Sending APDU: \(apdu)")
    let (response, sw1, sw2) = try await tag.sendCommand(apdu: apdu)
    print("Response: \(String(format: "%02X %02X", sw1, sw2))")
    if sw1 == 0x90 && sw2 == 0x00 {
        let responseData = response.map { String(format: "%02X", $0) }.joined()
        let binaryString = responseData.compactMap { hexChar -> String? in
            guard let hexValue = Int(String(hexChar), radix: 16) else { return nil }
            return String(format: "%04d", Int(String(hexValue, radix: 2))!)
        }.joined()
        return binaryString
    } else if sw1 == 0x6A && sw2 == 0x82 {
        throw NSError(domain: "Application not found", code: 0x6A82, userInfo: nil)
    } else if sw1 == 0x6A && sw2 == 0x83 {
        throw NSError(domain: "Record not found", code: 0x6A83, userInfo: nil)
    } else {
        throw NSError(domain: "Unexpected status word", code: Int(sw1) << 8 | Int(sw2), userInfo: ["sw1": sw1, "sw2": sw2])
    }
}

private func readRecord(_ tag: NFCISO7816Tag, _ recordId: UInt8, _ sfi: UInt8) async throws -> String {
    let apdu = NFCISO7816APDU.init(data: Data([0x00, 0xB2, recordId, sfi << 3 | 4, 0x00]))!
    print("Sending APDU: \(apdu)")
    let (response, sw1, sw2) = try await tag.sendCommand(apdu: apdu)
    print("Response: \(String(format: "%02X %02X", sw1, sw2))")
    if sw1 == 0x90 && sw2 == 0x00 {
        let responseData = response.map { String(format: "%02X", $0) }.joined()
        let binaryString = responseData.compactMap { hexChar -> String? in
            guard let hexValue = Int(String(hexChar), radix: 16) else { return nil }
            return String(format: "%04d", Int(String(hexValue, radix: 2))!)
        }.joined()
        return binaryString
    } else if sw1 == 0x6A && sw2 == 0x82 {
        throw NSError(domain: "Application not found", code: 0x6A82, userInfo: nil)
    } else if sw1 == 0x6A && sw2 == 0x83 {
        throw NSError(domain: "Record not found", code: 0x6A83, userInfo: nil)
    } else {
        throw NSError(domain: "Unexpected status word", code: Int(sw1) << 8 | Int(sw2), userInfo: ["sw1": sw1, "sw2": sw2])
    }
}

private func interpretCardID(_ iccBitstring: String) -> UInt64 {
    var bytes = [UInt8]()
    let bitLength = 8
    
    for i in stride(from: 0, to: iccBitstring.count, by: bitLength) {
        let start = iccBitstring.index(iccBitstring.startIndex, offsetBy: i)
        let end = iccBitstring.index(start, offsetBy: bitLength, limitedBy: iccBitstring.endIndex) ?? iccBitstring.endIndex
        let chunk = String(iccBitstring[start..<end])
        
        if let byte = UInt8(chunk, radix: 2) {
            bytes.append(byte)
        }
    }
    
    // 2. Locate Tag C7 (0xC7)
    // Tag C7 is followed by Length 08 (0x08)
    guard let c7Index = bytes.firstIndex(of: 0xC7),
          c7Index + 1 < bytes.count,
          bytes[c7Index + 1] == 0x08 else {
        return 0
    }
    
    // 3. Define the segment offset
    // Data starts at c7Index + 2
    // We want the last 4 bytes of the 8-byte value
    let serialStart = c7Index + 2 + 4
    let serialEnd = serialStart + 4
    
    guard bytes.count >= serialEnd else { return 0 }
    
    let targetBytes = bytes[serialStart..<serialEnd]
    
    // 4. Convert 4 bytes to UInt64
    var result: UInt64 = 0
    for byte in targetBytes {
        result = (result << 8) | UInt64(byte)
    }
    
    return result
}

class NFCReader: NSObject, ObservableObject, NFCTagReaderSessionDelegate {
    
    @Published var tagID: String = "Tap 'Scan' to read NFC"
    @Published var cardID: UInt64 = 0
    @Published var tagIcc: String = ""
    @Published var tagEnvHolder: [String: Any] = [:]
    @Published var tagContracts: [[String: Any]] = []
    @Published var tagMinContractPriority: Int? = nil
    @Published var tagEvents: [[String: Any]] = []
    @Published var tagSpecialEvents: [[String: Any]] = []
    private var session: NFCTagReaderSession?
    var historyManager: HistoryManager?
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("Tag reader session became active!")
    }
    
    var exportDataAsJSON: Data? {
        if tagContracts.isEmpty && tagEvents.isEmpty && tagSpecialEvents.isEmpty && cardID == 0 {
            return nil
        }
        let dict: [String: Any] = [
            "cardID": cardID,
            "icc": tagIcc,
            "envHolder": tagEnvHolder,
            "contracts": tagContracts,
            "events": tagEvents,
            "specialEvents": tagSpecialEvents
        ]
        
        // Safety check to ensure the dictionary can actually be made into JSON
        guard JSONSerialization.isValidJSONObject(dict) else {
            print("Error: Dictionary contains types that are not JSON compatible.")
            return nil
        }
        
        return try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted])
    }
    
    func importJSON(from data: Data, historyManager: HistoryManager) {
        self.historyManager = historyManager
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    self.cardID = json["cardID"] as? UInt64 ?? 0
                    self.tagIcc = json["icc"] as? String ?? ""
                    self.tagEnvHolder = json["envHolder"] as? [String: Any] ?? [:]
                    self.tagContracts = json["contracts"] as? [[String: Any]] ?? []
                    self.tagEvents = json["events"] as? [[String: Any]] ?? []
                    self.tagSpecialEvents = json["specialEvents"] as? [[String: Any]] ?? []
                    
                    self.tagID = "Imported Card: \(self.cardID)"
                    
                    self.historyManager?.saveScan(
                        cardID: self.cardID,
                        icc: self.tagIcc,
                        env: self.tagEnvHolder,
                        contracts: self.tagContracts,
                        events: self.tagEvents,
                        specialEvents: self.tagSpecialEvents
                    )
                }
            }
        } catch {
            print("Failed to parse imported JSON: \(error)")
        }
    }
    
    func beginScanning(historyManager: HistoryManager) {
        guard NFCTagReaderSession.readingAvailable else {
            tagID = "NFC is not available on this device."
            return
        }
        
        self.historyManager = historyManager
        
        session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self, queue: DispatchQueue.main)
        session?.alertMessage = "Placez votre passe sur le haut de votre iPhone pendant quelques secondes."
        session?.begin()
        
        clearData()
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        /* DispatchQueue.main.async {
            self.tagID = "NFC Session Invalidated: \(error.localizedDescription)"
        } */
    }
    
    func clearData() {
        DispatchQueue.main.async {
            self.tagID = "Tap 'Scan' to read NFC"
            self.cardID = 0
            self.tagEnvHolder = [:]
            self.tagContracts = []
            self.tagMinContractPriority = nil
            self.tagEvents = []
            self.tagSpecialEvents = []
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        var nfcIso7816Tag: NFCISO7816Tag? = nil
        var nfcTag: NFCTag? = nil
        
        for tag in tags {
            if nfcTag == nil {
                nfcTag = tag
            }
            if case let .iso7816(cTag) = tag {
                nfcIso7816Tag = cTag
                nfcTag = tag
            }
        }
        
        if nfcIso7816Tag == nil {
            session.invalidate(errorMessage: "Card not supported: \(nfcTag.debugDescription)")
            return
        }
        
        print("Using tag \(String(describing: nfcTag!))")
        
        session.connect(to: nfcTag!) { (error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.tagID = "Connection failed: \(error.localizedDescription)"
                }
                return
            }
            
            guard let nfcIso7816Tag = nfcIso7816Tag else {
                return
            }
            
            session.alertMessage = "Lecture en cours..."
            
            DispatchQueue.main.async {
                Task {
                    do {
                        session.alertMessage = "⚪️⚪️⚪️⚪️⚪️⚪️⚪️"
                        self.tagIcc = try await selectAID(nfcIso7816Tag, Data([0xA0, 0x00, 0x00, 0x04, 0x04, 0x01, 0x25, 0x09, 0x01, 0x01]))
                        
                        let decimalValue = interpretCardID(self.tagIcc)
                        self.tagID = "Card ID: \(decimalValue)"
                        self.cardID = decimalValue
                        
                        session.alertMessage = "🔵⚪️⚪️⚪️⚪️⚪️⚪️"
                        self.tagEnvHolder = parseStructure(bitstring: try await readRecord(nfcIso7816Tag, 1, 0x07), element: IntercodeEnvHolder).0 as! [String: Any]
                        print(self.tagEnvHolder)
                        
                        // Counters
                        session.alertMessage = "🔵🔵⚪️⚪️⚪️⚪️⚪️"
                        let countersBitstring = try await readRecord(nfcIso7816Tag, 1, 0x19)
                        var countersBitstrings: [String] = []
                        for i in 0...3 {
                            countersBitstrings.append(String(countersBitstring.dropFirst(i * 24).prefix(24)))
                        }
                        
                        // Contract List
                        session.alertMessage = "🔵🔵🔵⚪️⚪️⚪️⚪️"
                        let contractListContainer = parseStructure(bitstring: try await readRecord(nfcIso7816Tag, 1, 0x1E), element: IntercodeContractList).0 as! [String: Any]
                        let contractList = contractListContainer["ContractList"] as! [[String: Any]]
                        print(contractList)
                        
                        // Contracts
                        // loop 4 times
                        session.alertMessage = "🔵🔵🔵🔵⚪️⚪️⚪️"
                        for i in 1...4 {
                            do {
                                print("Reading contract \(i)")
                                var parsedContract = parseStructure(bitstring: try await readRecord(nfcIso7816Tag, UInt8(i), 0x09), element: IntercodeContract).0 as! [String: Any]
                                if ((getBitmapCount(parsedContract, "ContractBitmap") ?? 0) > 0) {
                                    if let validityJourneysBitstring = getKey(parsedContract, "ContractValidityJourneys") {
                                        let isProprietary = validityJourneysBitstring.first == "0"
                                        if !isProprietary {
                                            let CounterStructureNumber = String(validityJourneysBitstring.dropFirst(1).prefix(5))
                                            let CounterLastLoad = String(validityJourneysBitstring.suffix(8))
                                            
                                            if let counterStructure = IntercodeCounters[Int(CounterStructureNumber, radix: 2) ?? 0] {
                                                let parsedCounter = parseStructure(bitstring: countersBitstrings[i - 1], element: counterStructure).0 as! [String: Any]
                                                
                                                let counterDict: [String: Any] = [
                                                    "CounterStructureNumber": CounterStructureNumber,
                                                    "CounterLastLoad": CounterLastLoad
                                                ].merging(parsedCounter) { (_, new) in new }
                                                
                                                parsedContract["Counter"] = counterDict
                                            }
                                        }
                                    }
                                    let BetterContract = contractList.first(where: { contract in
                                        if let pointerBitString = contract["ContractListPointer"] as? String,
                                           let pointerValue = Int(pointerBitString, radix: 2) {
                                            return pointerValue == i
                                        }
                                        return false
                                    })
                                    if let foundContract = BetterContract {
                                        parsedContract["BetterContract"] = foundContract
                                        self.tagContracts.append(parsedContract)
                                        print("Found matching BetterContract for pointer \(i): \(foundContract)")
                                    } else {
                                        print("No BetterContract matches pointer \(i)")
                                    }
                                    
                                    self.tagContracts.append(parsedContract)
                                    print(parsedContract)
                                }
                                else {
                                    print("No contract in slot \(i)")
                                }
                            } catch {
                                print("Failed to read contract in slot \(i)")
                            }
                        }
                        
                        // Events
                        // loop 3 times
                        session.alertMessage = "🔵🔵🔵🔵🔵⚪️⚪️"
                        for i in 1...3 {
                            print("Reading event \(i)")
                            let parsedEvent = parseStructure(bitstring: try await readRecord(nfcIso7816Tag, UInt8(i), 0x08), element: IntercodeEvent).0 as! [String: Any]
                            if ((getBitmapCount(parsedEvent, "EventBitmap") ?? 0) > 0) && (interpretInt(getKey(parsedEvent, "EventContractPointer") ?? "") > 0) {
                                self.tagEvents.append(parsedEvent)
                                print(parsedEvent)
                            }
                            else {
                                print("No event in slot \(i)")
                            }
                        }
                        
                        // Special Events
                        // loop 3 times
                        session.alertMessage = "🔵🔵🔵🔵🔵🔵⚪️"
                        for i in 1...3 {
                            do {
                                print("Reading special event \(i)")
                                let parsedEvent = parseStructure(bitstring: try await readRecord(nfcIso7816Tag, UInt8(i), 0x1D), element: IntercodeEvent).0 as! [String: Any]
                                if ((getBitmapCount(parsedEvent, "EventBitmap") ?? 0) > 0) {
                                    self.tagSpecialEvents.append(parsedEvent)
                                    print(parsedEvent)
                                }
                                else {
                                    print("No special event in slot \(i)")
                                }
                            } catch {
                                print("Failed to read special event in slot \(i)")
                            }
                        }
                        session.alertMessage = "🔵🔵🔵🔵🔵🔵🔵"
                        session.invalidate()
                        
                        // Save the scan to history
                        self.historyManager?.saveScan(
                            cardID: self.cardID,
                            icc: self.tagIcc,
                            env: self.tagEnvHolder,
                            contracts: self.tagContracts,
                            events: self.tagEvents,
                            specialEvents: self.tagSpecialEvents
                        )
                    } catch {
                        print("Failed with error: \(error)")
                        session.invalidate()
                    }
                }
            }
        }
    }
}
