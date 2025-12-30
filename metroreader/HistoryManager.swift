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

    func saveScan(cardID: Int?, env: [String: Any], contracts: [[String: Any]], events: [[String: Any]], specialEvents: [[String: Any]]) {
        let isEnabled = UserDefaults.standard.bool(forKey: isHistoryEnabledKey)
        
        guard isEnabled else {
            print("History is disabled. Scan not saved.")
            return
        }
        
        let newRecord = ScanRecord(
            id: UUID(),
            date: Date(),
            cardID: cardID,
            envData: try? JSONSerialization.data(withJSONObject: env),
            contractsData: try? JSONSerialization.data(withJSONObject: contracts),
            eventsData: try? JSONSerialization.data(withJSONObject: events),
            specialEventsData: try? JSONSerialization.data(withJSONObject: specialEvents)
        )
        
        history.insert(newRecord, at: 0) // Newest first
        persistToDisk()
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
