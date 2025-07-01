//
//  EN1545Element.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 06/02/2025.
//

struct EN1545Element {
    var name: String
    var field_type: Int
    var final_type: Int?
    var counter_size: Int?
    var subfields: [EN1545Element]?
}
