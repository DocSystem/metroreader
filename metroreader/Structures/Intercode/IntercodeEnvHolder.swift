//
//  IntercodeEnvHolder.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 06/02/2025.
//

let IntercodeEnvHolder: EN1545Element = EN1545Element(name: "EnvHolderStructure", field_type: FieldType.Container, subfields: [
    EN1545Element(name: "EnvApplicationVersionNumber", field_type: FieldType.Final, final_type: FinalType.VersionNumber),
    EN1545Element(name: "EnvBitmap", field_type: FieldType.Bitmap, final_type: FinalType.NetworkId, subfields: [
        EN1545Element(name: "EnvNetworkId", field_type: FieldType.Final, final_type: FinalType.NetworkId),
        EN1545Element(name: "EnvApplicationIssuerId", field_type: FieldType.Final, final_type: FinalType.ApplicationOwner),
        EN1545Element(name: "EnvApplicationValidityEndDate", field_type: FieldType.Final, final_type: FinalType.DateStamp),
        EN1545Element(name: "EnvPayMethod", field_type: FieldType.Final, final_type: FinalType.PayMethod),
        EN1545Element(name: "EnvAuthenticator", field_type: FieldType.Final, final_type: FinalType.Authenticator),
        EN1545Element(name: "EnvPOGroup", field_type: FieldType.Container, subfields: [
            EN1545Element(name: "EnvPOMedia", field_type: FieldType.Final, final_type: FinalType.INT1),
            EN1545Element(name: "EnvPOPersonalization", field_type: FieldType.Final, final_type: FinalType.INT1),
            EN1545Element(name: "EnvPORFU", field_type: FieldType.Final, final_type: FinalType.INT2)
        ]),
        EN1545Element(name: "EnvDataBitmap", field_type: FieldType.Bitmap, subfields: [
            EN1545Element(name: "EnvDataCardStatus", field_type: FieldType.Final, final_type: FinalType.TestFlag),
            EN1545Element(name: "EnvData2", field_type: FieldType.Final, final_type: FinalType.UNKNOWN)
        ])
    ]),
    EN1545Element(name: "HolderBitmap", field_type: FieldType.Bitmap, subfields: [
        EN1545Element(name: "HolderNameBitmap", field_type: FieldType.Bitmap, subfields: [
            EN1545Element(name: "HolderSurname", field_type: FieldType.Final, final_type: FinalType.NameString),
            EN1545Element(name: "HolderForename", field_type: FieldType.Final, final_type: FinalType.NameString)
            ]),
        EN1545Element(name: "HolderBirthBitmap", field_type: FieldType.Bitmap, subfields: [
            EN1545Element(name: "HolderBirthDate", field_type: FieldType.Final, final_type: FinalType.BirthDate),
            EN1545Element(name: "HolderBirthPlace", field_type: FieldType.Final, final_type: FinalType.BirthPlace)
            ]),
        EN1545Element(name: "HolderBirthName", field_type: FieldType.Final, final_type: FinalType.NameString),
        EN1545Element(name: "HolderIdNumber", field_type: FieldType.Final, final_type: FinalType.HolderId),
        EN1545Element(name: "HolderCountryAlpha", field_type: FieldType.Final, final_type: FinalType.CountryAlpha),
        EN1545Element(name: "HolderCompany", field_type: FieldType.Final, final_type: FinalType.HolderCompany),
        EN1545Element(name: "HolderProfilesList", field_type: FieldType.Counter, counter_size: 4, subfields: [
            EN1545Element(name: "HolderProfileBitmap", field_type: FieldType.Bitmap, subfields: [
                EN1545Element(name: "HolderProfileNetworkId", field_type: FieldType.Final, final_type: FinalType.NetworkId),
                EN1545Element(name: "HolderProfileNumber", field_type: FieldType.Final, final_type: FinalType.ProfileCodeIOP),
                EN1545Element(name: "HolderProfileDate", field_type: FieldType.Final, final_type: FinalType.DateStamp)
                ])
            ]),
        EN1545Element(name: "HolderDataBitmap", field_type: FieldType.Bitmap, subfields: [
            EN1545Element(name: "HolderDataCardStatus", field_type: FieldType.Final, final_type: FinalType.PersonalisationTypeCode),
            EN1545Element(name: "HolderDataSettlements", field_type: FieldType.Final, final_type: FinalType.UNKNOWN_4),
            EN1545Element(name: "HolderDataResidence", field_type: FieldType.Final, final_type: FinalType.CityId),
            EN1545Element(name: "HolderDataCommercialID", field_type: FieldType.Final, final_type: FinalType.CommercialId),
            EN1545Element(name: "HolderDataWorkPlace", field_type: FieldType.Final, final_type: FinalType.CityId),
            EN1545Element(name: "HolderDataStudyPlace", field_type: FieldType.Final, final_type: FinalType.CityId),
            EN1545Element(name: "HolderDataSaleDevice", field_type: FieldType.Final, final_type: FinalType.INT2),
            EN1545Element(name: "HolderDataAuthenticator", field_type: FieldType.Final, final_type: FinalType.Authenticator),
            EN1545Element(name: "HolderDataProfileStartDate1", field_type: FieldType.Final, final_type: FinalType.DateStamp),
            EN1545Element(name: "HolderDataProfileStartDate2", field_type: FieldType.Final, final_type: FinalType.DateStamp),
            EN1545Element(name: "HolderDataProfileStartDate3", field_type: FieldType.Final, final_type: FinalType.DateStamp),
            EN1545Element(name: "HolderDataProfileStartDate4", field_type: FieldType.Final, final_type: FinalType.DateStamp)
            ])
        ])
])
