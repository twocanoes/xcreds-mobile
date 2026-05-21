//
//  OptionsSheet.swift
//  DFU Blaster
//
//  Created by Timothy Perfitt on 9/24/24.
//
import SwiftUI
import UniformTypeIdentifiers
struct OptionsSheet: View {

    
    @AppStorage(PrefKeys.discoveryURL.rawValue) var discoveryURL: String = ""
    @AppStorage(PrefKeys.clientSecret.rawValue) var clientSecret: String = ""
    @AppStorage(PrefKeys.clientID.rawValue) var clientID: String = ""
    @AppStorage(PrefKeys.scopes.rawValue) var scopes: String = ""
    @AppStorage(PrefKeys.shouldSetGoogleAccessTypeToOffline.rawValue) var shouldSetGoogleAccessTypeToOffline: Bool = false
    @AppStorage("settingsURL") var settingsURL: String = ""

    @AppStorage(PrefKeys.redirectURI.rawValue) var redirectURI:String = ""



    @Binding var optionsSheetIsPresented: Bool

    fileprivate func loadURL() {
        let url = URL(string:settingsURL )
        if let url = url {
            if let contents = NSDictionary(contentsOf:url ) as? Dictionary<String,Any>{
                for (k,v) in contents {
                    UserDefaults.standard.set(v, forKey: k)
                }
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    var body: some View {
        VStack (alignment: .leading){
            VStack{
//                Text("Settings")
//                    .font(.title)
//                    .padding()

                List {
                    Section(header: Text("OIDC")) {
                        
                        HStack{
                            Text("Discovery URL:")
                            TextField("Discovery URL", text: $discoveryURL)
                        }
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        
                        HStack{
                            Text("Client Secret:")
                            TextField("secret", text: $clientSecret)
                            
                        }
                        HStack{
                            Text("clientID:")
                            TextField("clientID", text: $clientID)
                            
                        }
                        HStack{
                            Text("redirect URI:")
                            TextField("redirectURI", text: $redirectURI)
                            
                        }
                        HStack{
                            Text("Scopes:")
                            
                            TextField("Scopes", text: $scopes)
                            
                        }
                        HStack{
                            Toggle(isOn: $shouldSetGoogleAccessTypeToOffline) {
                                Text("shouldSetGoogleAccessTypeToOffline")
                            }
                            
                            
                        }
                      


                    }
//                    .disabled(true)
//                    Section(header: Text("WiFi")) {
//                        HStack{
//                                            Text("WiFi SSID:")
//                                            TextField("ssid", text: $ssid)
//                        
//                                        }
//                                        .padding([.top,.leading,.trailing])
//                        
//                                        HStack{
//                                            Text("WiFi Password:")
//                        
//                                            TextField("Password", text: $wifiPassword)
//                        
//                                        }
//                                        .padding([.top,.leading,.trailing])
//                                        
//                    }
//                    .disabled(true)
//                    Section(header: Text("Load Settings From URL")) {
//                        TextField("URL", text: $settingsURL)
//                        Button("Load"){
//                            
//                            loadURL()
//                        }
//
//                    }


                }
                
            }
            
        }
   
        
        HStack{
            Button("Reset Prefs"){
                
                resetPrefs()
                discoveryURL = ""
                clientSecret = ""
                clientID = ""
                scopes = ""
                shouldSetGoogleAccessTypeToOffline = false
                
            }
            .padding()
            Spacer()
            Button {
                optionsSheetIsPresented.toggle()
                
            } label: {
                Text("OK")
                    .frame(width: 50)
            }
//            .simultaneousGesture(LongPressGesture().onEnded { _ in
//                discoveryURL = "https://accounts.google.com/.well-known/openid-configuration"
//                clientSecret = "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"
//                clientID = "421164668086-v3ocec44vrmgjjh41h9r2hj6cjh5erpk.apps.googleusercontent.com"
//                scopes = "profile openid email"
//                shouldSetGoogleAccessTypeToOffline = true
//                redirectURI = "https://twocanoes.com/xcreds-redirect"
//            })
            
            .padding()

            
                
        }

    }

    
    func selectScriptPath() {

        let folderChooserPoint = CGPoint(x: 0, y: 0)
        let folderChooserSize = CGSize(width: 500, height: 600)
        let folderChooserRectangle = CGRect(origin: folderChooserPoint, size: folderChooserSize)
//        let folderPicker = NSOpenPanel(contentRect: folderChooserRectangle, styleMask: .utilityWindow, backing: .buffered, defer: true)
//        folderPicker.canChooseDirectories = false
//        folderPicker.canChooseFiles = true
//        folderPicker.allowsMultipleSelection = false
//
//        folderPicker.begin { response in
//
////            if response == .OK {
////                if let first = folderPicker.urls.first {
////                    eventScriptPath = first.path
////                }
////            }
//        }
    }

}
