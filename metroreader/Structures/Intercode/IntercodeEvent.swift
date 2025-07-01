//
//  IntercodeEvent.swift
//  metroreader
//
//  Created by Antoine Souben-Fink on 07/02/2025.
//

let IntercodeEvent: EN1545Element = EN1545Element(name: "EventStructure", field_type: FieldType.Container, subfields: [
    EN1545Element(name: "EventDateStamp", field_type: FieldType.Final, final_type: FinalType.DateStamp),
    EN1545Element(name: "EventTimeStamp", field_type: FieldType.Final, final_type: FinalType.TimeStamp),
    EN1545Element(name: "EventBitmap", field_type: FieldType.Bitmap, subfields: [
        EN1545Element(name: "EventDisplayData", field_type: FieldType.Final, final_type: FinalType.INT1),
        EN1545Element(name: "EventNetworkId", field_type: FieldType.Final, final_type: FinalType.NetworkId),
        EN1545Element(name: "EventCode", field_type: FieldType.Final, final_type: FinalType.EventCode),
        EN1545Element(name: "EventResult", field_type: FieldType.Final, final_type: FinalType.EventResult),
        EN1545Element(name: "EventServiceProvider", field_type: FieldType.Final, final_type: FinalType.ServiceProvider),
        EN1545Element(name: "EventNotOkCounter", field_type: FieldType.Final, final_type: FinalType.INT1),
        EN1545Element(name: "EventSerialNumber", field_type: FieldType.Final, final_type: FinalType.SerialNumber),
        EN1545Element(name: "EventDestination", field_type: FieldType.Final, final_type: FinalType.LocationId),
        EN1545Element(name: "EventLocationId", field_type: FieldType.Final, final_type: FinalType.LocationId),
        EN1545Element(name: "EventLocationGate", field_type: FieldType.Final, final_type: FinalType.INT1),
        EN1545Element(name: "EventDevice", field_type: FieldType.Final, final_type: FinalType.INT2),
        EN1545Element(name: "EventRouteNumber", field_type: FieldType.Final, final_type: FinalType.RouteId),
        EN1545Element(name: "EventRouteVariant", field_type: FieldType.Final, final_type: FinalType.RouteVariantId),
        EN1545Element(name: "EventJourneyRun", field_type: FieldType.Final, final_type: FinalType.INT2),
        EN1545Element(name: "EventVehicleId", field_type: FieldType.Final, final_type: FinalType.INT2),
        EN1545Element(name: "EventVehicleClass", field_type: FieldType.Final, final_type: FinalType.INT1),
        EN1545Element(name: "EventLocationType", field_type: FieldType.Final, final_type: FinalType.LocationTypeId),
        EN1545Element(name: "EventEmployee", field_type: FieldType.Final, final_type: FinalType.EventEmployee),
        EN1545Element(name: "EventLocationReference", field_type: FieldType.Final, final_type: FinalType.INT2),
        EN1545Element(name: "EventJourneyInterchanges", field_type: FieldType.Final, final_type: FinalType.INT1),
        EN1545Element(name: "EventPeriodJourneys", field_type: FieldType.Final, final_type: FinalType.INT2),
        EN1545Element(name: "EventTotalJourneys", field_type: FieldType.Final, final_type: FinalType.INT2),
        EN1545Element(name: "EventJourneyDistance", field_type: FieldType.Final, final_type: FinalType.INT2),
        EN1545Element(name: "EventPriceAmount", field_type: FieldType.Final, final_type: FinalType.Amount),
        EN1545Element(name: "EventPriceUnit", field_type: FieldType.Final, final_type: FinalType.PaymentUnit),
        EN1545Element(name: "EventContractPointer", field_type: FieldType.Final, final_type: FinalType.Pointer),
        EN1545Element(name: "EventAuthenticator", field_type: FieldType.Final, final_type: FinalType.Authenticator),
        EN1545Element(name: "EventDataBitmap", field_type: FieldType.Bitmap, subfields: [
            EN1545Element(name: "EventDataDateFirstStamp", field_type: FieldType.Final, final_type: FinalType.DateStamp),
            EN1545Element(name: "EventDataTimeFirstStamp", field_type: FieldType.Final, final_type: FinalType.TimeStamp),
            EN1545Element(name: "EventDataSimulation", field_type: FieldType.Final, final_type: FinalType.EventDataSimulation),
            EN1545Element(name: "EventDataTrip", field_type: FieldType.Final, final_type: FinalType.UNKNOWN_2),
            EN1545Element(name: "EventDataRouteDirection", field_type: FieldType.Final, final_type: FinalType.JourneyTypeCode)
        ])
    ])
])
