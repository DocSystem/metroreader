//
//  ContractPreview.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 07/02/2025.
//

import SwiftUI

struct ContractPreview: View {
    var contractInfo: [String: Any] = [
        "ContractBitmap": [
            "ContractTariff": "0101000000000000",
            "ContractValidityEndDate": "00000000000000000"
        ],
        "Counter": [
            "CounterStructureNumber": "01100", "CounterRelativeFirstStamp15mn": "010001001010110100", "CounterContractCount": "000010", "CounterLastLoad": "00001010"
        ]
    ]
    
    var isPreferred: Bool = false
    var isDisabled: Bool = false
    
    var body: some View {
        HStack {
            ContractIcon(contractType: interpretInt(getKey(contractInfo, "ContractTariff") ?? ""))
            VStack(alignment: .leading) {
                if let counterContractCount = getKey(contractInfo, "CounterContractCount") {
                    HStack(spacing: 4) {
                        Text("\(interpretTariff(getKey(contractInfo, "ContractTariff") ?? ""))")
                            .font(.system(size: 12))
                            .foregroundColor(isDisabled ? .gray : .primary)
                        if isPreferred {
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 12))
                        }
                    }
                    Text("\(interpretInt(counterContractCount)) ticket\(interpretInt(counterContractCount) == 1 ? "" : "s")")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(isDisabled ? .gray : .primary)
                }
                else {
                    HStack(spacing: 4) {
                        Text("\(interpretTariff(getKey(contractInfo, "ContractTariff") ?? ""))")
                            .fontWeight(.bold)
                            .foregroundColor(isDisabled ? .gray : .primary)
                        if isPreferred {
                            Image(systemName: "star.circle.fill")
                        }
                    }
                    HStack(spacing: 0) {
                        Text(interpretDate(getKey(contractInfo, "ContractValidityStartDate") ?? ""))
                            .font(.caption)
                            .foregroundColor(Color.gray)
                        if let contractValidityEndDate = getKey(contractInfo, "ContractValidityEndDate") {
                            Text(" - \(interpretDate(contractValidityEndDate))")
                                .font(.caption)
                                .foregroundColor(Color.gray)
                        }
                    }
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    ContractPreview()
}
