//
//  HistoryManager.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 30/12/2025.
//

import Foundation


class HistoryManager: ObservableObject {
    @Published var history: [ScanRecord] = []
    private let isHistoryEnabledKey = "isHistoryEnabled"
    private let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("history.json")

    init() {
        loadHistory()
    }

    func saveScan(cardID: UInt64, icc: String, env: [String: Any], contracts: [[String: Any]], events: [[String: Any]], specialEvents: [[String: Any]]) {
        guard UserDefaults.standard.bool(forKey: isHistoryEnabledKey) else { return }
        
        // 1. Vérifier si la carte existe déjà (si cardID est présent)
        if let index = history.firstIndex(where: { $0.cardID == cardID }) {
            
            // --- LOGIQUE DE FUSION ---
            var existingRecord = history[index]
            
            // Mise à jour des infos de base
            existingRecord.date = Date()
            existingRecord.iccData = icc
            existingRecord.envData = try? JSONSerialization.data(withJSONObject: env)
            
            // Fusion des événements (éviter les doublons)
            let oldEvents = existingRecord.events
            let newUniqueEvents = events.filter { newEv in
                !oldEvents.contains(where: {
                    getKey($0, "EventDateStamp") == getKey(newEv, "EventDateStamp") &&
                    getKey($0, "EventTimeStamp") == getKey(newEv, "EventTimeStamp") &&
                    getKey($0, "EventCode") == getKey(newEv, "EventCode")
                })
            }
            existingRecord.eventsData = try? JSONSerialization.data(withJSONObject: newUniqueEvents + oldEvents)
            
            let oldSpecialEvents = existingRecord.specialEvents
            let newUniqueSpecialEvents = specialEvents.filter { newSE in
                !oldSpecialEvents.contains(where: {
                    getKey($0, "EventDateStamp") == getKey(newSE, "EventDateStamp") &&
                    getKey($0, "EventTimeStamp") == getKey(newSE, "EventTimeStamp") &&
                    getKey($0, "EventCode") == getKey(newSE, "EventCode")
                })
            }
            existingRecord.specialEventsData = try? JSONSerialization.data(withJSONObject: newUniqueSpecialEvents + oldSpecialEvents)
            
            let oldContracts = existingRecord.contracts
            let newUniqueContracts = contracts.filter { newC in
                !oldContracts.contains(where: {
                    getKey($0, "ContractSerialNumber") == getKey(newC, "ContractSerialNumber") &&
                    getKey($0, "ContractTariff") == getKey(newC, "ContractTariff") &&
                    getKey($0, "ContractValiditySaleDate") == getKey(newC, "ContractValiditySaleDate") &&
                    getKey($0, "ContractProvider") == getKey(newC, "ContractProvider")
                })
            }
            existingRecord.contractsData = try? JSONSerialization.data(withJSONObject: newUniqueContracts + oldContracts)
            
            // Remplacer l'ancien record et le remonter en haut de liste
            history.remove(at: index)
            history.insert(existingRecord, at: 0)
            
        } else {
            // --- NOUVEAU RECORD ---
            let newRecord = ScanRecord(
                id: UUID(),
                date: Date(),
                nickname: nil,
                imageName: nil,
                cardID: cardID,
                iccData: icc,
                envData: try? JSONSerialization.data(withJSONObject: env),
                contractsData: try? JSONSerialization.data(withJSONObject: contracts),
                eventsData: try? JSONSerialization.data(withJSONObject: events),
                specialEventsData: try? JSONSerialization.data(withJSONObject: specialEvents)
            )
            history.insert(newRecord, at: 0)
        }
        
        persistToDisk()
    }

    func setNickname(for cardID: UInt64, to name: String) {
        if let index = history.firstIndex(where: { $0.cardID == cardID }) {
            history[index].nickname = name.trimmingCharacters(in: .whitespacesAndNewlines)
            print("Set nickname for cardID \(cardID) to \(name)")
            persistToDisk()
        }
    }
    
    func setImageName(for cardID: UInt64, to imageName: String) {
        if let index = history.firstIndex(where: { $0.cardID == cardID }) {
            history[index].imageName = imageName
            persistToDisk()
        }
    }
    
    private func persistToDisk() {
        if let data = try? JSONEncoder().encode(history) {
            try? data.write(to: fileURL)
        }
    }

    private func loadHistory() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([ScanRecord].self, from: data) {
            self.history = decoded
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        persistToDisk()
    }

    func clearAll() {
        self.history = []
        
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
                print("History file deleted successfully.")
            }
        } catch {
            print("Error deleting history file: \(error.localizedDescription)")
        }
    }
}
