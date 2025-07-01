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
    
    @State private var region: MKCoordinateRegion
    @State private var cityName: String = "Loading..."
    @State private var location: NavigoStationInfo = NavigoStationInfo(name: "Loading", group: 0, id: 0, sub: 0, mode: "", lat: 0.0, long: 0.0, found: false)
        
    init(eventInfo: [String: Any] = [:], contractsInfos: [[String: Any]] = []) {
        self.eventInfo = eventInfo
        self.contractsInfos = contractsInfos
        
        let eventLocationId = getKey(eventInfo, "EventLocationId") ?? ""
        let eventCode = getKey(eventInfo, "EventCode") ?? ""
        let location = interpretLocationId(eventLocationId, eventCode)
        
        _location = State(initialValue: location)
        
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: location.lat, longitude: location.long),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .center, spacing: 8) {
                    if location.found {
                        Text("\(interpretLocationId(getKey(eventInfo, "EventLocationId") ?? "", getKey(eventInfo, "EventCode") ?? "").name)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        HStack(spacing: 0) {
                            Text("\(interpretEventCode(getKey(eventInfo, "EventCode") ?? "", isRouteNumberPresent: getKey(eventInfo, "EventRouteNumber") != nil).0)")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.gray)
                            if let eventRouteNumber = getKey(eventInfo, "EventRouteNumber") {
                                Text(" \(interpretRouteNumber(eventRouteNumber, getKey(eventInfo, "EventCode") ?? "", getKey(eventInfo, "EventServiceProvider") ?? ""))")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            Text(" - \(interpretEventCode(getKey(eventInfo, "EventCode") ?? "").1)")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    } else {
                        HStack(spacing: 0) {
                            Text("\(interpretEventCode(getKey(eventInfo, "EventCode") ?? "", isRouteNumberPresent: getKey(eventInfo, "EventRouteNumber") != nil).0)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            if let eventRouteNumber = getKey(eventInfo, "EventRouteNumber") {
                                Text(" \(interpretRouteNumber(eventRouteNumber, getKey(eventInfo, "EventCode") ?? "", getKey(eventInfo, "EventServiceProvider") ?? ""))")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Text("\(interpretEventCode(getKey(eventInfo, "EventCode") ?? "").1)")
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
                        Text("Payé avec \(interpretTariff(getKey(contractsInfos[interpretInt(getKey(eventInfo, "EventContractPointer") ?? "") - 1], "ContractTariff") ?? ""))")
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
                        Marker(interpretLocationId(getKey(eventInfo, "EventLocationId") ?? "", getKey(eventInfo, "EventCode") ?? "").name, systemImage: getTransitIcon(getKey(eventInfo, "EventCode") ?? ""), coordinate: region.center)
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
