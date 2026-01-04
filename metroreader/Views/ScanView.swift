//
//  ScanView.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 30/12/2025.
//

import SwiftUI

struct ScanView: View {
    let cardID: UInt64
    let tagEnvHolder: [String: Any]
    let tagContracts: [[String: Any]]
    let tagEvents: [[String: Any]]
    let tagSpecialEvents: [[String: Any]]
    var exportDataAsJSON: Data?
    
    @ObservedObject var historyManager: HistoryManager
    
    @State private var showAllContracts = false
    @State private var showAllEvents = false
    @State private var showingRenameAlert = false
    @State private var newNickname = ""
    @State private var showingImagePicker = false
    
    private var displayedContractsIndices: [Int] {
        let allIndices = Array(0..<tagContracts.count)
        
        // Si l'utilisateur a cliqué sur "Voir tout", on donne tout
        if showAllContracts {
            return allIndices
        }
        
        // On cherche l'index du contrat préféré
        let preferredIndex = allIndices.first { i in
            isContractBest(tagContracts[i], tagContracts)
        }
        
        // Si on trouve un préféré, on ne renvoie que celui-là
        if let bestIndex = preferredIndex {
            return [bestIndex]
        }
        
        // Sinon (pas de préféré détecté), on affiche tout par défaut
        return allIndices
    }
    
    private var displayedEventsIndices: [Int] {
        let allIndices = Array(0..<tagEvents.count)
        if showAllEvents {
            return allIndices
        } else {
            return Array(allIndices.prefix(3))
        }
    }
    
    private var stationsToDisplay: [NavigoStationInfo] {
        // 1. On récupère les événements concernés
        let relevantEvents = showAllEvents ? tagEvents : Array(tagEvents.prefix(3))
        
        // 2. On mappe vers les infos de station
        return relevantEvents.compactMap { event -> NavigoStationInfo? in
            let locId = getKey(event, "EventLocationId") ?? ""
            let code = getKey(event, "EventCode") ?? ""
            let provider = getKey(event, "EventServiceProvider") ?? ""
            let route = getKey(event, "EventRouteNumber")
            
            let location = interpretLocationId(locId, code, provider, route)
            return location.found ? location : nil
        }
    }
    
    var body: some View {
        List {
            Section(header:
                ZStack(alignment: .bottomLeading) {
                    if let holderCardStatus = getKey(tagEnvHolder, "HolderDataCardStatus"), let holderCommercialId = getKey(tagEnvHolder, "HolderDataCommercialID") {
                        NavigoImage(imageName: historyManager.history.first(where: { $0.cardID == cardID })?.image ?? interpretNavigoImage(holderCardStatus, holderCommercialId, tagContracts))
                            .shadow(radius: 2)
                        VStack(alignment: .leading) {
                            switch interpretNavigoPersonalizationStatusCode(holderCardStatus) {
                            case "Navigo Annuel":
                                Text("A")
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.black)
                            case "Navigo Imagine R":
                                Text("I")
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.black)
                            default:
                                Spacer(minLength: 0.0)
                            }
                            if cardID != 0 {
                                Text("\(cardID)")
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.black)
                            }
                        }
                        .padding()
                    }
                }
            ) {}
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            
            
            if tagContracts.count > 0 && tagEvents.count > 0 {
                StatusView(contracts: tagContracts, events: tagEvents)
            }
            
            if !tagEnvHolder.isEmpty {
                Section(header: Text("Environnement")) {
                    EnvHolderView(envHolderInfo: tagEnvHolder)
                }
            }
            
            if tagContracts.count > 0 {
                Section(header: Text("Contrats")) {
                    ForEach(displayedContractsIndices, id: \.self) { i in
                        NavigationLink {
                            ContractView(contractInfo: tagContracts[i])
                        } label: {
                            ContractPreview(
                                contractInfo: tagContracts[i],
                                isPreferred: isContractBest(tagContracts[i], tagContracts),
                                isDisabled: isContractDisabled(tagContracts[i])
                            )
                        }
                    }
                    
                    if tagContracts.count > 1 && !showAllContracts && displayedContractsIndices.count < tagContracts.count {
                        Button(action: {
                            withAnimation { showAllContracts = true }
                        }) {
                            HStack {
                                Text("Voir tout...")
                                Spacer()
                                Text("\(tagContracts.count)")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            
            if tagEvents.count > 0 {
                Section(header: Text("Derniers évènements")) {
                    ForEach(displayedEventsIndices, id: \.self) { i in
                        NavigationLink {
                            EventView(eventInfo: tagEvents[i], contractsInfos: tagContracts)
                        } label: {
                            EventPreview(eventInfo: tagEvents[i])
                        }
                    }
                    
                    if tagEvents.count > 3 && !showAllEvents {
                        Button(action: {
                            withAnimation { showAllEvents = true }
                        }) {
                            HStack {
                                Text("Voir tout...")
                                Spacer()
                                Text("\(tagEvents.count)")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                    }
                }
                
                if !stationsToDisplay.isEmpty {
                    Section {
                        EventsMapView(events: showAllEvents ? tagEvents : Array(tagEvents.prefix(3)))
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }
            }
            
            if tagSpecialEvents.count > 0 {
                Section(header: Text("Evènements spéciaux")) {
                    ForEach(tagSpecialEvents.indices, id: \.self) { i in
                        NavigationLink {
                            EventView(eventInfo: tagSpecialEvents[i], contractsInfos: tagContracts)
                        } label: {
                            EventPreview(eventInfo: tagSpecialEvents[i])
                        }
                    }
                }
            }
        }
        .navigationTitle(cardID != 0 ? historyManager.history.first(where: { $0.cardID == cardID })?.displayTitle ?? "" : "")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    Button(action: {
                        newNickname = historyManager.history.first(where: { $0.cardID == cardID })?.nickname ?? ""
                        showingRenameAlert = true
                    }) {
                        Label("Renommer le pass", systemImage: "pencil")
                    }
                    
                    Button(action: { showingImagePicker = true }) {
                        Label("Changer l'image", systemImage: "photo.on.rectangle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                
                if !tagEnvHolder.isEmpty, let jsonData = exportDataAsJSON {
                    let dateStr = ISO8601DateFormatter().string(from: Date()).prefix(10)
                    let fileName = "\(cardID)_\(dateStr).metropass"
                    
                    ShareLink(
                        item: ExportFile(data: jsonData, fileName: fileName),
                        preview: SharePreview("Données Navigo \(cardID)")
                    )
                } else {
                    // Optional: Disabled placeholder so the UI doesn't "jump"
                    Label("Exporter", systemImage: "square.and.arrow.up")
                        .opacity(0.5)
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerSheet(cardID: cardID, historyManager: historyManager)
                .presentationDetents([.medium, .large]) // Permet une ouverture partielle ou totale
        }
        .alert("Renommer la carte", isPresented: $showingRenameAlert) {
            TextField("Nom", text: $newNickname)
            Button("Annuler", role: .cancel) {}
            Button("Enregistrer") {
                historyManager.setNickname(for: cardID, to: newNickname)
                newNickname = ""
            }
        }
    }
}

#Preview {
    ScanView(cardID: 0, tagEnvHolder: [:], tagContracts: [], tagEvents: [], tagSpecialEvents: [], historyManager: HistoryManager())
}
