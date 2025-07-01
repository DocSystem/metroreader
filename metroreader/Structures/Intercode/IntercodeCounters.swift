//
//  IntercodeCounters.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 08/02/2025.
//

let IntercodeCounters: [Int: EN1545Element] = [
    0x0: EN1545Element(name: "Counter0Structure", field_type: FieldType.Container, subfields: [
        EN1545Element(name: "CounterCount", field_type: FieldType.Final, final_type: FinalType.INT3)
    ]),
    0xC: EN1545Element(name: "Counter12Structure", field_type: FieldType.Container, subfields: [
        EN1545Element(name: "CounterContractCount", field_type: FieldType.Final, final_type: FinalType.INT_6),
        EN1545Element(name: "CounterRelativeFirstStamp15mn", field_type: FieldType.Final, final_type: FinalType.RelativeFirstStamp15mn)
    ]),
]
