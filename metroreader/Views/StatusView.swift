//
//  StatusView.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 04/01/2026.
//

import SwiftUI

struct StatusView: View {
    let contracts: [[String: Any]]
    let events: [[String: Any]]
    
    private var data: (Bool, String?, Date?, TimeInterval?) {
        var titleInUse: Bool = false
        var titleName: String?
        var fromDate: Date?
        var duration: TimeInterval?
        for event in events {
            var eventDateTime = interpretDateAsDate(getKey(event, "EventDateStamp") ?? "")
            eventDateTime.addTimeInterval(interpretTimeAsTimeInterval(getKey(event, "EventTimeStamp") ?? ""))
            
            let eventContractPointer =  interpretInt(getKey(event, "EventContractPointer") ?? "")
            
            let eventTransition = interpretEventCode(getKey(event, "EventCode") ?? "").1
            
            if eventTransition.starts(with: "Entrée") {
                if contracts.count >= eventContractPointer {
                    let contract = contracts[Int(eventContractPointer) - 1]
                    if fromDate == nil || eventDateTime < fromDate! {
                        if ((eventDateTime + interpretTariffDuration(getKey(contract, "ContractTariff") ?? "")) > Date()) {
                            fromDate = eventDateTime
                            duration = interpretTariffDuration(getKey(contract, "ContractTariff") ?? "")
                            titleName = interpretTariff(getKey(contract, "ContractTariff") ?? "", getKey(contract, "ContractValidityEndDate") ?? "")
                            titleInUse = true
                        }
                    }
                }
            }
        }
        return (titleInUse, titleName, fromDate, duration)
    }
    
    private var titleInUse: Bool { data.0 }
    private var titleName: String? { data.1 }
    private var fromDate: Date? { data.2 }
    private var duration: TimeInterval? { data.3 } // Duration in seconds
    
    private func parseTime(_ seconds: Double) -> String {
        let hours = (Int(seconds) / 3600).isMultiple(of: 1) ? Int(seconds / 3600) : Int(seconds / 3600) + 1
        let minutes = (seconds.truncatingRemainder(dividingBy: 3600)) / 60
        let seconds = Int(seconds.truncatingRemainder(dividingBy: 60))
        return "\(hours):\(String(format: "%02d", Int(minutes))):\(String(format: "%02d", Int(seconds)))"
    }
    
    private func getColorForRemainingTime(_ seconds: Double) -> Color {
        if seconds >= 3600 {
            return Color.green.opacity(0.5)
        } else if seconds >= 1800 {
            return Color.yellow.opacity(0.5)
        } else if seconds >= 300 {
            return Color.orange.opacity(0.5)
        } else {
            return Color.red.opacity(0.5)
        }
    }
    
    var body: some View {
        if titleInUse {
            Section {
                VStack(alignment: .trailing, spacing: 8) {
                    HStack {
                        Text("Titre en cours")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(titleName ?? "Navigo")")
                            .fontWeight(.semibold)
                    }
                    if let fromDate = fromDate, let duration = duration {
                        TimelineView(.periodic(from: .now, by: 1.0)) { context in
                            Text("Restant : \(parseTime(fromDate.timeIntervalSinceNow + duration))")
                                .font(.system(.caption2, design: .monospaced))
                                .fontWeight(.bold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(getColorForRemainingTime(fromDate.timeIntervalSinceNow + duration)) // Fond du chip
                                )
                        }
                    }
                }
            }
            .listRowBackground(Color.green.opacity(0.2))
        } else {
            Section {
                Text("Aucun titre en cours d'utilisation")
                    .fontWeight(.semibold)
            }
            .listRowBackground(Color.gray.opacity(0.2))
        }
    }
}

#Preview {
    StatusView(contracts: [[
        "ContractBitmap" : [
          "ContractTariff" : "0000000000000101"
        ],
      ]], events: [[
          "EventDateStamp" : "10100101100010",
          "EventTimeStamp" : "00000111001",
          "EventBitmap" : [
            "EventCode" : "01010010",
            "EventContractPointer" : "00001"
          ]
        ],
        [
          "EventBitmap" : [
            "EventCode" : "01011010",
            "EventContractPointer" : "00001"
          ],
          "EventTimeStamp" : "00000011110",
          "EventDateStamp" : "10100101100010"
        ],
        [
          "EventTimeStamp" : "00000001110",
          "EventBitmap" : [
            "EventCode" : "00110001",
            "EventContractPointer" : "00001"
          ],
          "EventDateStamp" : "10100101100010"
        ]])
}
