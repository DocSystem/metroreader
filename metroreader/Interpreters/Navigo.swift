//
//  Navigo.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 07/02/2025.
//

func interpretNavigoPersonalizationStatusCode(_ bitstring: String) -> String {
    let (perso, integral, imaginer) = interpretPersonalizationStatusCode(bitstring)
    
    switch perso {
    case "Anonymous":
        return "Navigo Easy"
    case "Declarative":
        return "Navigo Découverte"
    case "Nominative":
        if integral {
            if imaginer {
                return "Navigo Imagine R"
            }
            return "Navigo Annuel"
        }
        return "Navigo"
    default:
        return "Navigo Unknown"
    }
}

func interpretNavigoCommercialId(_ bitstring: String) -> String {
    switch Int(bitstring, radix: 2) ?? 0 {
    case 0:
        return "Unknown"
    case 5:
        return "Navigo Imagine R"
    case 16:
        return "Navigo Easy Carte"
    case 17:
        return "Navigo Easy SOCS"
    default:
        return "Unknown (\(Int(bitstring, radix: 2) ?? 0))"
    }
}

func interpretTariff(_ bitstring: String) -> String {
    switch Int(bitstring, radix: 2) ?? 0 {
    case 0x0000:
        return "Navigo Mois"
    case 0x0001:
        return "Navigo Semaine"
    case 0x0002:
        return "Navigo Annuel"
    case 0x0003:
        return "Navigo Jour"
    case 0x0004:
        return "Imagine R Scolaire"
    case 0x0005:
        return "Imagine R Étudiant"
    case 0x000D:
        return "Navigo Jeunes Week-end"
    case 0x0015:
        return "Paris - Visite"
    case 0x1000:
        return "Navigo Liberté+"
    case 0x4000:
        return "Navigo Mois 75%"
    case 0x4001:
        return "Navigo Semaine 75%"
    case 0x4015:
        return "Paris - Visite (Enfant)"
    case 0x5000:
        return "Ticket T+"
    case 0x5004:
        return "Ticket OrlyBus"
    case 0x5005:
        return "Ticket RoissyBus"
    case 0x5006:
        return "Bus-Tram"
    case 0x5008:
        return "Métro-Train-RER"
    case 0x500b:
        return "Paris <> Aéroports"
    case 0x5010:
        return "Ticket T+ (Réduit)"
    case 0x5016:
        return "Bus-Tram (Réduit)"
    case 0x5018:
        return "Métro-Train-RER (Réduit)"
    case 0x501b:
        return "Paris <> Aéroports (Réduit)"
    case 0x8003:
        return "Navigo Solidarité Gratuit"
    default:
        return "Unknown (\(Int(bitstring, radix: 2) ?? 0))"
    }
}

func interpretZones(_ bitstring: String) -> String {
    /**
     Interprets the zone information from a binary string.
     - Parameter bitstring: The binary string representing zones.
     - Returns: A string describing the interpreted zones.
     */
    
    var zones: [Int] = []
    
    // Iterate through the binary string from right to left
    for (i, char) in bitstring.reversed().enumerated() {
        if char == "1" {
            zones.append(i + 1)
        }
    }
    
    guard let minZone = zones.min(), let maxZone = zones.max() else {
        return "No zones"
    }
    
    if minZone == maxZone {
        return "Zone \(minZone)"
    }
    
    if minZone == 1 && maxZone == 5 {
        return "Toutes zones (1-5)"
    }
    
    return "Zones \(minZone)-\(maxZone)"
}

func interpretZonesShort(_ bitstring: String) -> String {
    /**
     Interprets the zone information from a binary string.
     - Parameter bitstring: The binary string representing zones.
     - Returns: A string describing the interpreted zones.
     */
    
    var zones: [Int] = []
    
    // Iterate through the binary string from right to left
    for (i, char) in bitstring.reversed().enumerated() {
        if char == "1" {
            zones.append(i + 1)
        }
    }
    
    guard let minZone = zones.min(), let maxZone = zones.max() else {
        return "-"
    }
    
    if minZone == maxZone {
        return "\(minZone)"
    }
    
    return "\(minZone)-\(maxZone)"
}

