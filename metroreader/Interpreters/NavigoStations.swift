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
    let line_id: Int?
    let location_id: Int
    let mode: String
    let lat: Double
    let lon: Double
    let lines: [NavigoStationInfoLines]
    let found: Bool
    
    enum CodingKeys: String, CodingKey {
        case name, provider_id, line_id, location_id, mode, lat, lon, lines
        // omit 'found' if it's not in the JSON file
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.provider_id = try container.decode(Int.self, forKey: .provider_id)
        self.line_id = try container.decodeIfPresent(Int.self, forKey: .line_id)
        self.location_id = try container.decode(Int.self, forKey: .location_id)
        self.mode = try container.decode(String.self, forKey: .mode)
        self.lat = try container.decode(Double.self, forKey: .lat)
        self.lon = try container.decode(Double.self, forKey: .lon)
        self.lines = try container.decode([NavigoStationInfoLines].self, forKey: .lines)
        
        // Default to true when decoding from JSON
        self.found = true
    }
    
    init(name: String, provider_id: Int, line_id: Int?, location_id: Int, mode: String, lat: Double, lon: Double) {
        self.name = name
        self.provider_id = provider_id
        self.line_id = line_id
        self.location_id = location_id
        self.mode = mode
        self.lat = lat
        self.lon = lon
        self.lines = []
        self.found = true
    }
    
    init(name: String, provider_id: Int, line_id: Int?, location_id: Int, mode: String, lat: Double, lon: Double, found: Bool) {
        self.name = name
        self.provider_id = provider_id
        self.line_id = line_id
        self.location_id = location_id
        self.mode = mode
        self.lat = lat
        self.lon = lon
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
    
    public class func find(_ provider_id: Int, _ line_id: Int?, _ location_id: Int, _ mode: String) -> NavigoStationInfo? {
        var modeToUse = mode
        if (mode == "RER") {
            modeToUse = "Train"
        }
        if (provider_id == 2) { // Map SNCF Provider
            if let station = allStations.first(where: { $0.provider_id == 1 && $0.line_id == line_id && $0.location_id == location_id && $0.mode == modeToUse }) {
                return station
            }
            else {
                return allStations.first(where: { $0.provider_id == 1 && $0.location_id == location_id && $0.mode == modeToUse })
            }
        }
        else if (provider_id == 3) { // Map RATP Provider
            if let station = allStations.first(where: { $0.provider_id == 59 && $0.line_id == line_id && $0.location_id == location_id && $0.mode == modeToUse }) {
                return station
            }
            else if line_id == 17, let station = allStations.first(where: { $0.provider_id == 59 && $0.line_id == 17 && $0.location_id == (location_id ^ 0x8000) && $0.mode == modeToUse }) {
                return station
            }
            else {
                return allStations.first(where: { $0.provider_id == 59 && $0.location_id == location_id && $0.mode == modeToUse })
            }
        }
        if let station = allStations.first(where: { $0.provider_id == provider_id && $0.line_id == line_id && $0.location_id == location_id && $0.mode == modeToUse }) {
            return station
        }
        else if let station = allStations.first(where: { $0.provider_id == provider_id && $0.location_id == location_id && $0.mode == modeToUse }) {
            return station
        }
        // If no provider matches this location, we try without checking the provider
        return allStations.first(where: { $0.location_id == location_id && $0.mode == modeToUse })
    }
}
