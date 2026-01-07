//
//  ScanRecord.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 30/12/2025.
//

import Foundation
import SwiftUI


struct ScanRecord: Identifiable, Codable {
    let id: UUID // Gardé pour la compatibilité SwiftUI
    var date: Date // Date du dernier scan
    var nickname: String? // Nom personnalisé
    var imageName: String? // Image de pass personnalisée
    let cardID: UInt64
    var iccData: String?
    var envData: Data?
    var contractsData: Data?
    var eventsData: Data?
    var specialEventsData: Data?

    var icc: String { iccData ?? "" }
    var envHolder: [String: Any] { decode(envData) }
    var contracts: [[String: Any]] { decodeArray(contractsData) }
    var events: [[String: Any]] { decodeArray(eventsData) }
    var specialEvents: [[String: Any]] { decodeArray(specialEventsData) }

    // Titre d'affichage intelligent
    var displayTitle: String {
        if let name = nickname, !name.isEmpty {
            return name
        }
        return getKey(envHolder, "HolderDataCommercialID") != nil ? "\(interpretNavigoCommercialId(getKey(envHolder, "HolderDataCommercialID") ?? ""))" : "Pass inconnu (\(cardID))"
    }
    
    var image: String {
        if let imageName = imageName, !imageName.isEmpty {
            return imageName
        }
        return interpretNavigoImage(getKey(envHolder, "HolderDataCardStatus") ?? "", getKey(envHolder, "HolderDataCommercialID") ?? "", contracts)
    }

    private func decode(_ data: Data?) -> [String: Any] {
        guard let data = data else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
    }
    
    private func decodeArray(_ data: Data?) -> [[String: Any]] {
        guard let data = data else { return [] }
        return (try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]) ?? []
    }
    
    var exportDataAsJSON: Data? {
        let dict: [String: Any] = [
            "cardID": cardID,
            "nickname": nickname ?? "",
            "imageName": imageName ?? "",
            "icc": icc,
            "envHolder": envHolder,
            "contracts": contracts,
            "events": events,
            "specialEvents": specialEvents
        ]
        return try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted])
    }
}
