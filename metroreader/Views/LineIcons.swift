//
//  LineIcons.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 30/12/2025.
//


import SwiftUI

struct LineIcons: View {
    let lines: [NavigoStationInfoLines]
    
    // Ordered list of modes to ensure RER always appears before Transilien
    let modeOrder = ["RER", "Transilien", "Métro", "Tramway"]
    
    func lines(for mode: String) -> [NavigoStationInfoLines] {
        lines
            .filter { $0.mode == mode }
            .sorted { $0.name < $1.name }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // 1. Get unique modes present in this list, sorted by our preferred order
            let presentModes = modeOrder.filter { mode in
                lines.contains(where: { $0.mode == mode })
            }
            
            ForEach(presentModes, id: \.self) { mode in
                HStack(spacing: 4) {
                    // 2. Display the Mode Icon
                    Image(modeIconName(for: mode))
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(.primary)
                    
                    ForEach(lines(for: mode), id: \.name) { line in
                        Text(line.name)
                            .font(.system(size: 16, weight: .bold))
                            .frame(width: 25, height: 25)
                            .background(Color(hex: line.background_color))
                            .cornerRadius(4)
                            .foregroundColor(Color(hex: line.text_color))
                    }
                }
                // Add extra spacing between different mode groups
                .padding(.trailing, 4)
            }
        }
    }
    
    // Helper to map mode strings to your asset names
    func modeIconName(for mode: String) -> String {
        switch mode {
        case "RER": return "mode_rer"
        case "Transilien", "Train": return "mode_train"
        default: return "mode_bus"
        }
    }
}

#Preview {
    LineIcons(lines: [NavigoStationInfoLines(name: "D", mode: "RER", background_color: "008b5b", text_color: "ffffff"), NavigoStationInfoLines(name: "A", mode: "RER", background_color: "eb2132", text_color: "ffffff")])
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
