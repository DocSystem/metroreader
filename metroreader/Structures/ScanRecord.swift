//
//  ScanRecord.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 30/12/2025.
//


import Foundation

struct ScanRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let cardID: Int?
    let envData: Data?
    let contractsData: Data?
    let eventsData: Data?
    let specialEventsData: Data? // Added for complete export

    // Computed properties to turn Data back into [String: Any]
    var envHolder: [String: Any] { decode(envData) }
    var contracts: [[String: Any]] { decodeArray(contractsData) }
    var events: [[String: Any]] { decodeArray(eventsData) }
    var specialEvents: [[String: Any]] { decodeArray(specialEventsData) }

    private func decode(_ data: Data?) -> [String: Any] {
        guard let data = data else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
    }
    
    private func decodeArray(_ data: Data?) -> [[String: Any]] {
        guard let data = data else { return [] }
        return (try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]) ?? []
    }
    
    var exportDataAsJSON: Data? {
        if contracts.isEmpty && events.isEmpty && specialEvents.isEmpty && cardID == nil {
            return nil
        }
        let dict: [String: Any] = [
            "cardID": cardID ?? 0,
            "envHolder": envHolder,
            "contracts": contracts,
            "events": events,
            "specialEvents": specialEvents
        ]
        
        // Safety check to ensure the dictionary can actually be made into JSON
        guard JSONSerialization.isValidJSONObject(dict) else {
            print("Error: Dictionary contains types that are not JSON compatible.")
            return nil
        }
        
        return try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted])
    }
}
