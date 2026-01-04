//
//  ContractIcon.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 07/02/2025.
//

import SwiftUI

struct ContractIcon: View {
    let contractType: Int
    
    var body: some View {
        ZStack {
            switch contractType {
            case 0x0000:
                Image("ic_ticketing_month")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x0001:
                Image("ic_ticketing_week")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x0002:
                Image("ic_ticketing_year_pass")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x0003:
                Image("ic_ticketing_day")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x0004, 0x0005:
                Image("ic_ticketing_imaginer_pass")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x000D:
                Image("ic_ticketing_youthwe_pass")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x000E:
                Image("ic_ticketing_month")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x0015:
                Image("ic_ticketing_paris")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x1000, 0x1001:
                Image("ic_ticketing_liberte_plus")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x4000:
                Image("ic_ticketing_month")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x4001:
                Image("ic_ticketing_week")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x4015:
                Image("ic_ticketing_paris")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x5000:
                Image("ic_ticketing_ticket")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x5004:
                Image("ic_ticketing_orly_roissy")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x5005:
                Image("ic_ticketing_orly_roissy")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x5006:
                Image("ic_ticketing_ticket")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x5008:
                Image("ic_ticketing_ticket")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x500b:
                Image("ic_ticketing_orly_roissy")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x5010:
                Image("ic_ticketing_ticket")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x5016:
                Image("ic_ticketing_ticket")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x5018:
                Image("ic_ticketing_ticket")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x501b:
                Image("ic_ticketing_orly_roissy")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x8000:
                Image("ic_ticketing_default")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            case 0x8003:
                Image("ic_ticketing_default")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            default:
                Image("ic_ticketing_default")
                    .resizable(resizingMode: .stretch)
                    .padding(.all, 8.0)
            }
        }
            .frame(width: 40.0, height: 40.0)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 5.0))
    }
}

#Preview {
    ContractIcon(contractType: 0x0000)
}
