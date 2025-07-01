//
//  NavigoImage.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 08/02/2025.
//

import SwiftUI

struct NavigoImage: View {
    let passKind: String
    
    var body: some View {
        switch passKind {
        case "Navigo Easy":
            Image("NavigoEasy")
                .resizable(resizingMode: .stretch)
                .aspectRatio(contentMode: .fill)
        case "Navigo Découverte":
            Image("NavigoDecouverte")
                .resizable(resizingMode: .stretch)
                .aspectRatio(contentMode: .fill)
        default:
            Image("Navigo")
                .resizable(resizingMode: .stretch)
                .aspectRatio(contentMode: .fill)
        }
    }
}

#Preview {
    NavigoImage(passKind: "Navigo")
}
