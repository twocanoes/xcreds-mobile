//
//  ContentView.swift
//  LoginWindow
//
//  Created by Timothy Perfitt on 1/24/26.
//

import SwiftUI
import AuthenticationServices
internal import System
import OIDCLite
import WebKit
struct ContentView: View {
    @State var optionsSheetIsPresented = false
    
    @State var webView = WebView()
    @State var username:String=""
    @State var password:String=""
    @State var loggedIn:Bool = false
    @State var samActive = false
    @State var showWebLogin = false
    @State var resetOIDC = false
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @State var loadPage:Bool
    @Environment(\.authorizationController) private var authorizationController
    @Environment(\.scenePhase) private var scenePhase
    
    let currentDate = Date()
    //"Sat 24 Jan"
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE dd MMM"
        return formatter
    }()
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        return formatter
    }()
    
    fileprivate func LocalLoginView() -> ZStack<TupleView<(some View, some View)>> {
        return ZStack{
            Image("DefaultAerial")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                
                if samActive==false {
                    
                    Text("Single App Mode Not Enabled")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.red)
                        .padding(.top)
                }
                Text(dateFormatter.string(from: currentDate))
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .opacity(0.5)
                    .bold()
                    .padding(.top, 80)
                Text(timeFormatter.string(from: currentDate))
                    .font(.system(size: 110))
                    .foregroundColor(.white)
                    .opacity(0.5)
                    .bold()
                    .frame(height:60)
                Spacer()
                
                TextField("Username", text: $username, prompt: Text("Username").foregroundColor(.black))
                    .font(.system(size: 14))
                    .padding(.leading, 15)
                    .frame(width: 200, height:30)
                    .background(.regularMaterial)
                    .cornerRadius(20)
                    .autocorrectionDisabled(true)
                
                SecureField("Password", text: $password, prompt: Text("Enter Password").foregroundColor(.black))
                    .textContentType(.none)
                    .autocorrectionDisabled(true)
                
                    .font(.system(size: 14))
                    .padding(.leading, 15)
                    .frame(width: 200, height:30)
                    .background(.regularMaterial)
                    .cornerRadius(20)
                
                    .onSubmit {
                        loggedIn=true
                        UIAccessibility.requestGuidedAccessSession(enabled: false, completionHandler: {_ in })

                    }
                
                
                
                
            }
            .padding(.bottom,50)
        }
    }
    
    var body: some View {
        VStack {
            if loggedIn == false {
                ZStack{
                    
                    if showWebLogin == true {
                        LoginWebView(webView:$webView, loadPage:$loadPage, resetOIDC: $resetOIDC )
                    
                    }
                    else {
                        LocalLoginView()
                    }
                    VStack{
                        Spacer()
                        
                        HStack {
                            Spacer()
                            Button(action:{
                                optionsSheetIsPresented=true
                            }) {
                                Image(systemName: "gear.circle.fill")
                                    .resizable() // This allows the image to be resized
                                    .frame(width: 25, height: 25) // This sets the size of the image
                                
                            }
                            .controlSize(.extraLarge)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 8)
                            .sheet(isPresented: $optionsSheetIsPresented) {
                                if let discoveryURL = UserDefaults.standard.value(forKey: PrefKeys.discoveryURL.rawValue) as? String, discoveryURL.isEmpty == false {
                                    showWebLogin=false
                                    showWebLogin=true
                                    loadPage=true
                                    resetOIDC=true

                                }
                                else {
                                    showWebLogin=false
                                }

                            } content: {
                                OptionsSheet(optionsSheetIsPresented: $optionsSheetIsPresented)
                            }
                            .buttonStyle(.bordered)
                            .keyboardShortcut(",")
                            .labelStyle(.iconOnly)
                            .padding()
                            
                            Button("wifi"){
                                UIAccessibility.requestGuidedAccessSession(enabled: false, completionHandler: { enabled in
                                    WiFiController.shared.setupNetwork { success in
                                        UIAccessibility.requestGuidedAccessSession(enabled: true, completionHandler:{_ in })
                                    }
                                    

                                })

                            }
                            .padding()
                            .buttonStyle(.bordered)
                            Button("Exit SAM"){
                                UIAccessibility.requestGuidedAccessSession(enabled: false, completionHandler: { enabled in
                                })
                            }
                            .padding()
                            .buttonStyle(.bordered)
                            Button("Refresh"){
                                webView.loadPage()
                            }
                            .padding()
                            .buttonStyle(.bordered)
                        }
                    }
                    
                }
                
            }
            else {
                
                Text("Logged In")
                Button("reset"){
                    password=""
                    username=""
                    loggedIn=false

                }
                
            }
        }
        .onAppear(){
            UIAccessibility.requestGuidedAccessSession(enabled: true, completionHandler: { enabled in
                samActive=enabled
            })
            loadPage=true
            updatePrefsFromManagedPrefs()
            if let discoveryURL = UserDefaults.standard.value(forKey: PrefKeys.discoveryURL.rawValue) as? String, discoveryURL.isEmpty == false {
                showWebLogin=true
            }
        }
        
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                print("Active")
                UIAccessibility.requestGuidedAccessSession(enabled: true, completionHandler: { enabled in
                    samActive=enabled
                    
                })
                loadPage=true
            } else if newPhase == .inactive {
                print("Inactive")
            } else if newPhase == .background {
                print("Background")
            }
        }
        
    }
}
