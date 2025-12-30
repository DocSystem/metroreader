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
    
    var body: some View {
        ScanView(cardID: nfcReader.cardID, tagEnvHolder: nfcReader.tagEnvHolder, tagContracts: nfcReader.tagContracts, tagEvents: nfcReader.tagEvents, tagSpecialEvents: nfcReader.tagSpecialEvents, exportDataAsJSON: nfcReader.exportDataAsJSON)
        .navigationTitle("")
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button(action: {
                    nfcReader.beginScanning(historyManager: historyManager)
                }) {
                    Image(systemName: "wave.3.forward")
                }
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
