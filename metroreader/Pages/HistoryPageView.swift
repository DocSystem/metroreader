//
//  HistoryPageView.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 30/12/2025.
//

import SwiftUI


struct HistoryPageView: View {
    @ObservedObject var historyManager: HistoryManager
    @State private var selectedRecord: ScanRecord?
    
    var body: some View {
        List {
            ForEach(historyManager.history) { record in
                Button {
                    selectedRecord = record
                } label: {
                    HStack(spacing: 8) {
                        NavigoImage(passKind: interpretNavigoPersonalizationStatusCode(getKey(record.envHolder, "HolderDataCardStatus") ?? "", getKey(record.envHolder, "HolderDataCommercialID") ?? "", record.contracts))
                            .shadow(radius: 2)
                            .frame(height: 50)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(interpretNavigoCommercialId(getKey(record.envHolder, "HolderDataCommercialID") ?? ""))")
                                .font(.headline)
                            
                            HStack {
                                if let cardID = record.cardID, cardID != 0 {
                                    Text("\(cardID)")
                                        .font(.caption)
                                        .padding(4)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(4)
                                        .foregroundStyle(.secondary)
                                }
                             
                                Spacer()
                                
                                Text(record.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .buttonStyle(.plain)
            }
            .onDelete { indexSet in
                historyManager.deleteItems(at: indexSet)
            }
        }
        .navigationTitle("Historique")
        .sheet(item: $selectedRecord) { record in
            NavigationStack {
                ScanView(
                    cardID: record.cardID,
                    tagEnvHolder: record.envHolder,
                    tagContracts: record.contracts,
                    tagEvents: record.events,
                    tagSpecialEvents: record.specialEvents,
                    exportDataAsJSON: record.exportDataAsJSON
                )
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Fermer") { selectedRecord = nil }
                    }
                }
            }
        }
    }
}

#Preview {
    HistoryPageView(historyManager: HistoryManager())
}
