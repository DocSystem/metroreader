//
//  IntercodeContractList.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 08/02/2025.
//

let IntercodeContractList: EN1545Element = EN1545Element(name: "ContractListStructure", field_type: FieldType.Container, subfields: [
    EN1545Element(name: "ContractList", field_type: FieldType.Counter, counter_size: 4, subfields: [
        EN1545Element(name: "ContractListBitmap", field_type: FieldType.Bitmap, subfields: [
            EN1545Element(name: "ContractListNetworkId", field_type: FieldType.Final, final_type: FinalType.NetworkId),
            EN1545Element(name: "ContractListTariffGroup", field_type: FieldType.Container, subfields: [
                EN1545Element(name: "ContractListTariffKey", field_type: FieldType.Final, final_type: FinalType.INT_4),
                EN1545Element(name: "ContractListTariffStructure", field_type: FieldType.Final, final_type: FinalType.INT1),
                EN1545Element(name: "ContractListTariffPriority", field_type: FieldType.Final, final_type: FinalType.INT_4)
            ]),
            EN1545Element(name: "ContractListPointer", field_type: FieldType.Final, final_type: FinalType.Pointer)
        ])
    ])
])
