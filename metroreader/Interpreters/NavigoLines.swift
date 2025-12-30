//
//  NavigoStations.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 07/02/2025.
//

import Foundation

public struct NavigoLineInfo: Codable {
    let name: String
    let provider_id: Int
    let id: Int
    let mode: String
    let is_noctilien: Bool
}

public class NavigoLines {
    public static let allLines: [NavigoLineInfo] = {
        guard let url = Bundle.main.url(forResource: "NavigoLines", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }
        do {
            return try JSONDecoder().decode([NavigoLineInfo].self, from: data)
        } catch {
            print("Error loading Navigo data: \(error)")
            return []
        }
    }()

    public class func find(_ provider: Int, _ id: Int, _ mode: String) -> NavigoLineInfo? {
        if let line = allLines.first(where: { $0.provider_id == provider && $0.id == id && $0.mode == mode }) {
            return line
        }
        return allLines.first { $0.provider_id == provider && $0.id == (id >> 8) && $0.mode == mode }
    }
}
