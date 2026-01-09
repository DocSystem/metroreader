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
    let availableImages: [String: [String]] = [
        "Pass Originaux": ["Navigo", "Navigo Découverte", "Navigo Easy Carte", "Navigo Easy SOCS", "Navigo eSE Apple", "Carte ScolR"],
        "Pass Événementiels": ["Navigo Easy Carte JO", "Navigo JO Vert", "Navigo JO Jaune", "Navigo JO Rouge", "Navigo JO Bleu", "Navigo JO Noir", "Navigo JO", "Navigo JP"],
        "Pass Historiques": ["Navigo STIF", "NavigOrange"],
        "Pass Réseaux Externes": ["NavigOpus", "NavigOyster", "NavigoPassPass", "NavigAura"],
        "Pass Spéciaux": ["Navigo Anti-Pollution", "Ticket T+"],
        "Pass Entreprise": ["Pass Carmillion", "Pass Optile"],
        "Pass Ligne": ["C1", "M15", "RER B", "Grand Paris Express"]
    ]
    
    let categories: [String] = ["Pass Originaux", "Pass Événementiels", "Pass Historiques", "Pass Réseaux Externes", "Pass Spéciaux", "Pass Entreprise", "Pass Ligne"]
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // --- SECTION AUTOMATIQUE ---
                    Section {
                        Button {
                            historyManager.setImageName(for: cardID, to: "")
                            dismiss()
                        } label: {
                            VStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.secondary.opacity(0.1))
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.largeTitle)
                                        .foregroundColor(.secondary)
                                }
                                .frame(height: 100)
                                Text("Automatique").font(.caption).bold()
                            }
                        }
                        .buttonStyle(.plain)
                        .frame(width: 158) // Aligné sur la taille de la grille
                    }
                    
                    // --- PARCOURS DES CATÉGORIES ---
                    
                    ForEach(categories, id: \.self) { category in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(category)
                                .font(.title3)
                                .bold()
                                .padding(.bottom, 5)
                            
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(availableImages[category] ?? [], id: \.self) { imgName in
                                    Button {
                                        historyManager.setImageName(for: cardID, to: imgName)
                                        dismiss()
                                    } label: {
                                        VStack {
                                            NavigoImage(imageName: imgName)
                                                .frame(height: 100)
                                                .cornerRadius(10)
                                                .shadow(color: .black.opacity(0.1), radius: 3)
                                            
                                            Text(imgName)
                                                .font(.caption)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Choisir une image")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
            #else
            .toolbar {
                ToolbarItem {
                    Button("Fermer") { dismiss() }
                }
            }
            #endif
        }
    }
}
