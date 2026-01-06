//
//  NavigoStations.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 07/02/2025.
//

import Foundation

public struct NavigoLineInfo: Codable {
    let name: String
    var mode: String
    let direction: String?
    let public_id: String
    let provider_id: Int?
    let line_id: Int?
    let background_color: String
    let text_color: String
    let is_noctilien: Bool
    
    enum CodingKeys: String, CodingKey {
        case name, mode, direction, public_id, provider_id, line_id, background_color, text_color, is_noctilien
        // omit 'found' if it's not in the JSON file
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.mode = try container.decode(String.self, forKey: .mode)
        self.direction = try container.decodeIfPresent(String.self, forKey: .direction)
        self.public_id = try container.decode(String.self, forKey: .public_id)
        self.provider_id = try container.decodeIfPresent(Int.self, forKey: .provider_id)
        self.line_id = try container.decodeIfPresent(Int.self, forKey: .line_id)
        self.background_color = try container.decode(String.self, forKey: .background_color)
        self.text_color = try container.decode(String.self, forKey: .text_color)
        self.is_noctilien = try container.decodeIfPresent(Bool.self, forKey: .is_noctilien) ?? false
    }
    
    init(name: String, mode: String, direction: String? = nil, public_id: String, provider_id: Int?, line_id: Int?, background_color: String, text_color: String, is_noctilien: Bool = false) {
        self.name = name
        self.mode = mode
        self.direction = direction
        self.public_id = public_id
        self.provider_id = provider_id
        self.line_id = line_id
        self.background_color = background_color
        self.text_color = text_color
        self.is_noctilien = is_noctilien
    }
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

    public class func find(_ provider: Int, _ line_id: Int, _ mode: String) -> NavigoLineInfo? {
        if let line = allLines.first(where: { $0.provider_id == provider && $0.line_id == line_id && $0.mode == mode }) {
            return line
        }
        return allLines.first { $0.provider_id == provider && $0.line_id == (line_id >> 8) && $0.mode == mode }
    }
}