func interpretRouteNumber(_ routeNumberBitstring: String, _ eventCodeBitstring: String, _ eventServiceProviderBitstring: String) -> String {
    let routeNumber = Int(routeNumberBitstring, radix: 2)!
    
    let eventTransport = interpretEventCode(eventCodeBitstring, isRouteNumberPresent: true, routeNumber: routeNumber).0
    
    let serviceProviderCode = Int(eventServiceProviderBitstring, radix: 2)!
    
    if (eventTransport == "RER") {
        if (routeNumber == 16) || (routeNumber == 17) {
            return "A"
        }
        else if routeNumber == 18 {
            return "B"
        }
    }
    if (eventTransport == "Métro") {
        switch routeNumber {
        case 103:
            return "3 bis"
        case 107:
            return "7 bis"
        case 920:
            return "10"
        case 924:
            return "6"
        default:
            return "\(routeNumber)"
        }
    }
    else if (eventTransport == "Tramway") {
        switch routeNumber {
        case 11:
            return "T1"
        case 12:
            return "T2"
        case 13:
            return "T3a"
        case 3:
            return "T3b"
        case 2:
            return "T4"
        case 15:
            return "T5"
        case 16:
            return "T6"
        case 17:
            return "T7"
        case 18:
            return "T8"
        case 9:
            return "T9"
        case 10:
            return "T10"
        case 43:
            return "T13"
        default:
            return "\(routeNumber)"
        }
    }
    else if (eventTransport == "Bus urbain") {
        if (routeNumber == 101 && serviceProviderCode == 221) {
            return "C1"
        }
    }
    
    return "\(routeNumber)"
}

func interpretServiceProvider(_ bitstring: String) -> String {
    switch Int(bitstring, radix: 2) ?? 0 {
    case 2:
        return "SNCF";
    case 3:
        return "RATP";
    case 4, 10:
        return "IDF Mobilites";
    case 7:
        return "RATP Cap Bièvre";
    case 8:
        return "ORA";
    case 14:
        return "LUG - Paris";
    case 17:
        return "Stretto";
    case 109:
        return "Keolis Ouest Val-de-Marne T9";
    case 115:
        return "CSO (VEOLIA)";
    case 116:
        return "R'Bus (VEOLIA)";
    case 156:
        return "Phebus";
    case 175:
        return "RATP (Veolia Transport Nanterre)";
    case 221:
        return "Transdev Coteaux de la Marne";
    default:
        return "Unknown (\(Int(bitstring, radix: 2) ?? 0))"
    }
}

func interpretLocationId(_ locationIdBitString: String, _ eventCodeBitstring: String, _ eventProviderBitstring: String) -> NavigoStationInfo {
    guard let value = Int(locationIdBitString, radix: 2) else {
        return NavigoStationInfo.init(name: "Unknown (\(locationIdBitString))", provider_id: 0, provider_name: "", group: 0, id: 0, sub: 0, mode: "Unknown", lat: 0, long: 0, found: false)
    }
    
    let eventTransport = interpretEventCode(eventCodeBitstring).0
    
    let eventProviderId = Int(eventProviderBitstring, radix: 2) ?? 0
    
    let locationGroup = value >> 9
    let locationId = (value >> 4) & 31
    let locationSub = value & 15

    guard let station = NavigoStations.find(eventProviderId, locationGroup, locationId, locationSub, eventTransport) else {
        return NavigoStationInfo.init(name: "\(locationGroup)-\(locationId)-\(locationSub)", provider_id: eventProviderId, provider_name: "", group: locationGroup, id: locationId, sub: locationSub, mode: eventTransport, lat: 0, long: 0, found: false)
    }
    return station
}

func getTransitIcon(_ eventCodeBitstring: String) -> String {
    let (eventTransportMode, eventTransition) = interpretEventCode(eventCodeBitstring)
    switch (eventTransportMode) {
    case "Bus urbain":
        return "bus.fill"
    case "Bus interurbain":
        return "bus.doubledecker.fill"
    case "Train":
        if eventTransition.contains("Entrée") {
            return "train.side.front.car"
        }
        else if eventTransition.contains("Sortie") {
            return "train.side.rear.car"
        } else {
            return "train.side.middle.car"
        }
    case "Tramway":
        return "lightrail.fill"
    case "Métro":
        return "tram.fill.tunnel"
    case "Câble":
        return "cablecar.fill"
    default:
        return "questionmark.circle.fill"
    }
}
