import SwiftUI

struct ContentView: View {
    @StateObject private var nfcReader = NFCReader()
    
    var body: some View {
        NavigationSplitView {
            List {
                Section {
                    ZStack(alignment: .bottomLeading) {
                        if let holderCardStatus = getKey(nfcReader.tagEnvHolder, "HolderDataCardStatus") {
                            NavigoImage(passKind: interpretNavigoPersonalizationStatusCode(holderCardStatus))
                                .shadow(radius: 2)
                            VStack(alignment: .leading) {
                                switch interpretNavigoPersonalizationStatusCode(holderCardStatus) {
                                case "Navigo Annuel":
                                    Text("A")
                                        .fontWeight(.medium)
                                        .foregroundColor(Color.black)
                                case "Navigo Imagine R":
                                    Text("I")
                                        .fontWeight(.medium)
                                        .foregroundColor(Color.black)
                                default:
                                    Spacer(minLength: 0.0)
                                }
                                if nfcReader.cardID != nil {
                                    Text("\(nfcReader.cardID!)")
                                        .fontWeight(.medium)
                                        .foregroundColor(Color.black)
                                }
                            }
                            .padding()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.white.opacity(0.0))
                
                if !nfcReader.tagEnvHolder.isEmpty {
                    Section(header: Text("Environnement")) {
                        EnvHolderView(envHolderInfo: nfcReader.tagEnvHolder)
                    }
                }
                
                if nfcReader.tagContracts.count > 0 {
                    Section(header: Text("Contrats")) {
                        ForEach(nfcReader.tagContracts.indices, id: \.self) { i in
                            NavigationLink {
                                ContractView(contractInfo: nfcReader.tagContracts[i])
                            } label: {
                                ContractPreview(contractInfo: nfcReader.tagContracts[i], isPreferred: isContractBest(nfcReader.tagContracts[i], nfcReader.tagContracts), isDisabled: isContractDisabled(nfcReader.tagContracts[i]))
                            }
                        }
                    }
                }
                
                if nfcReader.tagEvents.count > 0 {
                    Section(header: Text("Derniers évènements")) {
                        ForEach(nfcReader.tagEvents.indices, id: \.self) { i in
                            NavigationLink {
                                EventView(eventInfo: nfcReader.tagEvents[i], contractsInfos: nfcReader.tagContracts)
                            } label: {
                                EventPreview(eventInfo: nfcReader.tagEvents[i])
                            }
                        }
                    }
                }
                
                if nfcReader.tagSpecialEvents.count > 0 {
                    Section(header: Text("Evènements spéciaux")) {
                        ForEach(nfcReader.tagSpecialEvents.indices, id: \.self) { i in
                            NavigationLink {
                                EventView(eventInfo: nfcReader.tagSpecialEvents[i], contractsInfos: nfcReader.tagContracts)
                            } label: {
                                EventPreview(eventInfo: nfcReader.tagSpecialEvents[i])
                            }
                        }
                    }
                }
                
                Section {
                    HStack(alignment: .center) {
                        Button("Scanner une carte") {
                            nfcReader.beginScanning()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.white.opacity(0.0))
            }
            .navigationTitle("")
        } detail: {
            Text("Sélectionnez une donnée")
        }
        .onAppear {
            nfcReader.beginScanning()
        }
    }
}

@main
struct NFCReaderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#Preview {
    ContentView()
}
