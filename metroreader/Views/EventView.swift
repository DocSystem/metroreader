//
//  EventView.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 07/02/2025.
//

import SwiftUI
import MapKit

struct EventView: View {
    var eventInfo: [String: Any] = [:]
    var contractsInfos: [[String: Any]] = []
    
    let eventLocation: NavigoStationInfo
    let eventRouteNumber: Int?
    let eventRouteName: String?
    let eventTransportMode: String
    let eventTransition: String
    let eventRouteData: NavigoLineInfo?
    
    @State private var region: MKCoordinateRegion
    @State private var cityName: String = "Loading..."
    @State private var location: NavigoStationInfo = NavigoStationInfo(name: "Loading", provider_id: 0, line_id: nil, location_id: 0, mode: "", lat: 0.0, lon: 0.0, found: false)
        
    init(eventInfo: [String: Any] = [:], contractsInfos: [[String: Any]] = []) {
        self.eventInfo = eventInfo
        self.contractsInfos = contractsInfos
        
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
        
        _location = State(initialValue: self.eventLocation)
        
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: self.eventLocation.lat, longitude: self.eventLocation.lon),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    private var colorForTransition: Color {
        if self.eventTransition.starts(with: "Entrée") {
            return Color.blue
        } else if self.eventTransition.starts(with: "Sortie") {
            return Color.red
        }
        return Color.purple
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .center, spacing: 8) {
                    if location.found {
                        Text("\(self.eventLocation.name)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        LineIcons(lines: self.eventLocation.lines)
                        
                        HStack(spacing: 0) {
                            Text("\(self.eventTransportMode)")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.gray)
                            if let routeName = self.eventRouteName {
                                Text(" \(routeName)")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            Text(" - \(self.eventTransition)")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    } else {
                        HStack(spacing: 0) {
                            Text("\(self.eventTransportMode)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            if let routeName = self.eventRouteName {
                                Text(" \(routeName)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Text("\(self.eventTransition)")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    
                    
                    if let eventResult = getKey(eventInfo, "EventResult") {
                        Text("\(interpretEventResult(eventResult))")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                    Text("\(interpretDate(getKey(eventInfo, "EventDateStamp") ?? "")) \(interpretTime(getKey(eventInfo, "EventTimeStamp") ?? ""))")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.white.opacity(0.0))
            }
            
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    if interpretInt(getKey(eventInfo, "EventContractPointer") ?? "") <= contractsInfos.count && interpretInt(getKey(eventInfo, "EventContractPointer") ?? "") > 0 {
                        Text("Payé avec \(interpretTariff(getKey(contractsInfos[interpretInt(getKey(eventInfo, "EventContractPointer") ?? "") - 1], "ContractTariff") ?? "", getKey(contractsInfos[interpretInt(getKey(eventInfo, "EventContractPointer") ?? "") - 1], "ContractValidityEndDate") ?? ""))")
                            .fontWeight(.semibold)
                    }
                    else {
                        Text("Payé avec Navigo")
                            .fontWeight(.semibold)
                    }
                }
            }
            
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Transporteur")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(interpretServiceProvider(getKey(eventInfo, "EventServiceProvider") ?? ""))
                            .fontWeight(.semibold)
                    }
                    
                    if let eventLocationGate = getKey(eventInfo, "EventLocationGate") {
                        Divider()
                        
                        HStack {
                            Text("Porte")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(interpretInt(eventLocationGate))")
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Valideur")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(interpretInt(getKey(eventInfo, "EventDevice") ?? ""))")
                            .fontWeight(.semibold)
                    }
                    
                    if let eventVehicleId = getKey(eventInfo, "EventVehicleId") {
                        Divider()
                        
                        HStack {
                            Text("Véhicule")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(interpretInt(eventVehicleId))")
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            
            if location.found {
                Section {
                    Map(initialPosition: .region(region)) {
                        Marker(self.eventLocation.name, systemImage: getTransitIcon(self.eventTransportMode, self.eventTransition), coordinate: region.center)
                            .tint(self.colorForTransition)
                    }
                    .frame(height: 200)
                    Text(cityName)
                        .padding()
                        .onAppear {
                            fetchCityName(for: region.center)
                        }
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
            else {
                Section {
                    HStack {
                        Text("Emplacement")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(location.name)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
    
    // Reverse Geocoding to get City Name
    func fetchCityName(for location: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let city = placemarks?.first?.locality {
                if let region = placemarks?.first?.administrativeArea {
                    self.cityName = "\(city), \(region)"
                }
            } else {
                self.cityName = "Unknown Location"
            }
        }
    }
}

#Preview {
    EventView()
}
