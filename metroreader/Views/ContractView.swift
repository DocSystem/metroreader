//
//  ContractView.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 07/02/2025.
//

import SwiftUI

struct ContractView: View {
    var contractInfo: [String: Any] = [
        "ContractBitmap": [
            "ContractTariff": "0101000000000000",
            // "ContractValidityEndDate": "00000000000000000"
        ],
        "Counter": [
            "CounterStructureNumber": "01100", "CounterRelativeFirstStamp15mn": "010001001010110100", "CounterContractCount": "000010", "CounterLastLoad": "00001010"
        ]
    ]
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .center, spacing: 8) {
                    Text("\(interpretTariff(getKey(contractInfo, "ContractTariff") ?? "", getKey(contractInfo, "ContractValidityEndDate") ?? ""))")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    HStack(spacing: 0) {
                        Text(interpretDate(getKey(contractInfo, "ContractValidityStartDate") ?? ""))
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                        if let contractValidityEndDate = getKey(contractInfo, "ContractValidityEndDate") {
                            Text(" - \(interpretDate(contractValidityEndDate))")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.white.opacity(0.0))
            }
            
            if let counterContractCount = getKey(contractInfo, "CounterContractCount") {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Ticket\(interpretInt(counterContractCount) == 1 ? "" : "s") restants")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(interpretInt(counterContractCount))")
                                .fontWeight(.semibold)
                        }
                        
                        Divider ()
                        
                        HStack {
                            Text("Dernière recharge")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(interpretInt(getKey(contractInfo, "CounterLastLoad") ?? ""))")
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("État")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(interpretStatus(getKey(contractInfo, "ContractStatus") ?? ""))
                            .fontWeight(.semibold)
                    }
                    
                    if let contractValidityZones = getKey(contractInfo, "ContractValidityZones") {
                        Divider()
                        
                        HStack {
                            Text("Zones")
                                .fontWeight(.semibold)
                            Spacer()
                            Text(interpretZonesShort(contractValidityZones))
                                .fontWeight(.semibold)
                        }
                    }
                    
                    if let contractSerialNumber = getKey(contractInfo, "ContractSerialNumber") {
                        Divider()
                        
                        HStack {
                            Text("Numéro de série")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(interpretInt(contractSerialNumber))")
                                .fontWeight(.semibold)
                        }
                    }
                    
                    if let contractAuthenticator = getKey(contractInfo, "ContractAuthenticator") {
                        Divider()
                        
                        HStack {
                            Text("Authenticateur")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(interpretInt(contractAuthenticator))")
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            
            Section(header: Text("Vente")) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Vendu le")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(interpretDate(getKey(contractInfo, "ContractValiditySaleDate") ?? ""))
                            .fontWeight(.semibold)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Vendu par")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(interpretServiceProvider(getKey(contractInfo, "ContractValiditySaleAgent") ?? ""))
                            .fontWeight(.semibold)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Appareil")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(interpretInt(getKey(contractInfo, "ContractValiditySaleDevice") ?? ""))")
                            .fontWeight(.semibold)
                    }
                    
                    if let contractPriceAmount = getKey(contractInfo, "ContractPriceAmount") {
                        Divider()
                        
                        HStack {
                            Text("Prix de vente")
                                .fontWeight(.semibold)
                            Spacer()
                            Text(String(format: "%.2f €", interpretAmount(contractPriceAmount)))
                                .fontWeight(.semibold)
                        }
                    }
                    
                    if let contractPayMethod = getKey(contractInfo, "ContractPayMethod") {
                        Divider()
                        
                        HStack {
                            Text("Mode de paiement")
                                .fontWeight(.semibold)
                            Spacer()
                            Text(interpretPayMethod(contractPayMethod))
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            
            Section {
                
            }
        }
    }
}

#Preview {
    ContractView()
}
