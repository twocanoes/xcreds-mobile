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
    
    @State var timer:Timer?
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
    
    @State private var showingPopover = false
    @State private var showingWifiPopover = false
    @State private var wifiNetworks:[WifiNetwork] = []
    
    @State private var wifiSelection:WifiNetwork?
    @AppStorage(PrefKeys.webHookAuthToken.rawValue) var webHookAuthToken: String?
    @AppStorage(PrefKeys.webHookURLString.rawValue) var webHookURLString: String?


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
    /*
     if let imagePathURL = DefaultsOverride.standardOverride.string(forKey: PrefKeys.loginWindowBackgroundImageURL.rawValue), let image = NSImage.imageFromPathOrURL(pathURLString: imagePathURL){

     */
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
                        UIAccessibility.requestGuidedAccessSession(enabled: false, completionHandler: { enabled in
                            samActive=false
                            postWebhookMessage(["event": "login"], )
                        })
                    }
                
                
                
                
            }
            .padding(.bottom,50)
            
        }
        
    }
    // Pull version and build info from bundle.
    func versionString() -> String? {
        let fullVersionString: String?
        if let bundle = Bundle.findBundleWithName(name: "XCreds"),
           let infoPlist = bundle.infoDictionary,
           let versionString = infoPlist["CFBundleShortVersionString"],
           let buildString = infoPlist["CFBundleVersion"]
        {
            fullVersionString = "\(versionString) (\(buildString))"
        } else {
            fullVersionString = nil
        }
        return fullVersionString
    }
    func postWebhookMessage(_ message: [String: String]) {
        if let token = webHookAuthToken,
           let urlString = webHookURLString,
           let webHookURL = URL(string: urlString) {
            URLSession.shared.postWebHook(url: webHookURL, token: token, payload: message)
        }
    }
    var body: some View {

        VStack {
            if loggedIn == false {
                ZStack{
                    if let imageURLString = UserDefaults.standard.value(forKey: PrefKeys.loginWindowBackgroundImageURL.rawValue) as? String,
                       let imageURL = URL(string: imageURLString){
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable(resizingMode: .stretch)
                                .ignoresSafeArea()
                        } placeholder: {}
                        
                    }
                    if showWebLogin == true {
                        let width = CGFloat(UserDefaults.standard.float(forKey: PrefKeys.loginWindowWidth.rawValue))
                        let height = CGFloat(UserDefaults.standard.float(forKey: PrefKeys.loginWindowHeight.rawValue))

                        LoginWebView(webView:$webView, loadPage:$loadPage, resetOIDC: $resetOIDC )
                            .refreshable{
                                webView.loadPage()

                            }
                            .frame(width: width > 150 ? width: nil,height: height > 150 ? height: nil)
                            .ignoresSafeArea()

                    }
                    else {
                        LocalLoginView()
                    }
                    VStack{

                        Spacer()
                        
                        HStack {
                            if UserDefaults.standard.bool(forKey: PrefKeys.shouldShowSystemInfoButton.rawValue)==true{
                                
                                Button(UserDefaults.standard.string(forKey: PrefKeys.systemInfoButtonTitle.rawValue) ?? "System Info") {
                                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                        if success {
                                            //                                            Logging.sharedLogger.printLog("All set!")
                                        } else if let error = error {
                                            //                                            TCSLo(error.localizedDescription)
                                        }
                                    }
                                    
                                    if UserDefaults.standard.bool(forKey: PrefKeys.shouldActivateSystemInfoButton.rawValue)==true{
                                        showingPopover = true
                                    }
                                    
                                    
                                }
                                
                                .buttonStyle(.borderedProminent)
                                
                                .popover(isPresented: $showingPopover, arrowEdge: .bottom) {
                                    
                                    VStack(alignment: .leading){
                                        Text("Name: \(UIDevice.current.name)")
                                        Text("System Version: \(UIDevice.current.systemVersion)")
                                        Text("System Name: \(UIDevice.current.systemName)")
                                        Text("Model: \(UIDevice.current.model)")
                                        if let version = versionString() {
                                            Text("XCreds: \(version)")
                                        }
                                    }
                                    .padding()
                                    
                                }
                                .padding()
                            }
                            
                            Spacer()
                            //                            Button(action:{
                            //                                optionsSheetIsPresented=true
                            //                            }) {
                            //                                Image(systemName: "gear.circle.fill")
                            //                                    .resizable() // This allows the image to be resized
                            //                                    .frame(width: 25, height: 25) // This sets the size of the image
                            //
                            //                            }
                            //                            .controlSize(.extraLarge)
                            //                            .frame(maxWidth: .infinity, alignment: .trailing)
                            //                            .padding(.trailing, 8)
                            //                            .sheet(isPresented: $optionsSheetIsPresented) {
                            //                                if let discoveryURL = UserDefaults.standard.value(forKey: PrefKeys.discoveryURL.rawValue) as? String, discoveryURL.isEmpty == false {
                            //                                    showWebLogin=false
                            //                                    showWebLogin=true
                            //                                    loadPage=true
                            //                                    resetOIDC=true
                            //
                            //                                }
                            //                                else {
                            //                                    showWebLogin=false
                            //                                }
                            
                            //                            } content: {
                            //                                OptionsSheet(optionsSheetIsPresented: $optionsSheetIsPresented)
                            //                            }
                            //                            .buttonStyle(.borderedProminent)
                            //                            .keyboardShortcut(",")
                            //                            .labelStyle(.iconOnly)
                            //                            .padding()
                            //
                            //
                            
                            if wifiNetworks.count>0{
                                Button("wifi"){
                                    showingWifiPopover=true
                                    //
                                }
                                .padding()
                                .buttonStyle(.borderedProminent)
                                
                                .popover(isPresented: $showingWifiPopover, arrowEdge: .bottom) {
                                    
                                    
                                    
                                    List(){
                                        Section(header: Text("Please select a WiFi network to join")){
                                            ForEach(wifiNetworks) { network in
                                                
                                                Button(network.name){
                                                    showingWifiPopover=false
                                                    UIAccessibility.requestGuidedAccessSession(enabled: false, completionHandler: { enabled in
                                                        WiFiController.shared.setupNetwork (network) { success in
                                                            UIAccessibility.requestGuidedAccessSession(enabled: true, completionHandler:{enabled in
                                                            })
                                                        }
                                                        
                                                        
                                                    })
                                                }
                                                
                                            }
                                        }
                                    }
                                    
                                    .frame(minWidth: 400, minHeight: 200)
                                    
                                    
                                }
                                .padding()
                                
                            }
                            if UserDefaults.standard.bool(forKey: PrefKeys.shouldAllowExitSAM.rawValue) == true {
                                
                                Button("Exit SAM"){
                                    
                                    Task{
                                        UIAccessibility.requestGuidedAccessSession(enabled: false, completionHandler: { enabled in
                                            samActive=false
                                            webView.showLoginSuccessful()
                                            
                                        })
                                    }
                                }
                                .padding()
                                .buttonStyle(.borderedProminent)
                            }
                            Button("Refresh"){
                                webView.loadPage()
                            }
                            .padding()
                            .buttonStyle(.borderedProminent)
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
            readDefaults()
            if UserDefaults.standard.integer(forKey: PrefKeys.notificationReminderTimerSeconds.rawValue) > 59 {
                UIAccessibility.requestGuidedAccessSession(enabled: false, completionHandler: { enabled in
                    Task{
                        if try await LocalNotificationManager.sharedManager.requestAuthorizationForNotifications() == true {
                            LocalNotificationManager.sharedManager.sendNotification(message: "Tap to Lock")
                        }
                        UIAccessibility.requestGuidedAccessSession(enabled: true, completionHandler: { enabled in
                            postWebhookMessage(["event": "login"])
                        })
                    }
                    samActive=true
                        
                })
            }
            else {
                UIAccessibility.requestGuidedAccessSession(enabled: true, completionHandler: { enabled in
                    URLSession.shared.postLogoutMessage()
                })
            }
//                UIAccessibility.requestGuidedAccessSession(enabled: false, completionHandler: { enabled in
//                    try? await LocalNotificationManager.sharedManager.requestAuthorizationForNotifications()
//                    
//                    samActive=false
//                })
//                
//
//                Task{
//                    if await LocalNotificationManager.sharedManager.checkCurrentAuthorizationSetting() == .notDetermined {
//                        
//                    }
//                }
//            }


            loadPage=true
            readDefaults()
            updatePrefsFromManagedPrefs()
            if let discoveryURL = UserDefaults.standard.value(forKey: PrefKeys.discoveryURL.rawValue) as? String, discoveryURL.isEmpty == false {
                showWebLogin=true
            }
            guard let wifiNetworksFromPrefs = UserDefaults.standard.array(forKey: PrefKeys.wifiNetworks.rawValue) as? Array<Dictionary<String,String>> else {
                return
            }
            for wifiNetworkFromPrefs in wifiNetworksFromPrefs {
                if let networkName = wifiNetworkFromPrefs["ssid"], let networkPassword = wifiNetworkFromPrefs["wifiPassword"]{
                    self.wifiNetworks.append(WifiNetwork(name: networkName, password: networkPassword))
                }
            }
        }
        
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                print("Active")
                //                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { // Change `2.0` to the desired number of seconds.
                UIAccessibility.requestGuidedAccessSession(enabled: true, completionHandler: { enabled in
                    samActive=true
                    webView.loadPage()
                    postWebhookMessage(["event": "logout"])
                })
                loadPage=true
            } else {
                webView.loadPage()
                let notificationTimer = UserDefaults.standard.integer(forKey: PrefKeys.notificationReminderTimerSeconds.rawValue)

                LocalNotificationManager().sendNotification(message: "Tap to Lock", repeatSeconds: notificationTimer>29 ? notificationTimer:0)

//                timer?.invalidate()
//                timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { _ in
//                    Task { @MainActor in
//                        UIAccessibility.requestGuidedAccessSession(enabled: true) { success in
//                                print("Requested Single App Mode: \(success)")
//                            }
//                    }
//                }

            }
//            } else if newPhase == .inactive {
//                print("Inactive")
//            }
//            
//            else if newPhase == .background {
//                print("Background")
//            }
        }
        
    }
}
