//
//  NavigoImage.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 08/02/2025.
//

import SwiftUI

struct NavigoImage: View {
    let imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable(resizingMode: .stretch)
            .aspectRatio(contentMode: .fit)
    }
}

#Preview {
    NavigoImage(imageName: "Navigo JO")
}
