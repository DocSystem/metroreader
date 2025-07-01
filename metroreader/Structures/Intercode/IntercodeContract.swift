//
//  IntercodeContract.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 07/02/2025.
//

let IntercodeContract: EN1545Element = EN1545Element(name: "ContractStructure", field_type: FieldType.Container, subfields: [
    EN1545Element(name: "ContractBitmap", field_type: FieldType.Bitmap, subfields: [
        EN1545Element(name: "ContractNetworkId", field_type: FieldType.Final, final_type: FinalType.NetworkId),
        EN1545Element(name: "ContractProvider", field_type: FieldType.Final, final_type: FinalType.ServiceProvider),
        EN1545Element(name: "ContractTariff", field_type: FieldType.Final, final_type: FinalType.TariffNumber),
        EN1545Element(name: "ContractSerialNumber", field_type: FieldType.Final, final_type: FinalType.ContractSerialNumber),
        
        EN1545Element(name: "ContractCustomerInfoBitmap", field_type: FieldType.Bitmap, subfields: [
            EN1545Element(name: "ContractCustomerProfile", field_type: FieldType.Final, final_type: FinalType.CustomerProfile),
            EN1545Element(name: "ContractCustomerNumber", field_type: FieldType.Final, final_type: FinalType.CustomerNumber)
        ]),

        EN1545Element(name: "ContractPassengerInfoBitmap", field_type: FieldType.Bitmap, subfields: [
            EN1545Element(name: "ContractPassengerClass", field_type: FieldType.Final, final_type: FinalType.AccommodationClassCode),
            EN1545Element(name: "ContractPassengerTotal", field_type: FieldType.Final, final_type: FinalType.INT1)
        ]),

        EN1545Element(name: "ContractVehicleClassAllowed", field_type: FieldType.Final, final_type: FinalType.UNKNOWN_6),
        EN1545Element(name: "ContractPaymentPointer", field_type: FieldType.Final, final_type: FinalType.UNKNOWN_32),
        EN1545Element(name: "ContractPayMethod", field_type: FieldType.Final, final_type: FinalType.PayMethod),
        EN1545Element(name: "ContractServices", field_type: FieldType.Final, final_type: FinalType.INT2),
        EN1545Element(name: "ContractPriceAmount", field_type: FieldType.Final, final_type: FinalType.Amount),
        EN1545Element(name: "ContractPriceUnit", field_type: FieldType.Final, final_type: FinalType.PaymentUnit),

        EN1545Element(name: "ContractRestrictionBitmap", field_type: FieldType.Bitmap, subfields: [
            EN1545Element(name: "ContractRestrictStart", field_type: FieldType.Final, final_type: FinalType.TimeStamp),
            EN1545Element(name: "ContractRestrictEnd", field_type: FieldType.Final, final_type: FinalType.TimeStamp),
            EN1545Element(name: "ContractRestrictDay", field_type: FieldType.Final, final_type: FinalType.DaysBitmap),
            EN1545Element(name: "ContractRestrictTimeCode", field_type: FieldType.Final, final_type: FinalType.RestrictedPeriodOfDay),
            EN1545Element(name: "ContractRestrictCode", field_type: FieldType.Final, final_type: FinalType.INT1),
            EN1545Element(name: "ContractRestrictProduct", field_type: FieldType.Final, final_type: FinalType.INT2),
            EN1545Element(name: "ContractRestrictLocation", field_type: FieldType.Final, final_type: FinalType.LocationId)
        ]),

        EN1545Element(name: "ContractValidityInfoBitmap", field_type: FieldType.Bitmap, subfields: [
            EN1545Element(name: "ContractValidityStartDate", field_type: FieldType.Final, final_type: FinalType.DateStamp),
            EN1545Element(name: "ContractValidityStartTime", field_type: FieldType.Final, final_type: FinalType.TimeStamp),
            EN1545Element(name: "ContractValidityEndDate", field_type: FieldType.Final, final_type: FinalType.DateStamp),
            EN1545Element(name: "ContractValidityEndTime", field_type: FieldType.Final, final_type: FinalType.TimeStamp),
            EN1545Element(name: "ContractValidityDuration", field_type: FieldType.Final, final_type: FinalType.INT1),
            EN1545Element(name: "ContractValidityLimiteDate", field_type: FieldType.Final, final_type: FinalType.DateStamp),
            EN1545Element(name: "ContractValidityZones", field_type: FieldType.Final, final_type: FinalType.Zones),
            EN1545Element(name: "ContractValidityJourneys", field_type: FieldType.Final, final_type: FinalType.CounterFlag),
            EN1545Element(name: "ContractPeriodJourneys", field_type: FieldType.Final, final_type: FinalType.CounterFlag)
        ]),

        EN1545Element(name: "ContractJourneyData", field_type: FieldType.Bitmap, subfields: [
            EN1545Element(name: "ContractJourneyOrigin", field_type: FieldType.Final, final_type: FinalType.LocationId),
            EN1545Element(name: "ContractJourneyDestination", field_type: FieldType.Final, final_type: FinalType.LocationId),
            EN1545Element(name: "ContractJourneyRouteNumbers", field_type: FieldType.Final, final_type: FinalType.INT2),
            EN1545Element(name: "ContractJourneyRouteVariants", field_type: FieldType.Final, final_type: FinalType.INT1),
            EN1545Element(name: "ContractJourneyRun", field_type: FieldType.Final, final_type: FinalType.JourneyRunId),
            EN1545Element(name: "ContractJourneyVia", field_type: FieldType.Final, final_type: FinalType.LocationId),
            EN1545Element(name: "ContractJourneyDistance", field_type: FieldType.Final, final_type: FinalType.INT2),
            EN1545Element(name: "ContractJourneyInterchanges", field_type: FieldType.Final, final_type: FinalType.INT1)
        ]),

        EN1545Element(name: "ContractSaleData", field_type: FieldType.Bitmap, subfields: [
            EN1545Element(name: "ContractValiditySaleDate", field_type: FieldType.Final, final_type: FinalType.DateStamp),
            EN1545Element(name: "ContractValiditySaleTime", field_type: FieldType.Final, final_type: FinalType.TimeStamp),
            EN1545Element(name: "ContractValiditySaleAgent", field_type: FieldType.Final, final_type: FinalType.ServiceProvider),
            EN1545Element(name: "ContractValiditySaleDevice", field_type: FieldType.Final, final_type: FinalType.INT2)
        ]),

        EN1545Element(name: "ContractStatus", field_type: FieldType.Final, final_type: FinalType.StatusCode),
        EN1545Element(name: "ContractLoyaltyPoints", field_type: FieldType.Final, final_type: FinalType.INT2),
        EN1545Element(name: "ContractAuthenticator", field_type: FieldType.Final, final_type: FinalType.Authenticator),
        EN1545Element(name: "ContractData", field_type: FieldType.Final, final_type: FinalType.UNKNOWN)
    ])
])

