//
//  Networks.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 06/02/2025.
//

public struct NetworkInfo {
    let name: String
    let countryId: String
    let networkId: String
}

public class Networks {
    public class func find(countryId: String, networkId: String) -> NetworkInfo? {
        return Networks.allNetworks.first { $0.countryId == countryId && $0.networkId == networkId }
    }
    
    public static let allNetworks: [NetworkInfo] = [
        NetworkInfo(name: "Montréal", countryId: "124", networkId: "001"),
        NetworkInfo(name: "Île-de-France", countryId: "250", networkId: "901")
    ]
}
