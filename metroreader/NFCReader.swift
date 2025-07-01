//
//  NFCReader.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 07/02/2025.
//

import Foundation
import CoreNFC

func selectAID(_ tag: NFCISO7816Tag, _ aidData: Data) async throws -> String {
    let apdu = NFCISO7816APDU.init(instructionClass: 0x00, instructionCode: 0xA4, p1Parameter: 0x04, p2Parameter: 0x00, data: aidData, expectedResponseLength: -1)
    print("Sending APDU: \(apdu)")
    let (response, sw1, sw2) = try await tag.sendCommand(apdu: apdu)
    print("Response: \(String(format: "%02X %02X", sw1, sw2))")
    if sw1 == 0x90 && sw2 == 0x00 {
        return response.map { String(format: "%02X", $0) }.joined()
    } else if sw1 == 0x6A && sw2 == 0x82 {
        throw NSError(domain: "Application not found", code: 0x6A82, userInfo: nil)
    } else {
        throw NSError(domain: "Unexpected status word", code: Int(sw1) << 8 | Int(sw2), userInfo: ["sw1": sw1, "sw2": sw2])
    }
}

func readRecord(_ tag: NFCISO7816Tag, _ recordId: UInt8, _ sfi: UInt8) async throws -> String {
    let apdu = NFCISO7816APDU.init(data: Data([0x00, 0xB2, recordId, sfi << 3 | 4, 0x00]))!
    print("Sending APDU: \(apdu)")
    let (response, sw1, sw2) = try await tag.sendCommand(apdu: apdu)
    print("Response: \(String(format: "%02X %02X", sw1, sw2))")
    let responseData = response.map { String(format: "%02X", $0) }.joined()
    let binaryString = responseData.compactMap { hexChar -> String? in
        guard let hexValue = Int(String(hexChar), radix: 16) else { return nil }
        return String(format: "%04d", Int(String(hexValue, radix: 2))!)
    }.joined()
    return binaryString
}

class NFCReader: NSObject, ObservableObject, NFCTagReaderSessionDelegate {
    
    @Published var tagID: String = "Tap 'Scan' to read NFC"
    @Published var cardID: Int? = nil
    @Published var tagEnvHolder: [String: Any] = [:]
    @Published var tagContracts: [[String: Any]] = []
    @Published var tagMinContractPriority: Int? = nil
    @Published var tagEvents: [[String: Any]] = []
    @Published var tagSpecialEvents: [[String: Any]] = []
    private var session: NFCTagReaderSession?
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("Tag reader session became active!")
    }
    
    func beginScanning() {
        guard NFCTagReaderSession.readingAvailable else {
            tagID = "NFC is not available on this device."
            return
        }
        
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
            self.cardID = nil
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
            if case let .iso7816(cTag) = tag {
                nfcIso7816Tag = cTag
                nfcTag = tag
            }
        }
        
        if nfcIso7816Tag == nil {
            session.invalidate(errorMessage: "Card not supported")
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
                        let _ = try await selectAID(nfcIso7816Tag, Data([0xA0, 0x00, 0x00, 0x04, 0x04, 0x01, 0x25, 0x09, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
                        
                        do {
                            let icc = try await readRecord(nfcIso7816Tag, 1, 0x02)
                            // now take bits 128 to 159 (32 bits) and convert it to decimal
                            if let decimalValue = Int(icc.dropFirst(128).prefix(32), radix: 2) {
                                self.tagID = "Card ID: \(decimalValue)"
                                self.cardID = decimalValue
                            }
                        } catch {
                            self.tagID = "Card ID: Non disponible"
                            self.cardID = nil
                        }
                        
                        self.tagEnvHolder = parseStructure(bitstring: try await readRecord(nfcIso7816Tag, 1, 0x07), element: IntercodeEnvHolder).0 as! [String: Any]
                        print(self.tagEnvHolder)
                        
                        // Counters
                        let countersBitstring = try await readRecord(nfcIso7816Tag, 1, 0x19)
                        var countersBitstrings: [String] = []
                        for i in 0...3 {
                            countersBitstrings.append(String(countersBitstring.dropFirst(i * 24).prefix(24)))
                        }
                        
                        // Contract List
                        let contractListContainer = parseStructure(bitstring: try await readRecord(nfcIso7816Tag, 1, 0x1E), element: IntercodeContractList).0 as! [String: Any]
                        let contractList = contractListContainer["ContractList"] as! [[String: Any]]
                        print(contractList)
                        
                        // Contracts
                        // loop 4 times
                        for i in 1...4 {
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
                                let BetterContract = contractList[i - 1]
                                parsedContract["BetterContract"] = BetterContract
                                
                                self.tagContracts.append(parsedContract)
                                print(parsedContract)
                            }
                            else {
                                print("No contract in slot \(i)")
                            }
                        }
                        
                        // Events
                        // loop 3 times
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
                        for i in 1...3 {
                            print("Reading special event \(i)")
                            let parsedEvent = parseStructure(bitstring: try await readRecord(nfcIso7816Tag, UInt8(i), 0x1D), element: IntercodeEvent).0 as! [String: Any]
                            if ((getBitmapCount(parsedEvent, "EventBitmap") ?? 0) > 0) {
                                self.tagSpecialEvents.append(parsedEvent)
                                print(parsedEvent)
                            }
                            else {
                                print("No special event in slot \(i)")
                            }
                        }
                        session.alertMessage = "Votre passe a été lu. Vous pouvez le retirer"
                        session.invalidate()
                    } catch {
                        print("Failed with error: \(error)")
                        session.invalidate()
                    }
                }
            }
        }
    }
}
