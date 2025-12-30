//
//  EventPreview.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 07/02/2025.
//

import SwiftUI

struct EventPreview: View {
    var eventInfo: [String: Any]
    
    let eventLocation: NavigoStationInfo
    let eventRouteNumber: Int?
    let eventRouteName: String?
    let eventTransportMode: String
    let eventTransition: String
    let eventRouteData: NavigoLineInfo?
    
    init(eventInfo: [String : Any] = [:]) {
        self.eventInfo = eventInfo
        
        self.eventRouteNumber = Int(getKey(eventInfo, "EventRouteNumber") ?? "", radix: 2)
        var finalRouteName: String? = nil
        if self.eventRouteNumber != nil {
            finalRouteName = interpretRouteNumber(getKey(eventInfo, "EventRouteNumber") ?? "", getKey(eventInfo, "EventCode") ?? "", getKey(eventInfo, "EventServiceProvider") ?? "")
        }
        
        self.eventLocation = interpretLocationId(getKey(eventInfo, "EventLocationId") ?? "", getKey(eventInfo, "EventCode") ?? "", getKey(eventInfo, "EventServiceProvider") ?? "", getKey(eventInfo, "EventRouteNumber"))
        
        let eventCode = interpretEventCode(getKey(eventInfo, "EventCode") ?? "", isRouteNumberPresent: getKey(eventInfo, "EventRouteNumber") != nil, routeNumber: Int(getKey(eventInfo, "EventRouteNumber") ?? "0", radix: 2))
        var finalMode = eventCode.0
        self.eventTransition = eventCode.1
        if (self.eventLocation.found && finalMode == "Train") {
            let stationModes = Set(self.eventLocation.lines.map { $0.mode })
            
            let hasRER = stationModes.contains("RER")
            let hasTrain = stationModes.contains("Transilien") || stationModes.contains("TER")
            
            if hasRER && hasTrain {
                finalMode = "Train / RER"
            } else if hasRER {
                finalMode = "RER"
            } else if hasTrain {
                finalMode = "Train"
            }
            
            if self.eventLocation.lines.count == 1 {
                finalRouteName = self.eventLocation.lines.first!.name
            }
        }
        
        self.eventRouteData = NavigoLines.find(Int(getKey(eventInfo, "EventServiceProvider") ?? "", radix: 2) ?? 0, self.eventRouteNumber ?? 0, finalMode)
        
        if self.eventRouteData?.is_noctilien == true {
            finalMode = "Noctilien"
        }
        
        self.eventTransportMode = finalMode
        self.eventRouteName = finalRouteName
    }
    
    var body: some View {
        HStack {
            EventIcon(eventTransportMode: self.eventTransportMode, eventTransition: self.eventTransition)
            VStack(alignment: .leading) {
                if self.eventLocation.found {
                    Text("\(self.eventLocation.name)")
                        .fontWeight(.bold)
                    
                    HStack(spacing: 0) {
                        Text("\(self.eventTransportMode)")
                            .font(.caption)
                            .foregroundColor(Color.gray)
                        if let routeName = self.eventRouteName {
                            Text(" \(routeName)")
                                .font(.caption)
                                .foregroundColor(Color.gray)
                        }
                        if getKey(eventInfo, "EventResult") != nil {
                            Text(" - \(interpretEventResult(getKey(eventInfo, "EventResult") ?? ""))")
                                .font(.caption)
                                .foregroundColor(Color.gray)
                        }
                        else {
                            Text(" - \(self.eventTransition)")
                                .font(.caption)
                                .foregroundColor(Color.gray)
                        }
                    }
                }
                else {
                    HStack(spacing: 0) {
                        Text("\(self.eventTransportMode)")
                            .fontWeight(.bold)
                        if let routeName = self.eventRouteName {
                            Text(" \(routeName)")
                                .fontWeight(.bold)
                        }
                    }
                    if getKey(eventInfo, "EventResult") != nil {
                        Text("\(interpretEventResult(getKey(eventInfo, "EventResult") ?? ""))")
                            .font(.caption)
                            .foregroundColor(Color.gray)
                    }
                    else {
                        Text("\(self.eventTransition)")
                            .font(.caption)
                            .foregroundColor(Color.gray)
                    }
                }
                Text("\(interpretDate(getKey(eventInfo, "EventDateStamp") ?? "")) - \(interpretTime(getKey(eventInfo, "EventTimeStamp") ?? ""))")
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
            
            Spacer()
        }
        
    }
}

#Preview {
    EventPreview()
}
