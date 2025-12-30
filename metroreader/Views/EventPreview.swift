//
//  EventPreview.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 07/02/2025.
//

import SwiftUI

struct EventPreview: View {
    var eventInfo: [String: Any] = [:]
    
    var body: some View {
        HStack {
            EventIcon(eventTransportMode: interpretEventCode(getKey(eventInfo, "EventCode") ?? "", isRouteNumberPresent: getKey(eventInfo, "EventRouteNumber") != nil, routeNumber: Int(getKey(eventInfo, "EventRouteNumber") ?? "", radix: 2)).0, eventTransition: interpretEventCode(getKey(eventInfo, "EventCode") ?? "").1)
            VStack(alignment: .leading) {
                if interpretLocationId(getKey(eventInfo, "EventLocationId") ?? "", getKey(eventInfo, "EventCode") ?? "", getKey(eventInfo, "EventServiceProvider") ?? "", getKey(eventInfo, "EventRouteNumber")).found {
                    Text("\(interpretLocationId(getKey(eventInfo, "EventLocationId") ?? "", getKey(eventInfo, "EventCode") ?? "", getKey(eventInfo, "EventServiceProvider") ?? "", getKey(eventInfo, "EventRouteNumber")).name)")
                        .fontWeight(.bold)
                    
                    HStack(spacing: 0) {
                        Text("\(interpretEventCode(getKey(eventInfo, "EventCode") ?? "", isRouteNumberPresent: getKey(eventInfo, "EventRouteNumber") != nil, routeNumber: Int(getKey(eventInfo, "EventRouteNumber") ?? "0", radix: 2)).0)")
                            .font(.caption)
                            .foregroundColor(Color.gray)
                        if getKey(eventInfo, "EventRouteNumber") != nil {
                            Text(" \(interpretRouteNumber(getKey(eventInfo, "EventRouteNumber") ?? "", getKey(eventInfo, "EventCode") ?? "", getKey(eventInfo, "EventServiceProvider") ?? ""))")
                                .font(.caption)
                                .foregroundColor(Color.gray)
                        }
                        if getKey(eventInfo, "EventResult") != nil {
                            Text(" - \(interpretEventResult(getKey(eventInfo, "EventResult") ?? ""))")
                                .font(.caption)
                                .foregroundColor(Color.gray)
                        }
                        else {
                            Text(" - \(interpretEventCode(getKey(eventInfo, "EventCode") ?? "").1)")
                                .font(.caption)
                                .foregroundColor(Color.gray)
                        }
                    }
                }
                else {
                    HStack(spacing: 0) {
                        Text("\(interpretEventCode(getKey(eventInfo, "EventCode") ?? "", isRouteNumberPresent: getKey(eventInfo, "EventRouteNumber") != nil).0)")
                            .fontWeight(.bold)
                        if getKey(eventInfo, "EventRouteNumber") != nil {
                            Text(" \(interpretRouteNumber(getKey(eventInfo, "EventRouteNumber") ?? "", getKey(eventInfo, "EventCode") ?? "", getKey(eventInfo, "EventServiceProvider") ?? ""))")
                                .fontWeight(.bold)
                        }
                    }
                    if getKey(eventInfo, "EventResult") != nil {
                        Text("\(interpretEventResult(getKey(eventInfo, "EventResult") ?? ""))")
                            .font(.caption)
                            .foregroundColor(Color.gray)
                    }
                    else {
                        Text("\(interpretEventCode(getKey(eventInfo, "EventCode") ?? "").1)")
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
