//
//  ScanPageView.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 30/12/2025.
//


import SwiftUI

struct ScanPageView: View {
    @ObservedObject var nfcReader: NFCReader
    @ObservedObject var historyManager: HistoryManager
    @AppStorage("autoLaunchScan") private var autoLaunchScan = false
    @State private var hasAutoLaunched = false
    @State private var isImporting = false
    
    var body: some View {
        ScanView(cardID: nfcReader.cardID, tagEnvHolder: nfcReader.tagEnvHolder, tagContracts: nfcReader.tagContracts, tagEvents: nfcReader.tagEvents, tagSpecialEvents: nfcReader.tagSpecialEvents, exportDataAsJSON: nfcReader.exportDataAsJSON)
        .navigationTitle("")
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button(action: { isImporting = true }) {
                    Image(systemName: "square.and.arrow.down")
                }
                
                Button(action: {
                    nfcReader.beginScanning(historyManager: historyManager)
                }) {
                    Image(systemName: "wave.3.forward")
                }
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.metropass],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                
                // Security: Gain access to the file
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    if let data = try? Data(contentsOf: url) {
                        nfcReader.importJSON(from: data, historyManager: historyManager)
                    }
                }
            case .failure(let error):
                print("Error picking file: \(error.localizedDescription)")
            }
        }
        .onAppear {
            if autoLaunchScan && !hasAutoLaunched {
                nfcReader.beginScanning(historyManager: historyManager)
                hasAutoLaunched = true
            }
        }
    }
}

#Preview {
    ScanPageView(nfcReader: NFCReader(), historyManager: HistoryManager())
}
