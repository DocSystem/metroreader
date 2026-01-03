//
//  EventsMapView.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 03/01/2026.
//


import SwiftUI
import MapKit


struct EventAnnotation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let eventNumber: Int
    let systemImage: String
    let eventTransition: String
}

struct EventsMapView: View {
    // Liste dynamique des stations trouvées
    let events: [[String: Any]]

    // Transformation des stations en annotations identifiables
    private var annotations: [EventAnnotation] {
        events.enumerated().compactMap { index, eventInfo in
            let eventRouteNumber = Int(getKey(eventInfo, "EventRouteNumber") ?? "", radix: 2)
            
            let eventLocation = interpretLocationId(getKey(eventInfo, "EventLocationId") ?? "", getKey(eventInfo, "EventCode") ?? "", getKey(eventInfo, "EventServiceProvider") ?? "", getKey(eventInfo, "EventRouteNumber"))
            
            if !eventLocation.found {
                return nil;
            }
            
            let eventCode = interpretEventCode(getKey(eventInfo, "EventCode") ?? "", isRouteNumberPresent: getKey(eventInfo, "EventRouteNumber") != nil, routeNumber: Int(getKey(eventInfo, "EventRouteNumber") ?? "0", radix: 2))
            var finalMode = eventCode.0
            let eventTransition = eventCode.1
            if (eventLocation.found && finalMode == "Train") {
                let stationModes = Set(eventLocation.lines.map { $0.mode })
                
                let hasRER = stationModes.contains("RER")
                let hasTrain = stationModes.contains("Transilien") || stationModes.contains("TER")
                
                if hasRER && hasTrain {
                    finalMode = "Train / RER"
                } else if hasRER {
                    finalMode = "RER"
                } else if hasTrain {
                    finalMode = "Train"
                }
            }
            
            let eventRouteData = NavigoLines.find(Int(getKey(eventInfo, "EventServiceProvider") ?? "", radix: 2) ?? 0, eventRouteNumber ?? 0, finalMode)
            
            if eventRouteData?.is_noctilien == true {
                finalMode = "Noctilien"
            }
            
            let eventTransportMode = finalMode
            
            return EventAnnotation(
                name: eventLocation.name,
                coordinate: CLLocationCoordinate2D(latitude: eventLocation.lat, longitude: eventLocation.lon),
                eventNumber: index + 1,
                systemImage: getTransitIcon(eventTransportMode, eventTransition),
                eventTransition: eventTransition
            )
        }
    }

    var body: some View {
        Map {
            ForEach(annotations) { annotation in
                Marker(coordinate: annotation.coordinate) {
                    // Affiche le numéro de l'événement (1 étant le plus récent)
                    Label(annotation.name, systemImage: annotation.systemImage)
                }
                .tint(colorForTransition(annotation.eventTransition))
            }
            
            MapPolyline(coordinates: annotations.map { $0.coordinate })
                .stroke(.blue.opacity(0.5), lineWidth: 3)
        }
        .mapStyle(.standard(emphasis: .muted))
        .frame(height: 300)
    }

    // Optionnel : change la couleur des marqueurs selon l'ancienneté
    private func colorForTransition(_ transition: String) -> Color {
        switch transition {
        case "Entrée", "Entrée (correspondance)", "Entrée (voie publique)":
            return .blue
        case "Sortie", "Sortie (correspondance)", "Sortie (voie publique)":
            return .red
        default:
            return .purple
        }
    }
}
