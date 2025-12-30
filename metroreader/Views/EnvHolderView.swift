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
            Text("App Version: \(interpretAppVersionNumber(getKey(envHolderInfo, "EnvApplicationVersionNumber") ?? ""))")
            Text("Country: \(interpretNetworkId(getKey(envHolderInfo, "EnvNetworkId") ?? "").0)")
            Text("Network: \(interpretNetworkId(getKey(envHolderInfo, "EnvNetworkId") ?? "").1)")
            Text("Expiration Date: \(interpretDate(getKey(envHolderInfo, "EnvApplicationValidityEndDate") ?? ""))")
            if let holderCardStatus = getKey(envHolderInfo, "HolderDataCardStatus") {
                Text("Card status: \(interpretPersonalizationStatusCode(holderCardStatus).0)")
            }
            if let holderCommercialId = getKey(envHolderInfo, "HolderDataCommercialID") {
                Text("Commercial ID: \(interpretNavigoCommercialId(holderCommercialId))")
            }
        }
    }
}

#Preview {
    EnvHolderView(envHolderInfo: [:])
}
