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
                .aspectRatio(contentMode: .fit)
        case "Navigo Découverte":
            Image("NavigoDecouverte")
                .resizable(resizingMode: .stretch)
                .aspectRatio(contentMode: .fit)
        case "Navigo JO":
            Image("NavigoJO")
                .resizable(resizingMode: .stretch)
                .aspectRatio(contentMode: .fit)
        case "Navigo JP":
            Image("NavigoJP")
                .resizable(resizingMode: .stretch)
                .aspectRatio(contentMode: .fit)
        default:
            Image("Navigo")
                .resizable(resizingMode: .stretch)
                .aspectRatio(contentMode: .fit)
        }
    }
}

#Preview {
    NavigoImage(passKind: "Navigo")
}
