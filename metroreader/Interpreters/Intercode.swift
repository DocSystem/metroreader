//
//  Intercode.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 08/02/2025.
//

import Foundation

func isContractBest(_ contractInfo: [String: Any], _ allContracts: [[String: Any]]) -> Bool {
    var minPriority = 0x10
    if isContractDisabled(contractInfo) {
        return false
    }
    for contract in allContracts {
        if !isContractDisabled(contract) && interpretInt(getKey(contract, "ContractListTariffPriority") ?? "0") < minPriority {
            minPriority = interpretInt(getKey(contract, "ContractListTariffPriority") ?? "0")
        }
    }
    return interpretInt(getKey(contractInfo, "ContractListTariffPriority") ?? "0") == minPriority
}

func isContractDisabled(_ contractInfo: [String: Any]) -> Bool {
    // Check if priority is a disabled one
    if let priority = getKey(contractInfo, "ContractListTariffPriority") {
        if interpretInt(priority) >= 0xC {
            return true
        }
    }
    
    // Check validity end date, if there's one
    if let contractValidityEndDate = getKey(contractInfo, "ContractValidityEndDate") {
        if interpretDateAsDate(contractValidityEndDate) < Date() {
            return true
        }
    }
    
    // Check if counter value is 0, if there's a counter
    if let counterValue = getKey(contractInfo, "CounterContractCount") {
        if interpretInt(counterValue) == 0 {
            return true
        }
    }
    
    return false
}
