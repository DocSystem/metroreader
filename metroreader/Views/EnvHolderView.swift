//
//  EnvHolder.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 06/02/2025.
//

import SwiftUI

struct EnvHolderView: View {
    var envHolderInfo: [String: Any]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Version de l'app : \(interpretAppVersionNumber(getKey(envHolderInfo, "EnvApplicationVersionNumber") ?? ""))")
            Text("Pays : \(interpretNetworkId(getKey(envHolderInfo, "EnvNetworkId") ?? "").0)")
            Text("Réseau : \(interpretNetworkId(getKey(envHolderInfo, "EnvNetworkId") ?? "").1)")
            Text("Date d'expiration : \(interpretDate(getKey(envHolderInfo, "EnvApplicationValidityEndDate") ?? ""))")
            if let holderCardStatus = getKey(envHolderInfo, "HolderDataCardStatus") {
                Text("Type de carte : \(interpretPersonalizationStatusCode(holderCardStatus).0)")
            }
            if let holderCommercialId = getKey(envHolderInfo, "HolderDataCommercialID") {
                Text("Type commercial : \(interpretNavigoCommercialId(holderCommercialId))")
            }
        }
    }
}

#Preview {
    EnvHolderView(envHolderInfo: [:])
}
