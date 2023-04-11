//
//  ContentView.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 06/12/2022.
//

import SwiftUI
import VerIDCore
import VerIDUI
import BlinkID

struct ContentView: View {
    
    @StateObject var verIDLoader: VerIDLoader = VerIDLoader()
    @StateObject var microblinkKeyLoader: MicroblinkKeyLoader = MicroblinkKeyLoader()
    @StateObject var microblinkSessionRunner: MicroblinkSessionRunner = MicroblinkSessionRunner()
    @State var showingSessionResult = true
    
    var body: some View {
        NavigationView {
            if microblinkSessionRunner.status != .idle {
                ProgressView {
                    if microblinkSessionRunner.status == .capturing {
                        Text("Capturing document")
                    } else {
                        Text("Processing captured document")
                    }
                }
            } else if let sessionResult = microblinkSessionRunner.sessionResult, self.showingSessionResult {
                NavigationLink(isActive: $showingSessionResult) {
                    IDCardView(sessionResult: sessionResult)
                } label: {
                    EmptyView()
                }
            } else if let verIDResult = verIDLoader.result, let microblinkKeyResult = microblinkKeyLoader.result {
                ZStack {
                    VStack {
                        Spacer()
                        Image("woman_with_licence").frame(maxWidth: 200)
                    }.ignoresSafeArea()
                    if case .success(let verID) = verIDResult, case .success() = microblinkKeyResult {
                        VStack {
                            HStack {
                                Text("1. Scan your ID card 2. Compare the face on the ID card to a selfie").shadow(color: Color(.systemBackground), radius: 2)
                                Spacer()
                            }
                            HStack {
                                Button {
                                    self.microblinkSessionRunner.verID = verID
                                    self.microblinkSessionRunner.sessionResult = nil
                                    self.showingSessionResult = true
                                    self.microblinkSessionRunner.captureDocument()
                                } label: {
                                    Image(systemName: "camera")
                                    Text("Scan ID card")
                                }
                                .buttonStyle(.borderedProminent)
                                .padding(.top, 16)
                                Spacer()
                            }
                            Spacer()
                        }.padding()
                    } else if case .failure(let error) = verIDResult {
                        VStack {
                            HStack {
                                Text("Failed to load Ver-ID")
                                Spacer()
                            }
                            Spacer()
                        }
                    } else {
                        VStack {
                            HStack {
                                Text("Failed to load BlinkID")
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }.navigationTitle("ID Capture")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink {
                                AppInfoView()
                            } label: {
                                Image(systemName: "gearshape")
                            }
                        }
                    }
            } else {
                ProgressView {
                    Text("Loading Ver-ID")
                }
            }
        }.navigationViewStyle(.stack).environmentObject(verIDLoader)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
