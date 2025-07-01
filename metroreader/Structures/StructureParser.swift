//
//  StructureParser.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 06/02/2025.
//

import Foundation

func getAvailableBits(bitmap: String) -> [Bool] {
    // Ensure the bitmap string is a valid binary string
    guard !bitmap.isEmpty, bitmap.allSatisfy({ $0 == "0" || $0 == "1" }) else {
        return [] // Return an empty array if the bitmap is invalid
    }

    // Convert the bitmap string to an array of booleans
    return bitmap.reversed().map { $0 == "1" }
}

func parseStructure(bitstring: String, element: EN1545Element) -> (Any, Int) {
    var keys: [String: Any] = [:]
    var offset: Int = 0
    
    if (element.field_type == FieldType.Container) {
        // loop all sub_fields
        for subfield in element.subfields! {
            if subfield.field_type == FieldType.Final {
                keys[subfield.name] = String(bitstring.dropFirst(offset).prefix(subfield.final_type!))
                // print("\(element.name) -> \(subfield.name) = \(keys[subfield.name]!)")
                offset += subfield.final_type!
            }
            
            else if (subfield.field_type == FieldType.Bitmap) || (subfield.field_type == FieldType.Container) || (subfield.field_type == FieldType.Counter) {
                // print("\(element.name) -> \(subfield.name)")
                let (new_keys, new_offset) = parseStructure(bitstring: String(bitstring.dropFirst(offset)), element: subfield)
                keys[subfield.name] = new_keys
                offset += new_offset
            }
        }
    }
    
    else if (element.field_type == FieldType.Bitmap) {
        let availableBits: [Bool] = getAvailableBits(bitmap: String(bitstring.prefix(element.subfields!.count)))
        offset += element.subfields!.count
        for (index, subfield) in element.subfields!.enumerated() {
            if availableBits[index] {
                if subfield.field_type == FieldType.Final {
                    keys[subfield.name] = String(bitstring.dropFirst(offset).prefix(subfield.final_type!))
                    // print("\(element.name) -> \(subfield.name) = \(keys[subfield.name]!)")
                    offset += subfield.final_type!
                }
                
                else if (subfield.field_type == FieldType.Bitmap) || (subfield.field_type == FieldType.Container) || (subfield.field_type == FieldType.Counter) {
                    // print("\(element.name) -> \(subfield.name)")
                    let (new_keys, new_offset) = parseStructure(bitstring: String(bitstring.dropFirst(offset)), element: subfield)
                    keys[subfield.name] = new_keys
                    offset += new_offset
                }
            }
        }
    }
    
    else if (element.field_type == FieldType.Counter) {
        let totalCount = Int(bitstring.prefix(element.counter_size!), radix: 2) ?? 0
        offset += element.counter_size!
        var childs: [[String: Any]] = []
        for _ in 0..<totalCount {
            for subfield in element.subfields! {
                var childKeys: [String: Any] = [:]
                if subfield.field_type == FieldType.Final {
                    childKeys[subfield.name] = String(bitstring.dropFirst(offset).prefix(subfield.final_type!))
                    // print("\(element.name) -> \(subfield.name) = \(keys[subfield.name]!)")
                    offset += subfield.final_type!
                }
                
                else if (subfield.field_type == FieldType.Bitmap) || (subfield.field_type == FieldType.Container) || (subfield.field_type == FieldType.Counter) {
                    // print("\(element.name) -> \(subfield.name)")
                    let (new_keys, new_offset) = parseStructure(bitstring: String(bitstring.dropFirst(offset)), element: subfield)
                    childKeys[subfield.name] = new_keys
                    offset += new_offset
                }
                
                childs.append(childKeys)
            }
        }
        
        return (childs, offset)
    }
    
    return (keys, offset)
}

func getKey(_ dict: [String: Any], _ key: String) -> String? {
    // Check if the key exists and its value is a String
    if let value = dict[key] as? String {
        return value
    }
    
    // Recursively search in nested dictionaries
    for (_, value) in dict {
        if let nestedDict = value as? [String: Any] {
            if let result = getKey(nestedDict, key) {
                return result
            }
        }
    }
    
    // Return nil if the key is not found or is not a String
    return nil
}

func getBitmapCount(_ dict: [String: Any], _ key: String) -> Int? {
    if let value = dict[key] as? [String: Any] {
        return value.count
    }
    
    for (_, value) in dict {
        if let nestedDict = value as? [String: Any] {
            if let result = getBitmapCount(nestedDict, key) {
                return result
            }
        }
    }
    
    return nil
}
