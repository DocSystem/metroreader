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
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

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
            
            Section(header: Text("Crédits")) {
                VStack(alignment: .leading, spacing: 8) {
                    // Lien pour DocSystem
                    Link(destination: URL(string: "https://twitter.com/TheDocSystem")!) {
                        HStack {
                            Text("DocSystem")
                                .font(.headline)
                            Image(systemName: "arrow.up.right.circle.fill")
                                .font(.caption)
                        }
                    }
                    
                    Text("Recherche, rétro-ingénierie et développement")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    // Lien pour Stitch
                    Link(destination: URL(string: "https://twitter.com/TweetingStitch")!) {
                        HStack {
                            Text("Stitch")
                                .font(.headline)
                            Image(systemName: "arrow.up.right.circle.fill")
                                .font(.caption)
                        }
                    }
                    
                    Text("Designs des cartes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("À propos")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("\(appVersion) (\(buildNumber))")
                        .foregroundColor(.secondary)
                }
                Link(destination: URL(string: "https://github.com/DocSystem/metroreader")!) {
                    HStack {
                        Label("GitHub", systemImage: "terminal.fill")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right.circle.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
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
