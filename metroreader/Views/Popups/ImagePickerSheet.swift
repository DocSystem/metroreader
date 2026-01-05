//
//  ImagePickerSheet.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 04/01/2026.
//

import SwiftUI


struct ImagePickerSheet: View {
    @Environment(\.dismiss) var dismiss
    let cardID: UInt64
    @ObservedObject var historyManager: HistoryManager
    
    // Liste des images disponibles dans vos Assets
    let availableImages = [
        "Navigo", "Navigo Découverte",
        "Navigo Easy Carte", "Navigo Easy SOCS", "Navigo Easy Carte JO",
        "Navigo eSE Apple",
        "Navigo JO", "Navigo JP",
        "Navigo STIF", "NavigOrange", "Pass Carmillion", "NavigOpus", "NavigOyster", "NavigoPassPass"
    ]
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    // Option pour revenir à l'image automatique
                    Button {
                        historyManager.setImageName(for: cardID, to: "")
                        dismiss()
                    } label: {
                        VStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.secondary.opacity(0.2))
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.largeTitle)
                            }
                            .frame(width: 158, height: 100)
                            Text("Automatique").font(.caption).bold()
                        }
                    }
                    .buttonStyle(.plain)

                    // Liste des images manuelles
                    ForEach(availableImages, id: \.self) { imgName in
                        Button {
                            historyManager.setImageName(for: cardID, to: imgName)
                            dismiss()
                        } label: {
                            VStack {
                                NavigoImage(imageName: imgName)
                                    .frame(height: 100)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                                Text(imgName)
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Choisir une image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Fermer") { dismiss() }
            }
        }
    }
}
