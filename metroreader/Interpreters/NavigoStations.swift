//
//  NavigoStations.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 07/02/2025.
//

import Foundation

public struct NavigoStationInfoLines: Codable {
    let name: String
    let mode: String
    let background_color: String
    let text_color: String
}

public struct NavigoStationInfo: Codable {
    let name: String
    let provider_id: Int
    let group: Int
    let id: Int
    let sub: Int
    let mode: String
    let lat: Double
    let long: Double
    let lines: [NavigoStationInfoLines]
    let found: Bool
    
    enum CodingKeys: String, CodingKey {
        case name, provider_id, group, id, sub, mode, lat, long, lines
        // omit 'found' if it's not in the JSON file
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.provider_id = try container.decode(Int.self, forKey: .provider_id)
        self.group = try container.decode(Int.self, forKey: .group)
        self.id = try container.decode(Int.self, forKey: .id)
        self.sub = try container.decode(Int.self, forKey: .sub)
        self.mode = try container.decode(String.self, forKey: .mode)
        self.lat = try container.decode(Double.self, forKey: .lat)
        self.long = try container.decode(Double.self, forKey: .long)
        self.lines = try container.decode([NavigoStationInfoLines].self, forKey: .lines)
        
        // Default to true when decoding from JSON
        self.found = true
    }
    
    init(name: String, provider_id: Int, group: Int, id: Int, sub: Int, mode: String, lat: Double, long: Double) {
        self.name = name
        self.provider_id = provider_id
        self.group = group
        self.id = id
        self.sub = sub
        self.mode = mode
        self.lat = lat
        self.long = long
        self.lines = []
        self.found = true
    }
    
    init(name: String, provider_id: Int, group: Int, id: Int, sub: Int, mode: String, lat: Double, long: Double, found: Bool) {
        self.name = name
        self.provider_id = provider_id
        self.group = group
        self.id = id
        self.sub = sub
        self.mode = mode
        self.lat = lat
        self.long = long
        self.lines = []
        self.found = found
    }
}

public class NavigoStations {
    public static let allStations: [NavigoStationInfo] = {
        guard let url = Bundle.main.url(forResource: "NavigoStations", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }
        do {
            return try JSONDecoder().decode([NavigoStationInfo].self, from: data)
        } catch {
            print("Error loading Navigo data: \(error)")
            return []
        }
    }()
    
    public class func find(_ provider: Int, _ group: Int, _ id: Int, _ sub: Int, _ mode: String) -> NavigoStationInfo? {
        var modeToUse = mode
        if (mode == "RER") {
            modeToUse = "Train"
        }
        if (provider == 2) { // Map SNCF Provider
            return allStations.first { $0.provider_id == 1 && $0.group == group && $0.id == id && $0.sub == sub && $0.mode == modeToUse }
        }
        else if (provider == 3) { // Map RATP Provider
            return allStations.first { $0.provider_id == 59 && $0.group == group && $0.id == id && $0.sub == sub && $0.mode == modeToUse }
        }
        if let station = allStations.first(where: { $0.provider_id == provider && $0.group == group && $0.id == id && $0.sub == sub && $0.mode == modeToUse }) {
            return station
        }
        return allStations.first { $0.group == group && $0.id == id && $0.sub == sub }
    }
}
