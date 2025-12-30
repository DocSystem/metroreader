//
//  SettingsPageView.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 30/12/2025.
//

import SwiftUI

struct SettingsPageView: View {
    @ObservedObject var historyManager: HistoryManager
    // This stores the preference in the phone's memory automatically
    @AppStorage("autoLaunchScan") private var autoLaunchScan = false
    @AppStorage("isHistoryEnabled") private var isHistoryEnabled = false
    
    @State private var showingDeleteAlert = false

    var body: some View {
        List {
            Section(header: Text("Comportement")) {
                Toggle(isOn: $autoLaunchScan) {
                    Label("Scan au démarrage", systemImage: "bolt.fill")
                }
                
                Toggle(isOn: $isHistoryEnabled) {
                    Label("Conserver l'historique", systemImage: "clock.arrow.circlepath")
                }
            }
            
            Section(header: Text("Confidentialité")) {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Effacer tout l'historique", systemImage: "trash")
                }
                .disabled(historyManager.history.isEmpty)
            }
            
            Section(header: Text("À propos")) {
                Text("PassReader v1.0")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Réglages")
        .alert("Effacer l'historique ?", isPresented: $showingDeleteAlert) {
            Button("Annuler", role: .cancel) { }
            Button("Tout effacer", role: .destructive) {
                historyManager.clearAll()
            }
        } message: {
            Text("Cette action est irréversible. Tous vos scans enregistrés seront supprimés.")
        }
    }
}

#Preview {
    SettingsPageView(historyManager: HistoryManager())
}
