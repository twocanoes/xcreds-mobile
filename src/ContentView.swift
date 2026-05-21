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

enum WebhookEvent: String {
    case login = "xcreds-mobile.login"
    case logout = "xcreds-mobile.logout"
}

struct ContentView: View {
    @State var optionsSheetIsPresented = false
    
    @State var timer:Timer?
    @State var webView = WebView()
    @State var username:String=""
    @State var password:String=""
    @State var samActive = false
    @State var isWebLoginConfigured = false
    @State var resetOIDC = false
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @State var loadPage:Bool
    @Environment(\.authorizationController) private var authorizationController
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showingPopover = false
    @State private var showingWifiPopover = false
    @State private var wifiNetworks:[WifiNetwork] = []
    @State private var isLoggedIn:Bool = false
    @State private var credentials:Creds?  = nil
    @State private var wifiSelection:WifiNetwork?
    @AppStorage(PrefKeys.webHookAuthToken.rawValue) var webHookAuthToken: String?
    @AppStorage(PrefKeys.webHookURLString.rawValue) var webHookURLString: String?
    
    
    let currentDate = Date()
    
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
    //    fileprivate func LocalLoginView() -> ZStack<TupleView<(some View, some View)>> {
    //        return ZStack{
    //            Image("DefaultAerial")
    //                .resizable()
    //                .scaledToFill()
    //                .frame(minWidth: 0)
    //                .edgesIgnoringSafeArea(.all)
    //
    //            VStack {
    //
    //                if samActive==false {
    //
    //                    Text("Single App Mode Not Enabled")
    //                        .font(.title)
    //                        .bold()
    //                        .foregroundStyle(.red)
    //                        .padding(.top)
    //                }
    //                Text(dateFormatter.string(from: currentDate))
    //                    .font(.system(size: 28))
    //                    .foregroundColor(.white)
    //                    .opacity(0.5)
    //                    .bold()
    //                    .padding(.top, 80)
    //                Text(timeFormatter.string(from: currentDate))
    //                    .font(.system(size: 110))
    //                    .foregroundColor(.white)
    //                    .opacity(0.5)
    //                    .bold()
    //                    .frame(height:60)
    //                Spacer()
    //
    //                TextField("Username", text: $username, prompt: Text("Username").foregroundColor(.black))
    //                    .font(.system(size: 14))
    //                    .padding(.leading, 15)
    //                    .frame(width: 200, height:30)
    //                    .background(.regularMaterial)
    //                    .cornerRadius(20)
    //                    .autocorrectionDisabled(true)
    //
    //                SecureField("Password", text: $password, prompt: Text("Enter Password").foregroundColor(.black))
    //                    .textContentType(.none)
    //                    .autocorrectionDisabled(true)
    //
    //                    .font(.system(size: 14))
    //                    .padding(.leading, 15)
    //                    .frame(width: 200, height:30)
    //                    .background(.regularMaterial)
    //                    .cornerRadius(20)
    //
    //                    .onSubmit {
    //                        loggedIn=true
    //                        UIAccessibility.requestGuidedAccessSession(enabled: false, completionHandler: { enabled in
    //                            samActive=false
    //                            TCSLogDebugWithMark("\(#file):\(#line) - \("Login webhook called in \(#function)")")
    //                            postWebhookEvent(.login)
    //                        })
    //                    }
    //
    //
    //
    //
    //            }
    //            .padding(.bottom,50)
    //
    //        }
    //
    //    }
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
    func postWebhookEvent(_ event: WebhookEvent) {
        var payload: [String: String] = [
            "event": event.rawValue,
            "time": Date.now.ISO8601Format()
        ]
        if let creds = try? Creds.fromKeychain(),
           let info = try? TokenManager.webhookPayloadFromCredentials(creds) {
            payload.merge(info) { $1 }
        }
        else {
            TCSLogWithMark("No user info found in keychain. Skipping webhook.")
            return
        }
        if let token = webHookAuthToken,
           let urlString = webHookURLString,
           let webHookURL = URL(string: urlString) {
            URLSession.shared.postWebHook(url: webHookURL, token: token, payload: payload)
        }
    }
    
    var body: some View {
        
        VStack {
            ZStack{
                
                if let imageURLString = UserDefaults.standard.value(forKey: PrefKeys.loginWindowBackgroundImageURL.rawValue) as? String,
                   let imageURL = URL(string: imageURLString){
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable(resizingMode: .stretch)
                            .ignoresSafeArea()
                    } placeholder: {}
                    
                }
                
                VStack{
                    if UserDefaults.standard.string(forKey: PrefKeys.discoveryURL.rawValue) == nil {
                        
                        Text("No configuration detected. Please install a configuration profile." )
                            .font(.title)
                            .foregroundStyle(.red)
                    }
                    let width = CGFloat(UserDefaults.standard.float(forKey: PrefKeys.loginWindowWidth.rawValue))
                    let height = CGFloat(UserDefaults.standard.float(forKey: PrefKeys.loginWindowHeight.rawValue))
                    
                    if isLoggedIn == false {
                        LoginWebView(webView:$webView, loadPage:$loadPage, resetOIDC: $resetOIDC, isLoggedIn: $isLoggedIn, credentials: $credentials )
                            .refreshable{
                                webView.loadPage()
                                
                            }
                            .frame(width: width > 150 ? width: nil,height: height > 150 ? height: nil)
                            .ignoresSafeArea()
                    }
                    else {
                        Text("OIDC ID Token")
                        if let credentials = credentials,
                            let dict = credentials.dictionary,
                            let idToken = dict["idToken"] as? IDToken {
                            
                            List{
                                IDTokenPrint(key: "email", value: idToken.email ?? "")
                                IDTokenPrint(key: "sub", value: idToken.sub)
                                IDTokenPrint(key: "iss", value: idToken.iss )
                                switch idToken.aud {
                                case .string(let string):
                                    IDTokenPrint(key: "aud", value:  string)

                                case .array(let array):
                                    IDTokenPrint(key: "aud", value:  array.description)

                                }
                                IDTokenPrint(key: "iat", value: "\(idToken.iat)" )
                                IDTokenPrint(key: "exp", value: "\(idToken.exp)" )
                                IDTokenPrint(key: "unique_name", value: idToken.unique_name ?? "" )
                                IDTokenPrint(key: "given_name", value: idToken.given_name ?? "" )
                                IDTokenPrint(key: "family_name", value: idToken.family_name ?? "" )
                                IDTokenPrint(key: "name", value: idToken.name ?? "" )

                            }

                        }
                    }
                }
                VStack{
                    
                    Spacer()
                    
                    HStack {
                        if UserDefaults.standard.bool(forKey: PrefKeys.shouldShowSystemInfoButton.rawValue)==true{
                            
                            Button(UserDefaults.standard.string(forKey: PrefKeys.systemInfoButtonTitle.rawValue) ?? "System Info") {
                                UNUserNotificationCenter
                                    .current()
                                    .requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
                                
                                showingPopover = true
                                
                                
                                
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
                                    Text("Thanks to North Carolina State University and Everette Allen for funding the initial development of XCreds Mobile.")
                                        .font(.footnote)
                                        .italic()
                                        .frame(width: 250)
                                        .padding([.top])
                                }
                                .padding()
                                
                            }
                            .padding()
                        }
                        
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
                            
                        } content: {
                            OptionsSheet(optionsSheetIsPresented: $optionsSheetIsPresented)
                        }
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(",")
                        .labelStyle(.iconOnly)
                        .padding()
                        
                        
                        
                        if wifiNetworks.count>0{
                            Button("Wi-Fi"){
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
                            isLoggedIn=false
                            webView.loadPage()
                        }
                        .padding()
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                
                
                
            }
            
        }
        
        .onChange(of: optionsSheetIsPresented, { oldValue, newValue in
            if newValue==false {
                webView.loadPage()
            }
        })
        .onAppear(){
            readDefaults()
            if UserDefaults.standard.bool(forKey: PrefKeys.shouldActivateSystemInfoButton.rawValue)==true{
                showingPopover = true
            }
            
            if UserDefaults.standard.integer(forKey: PrefKeys.notificationReminderTimerSeconds.rawValue) > 59 {
                UIAccessibility.requestGuidedAccessSession(enabled: false, completionHandler: { enabled in
                    Task{
                        if try await LocalNotificationManager.sharedManager.requestAuthorizationForNotifications() == true {
                        }
                        UIAccessibility.requestGuidedAccessSession(enabled: true, completionHandler: { enabled in
                            postWebhookEvent(.login)
                        })
                    }
                    samActive=true
                    
                })
            }
            else {
                UIAccessibility.requestGuidedAccessSession(enabled: true, completionHandler: { enabled in
                    //                    let data = try? KeychainUtil().findDataInKeychain(account: "xcreds-mobile", service: "xcreds-mobile", group: "UXP6YEHSPW.com.twocanoes.xcreds-mobile")
                    //                    let info = TokenManager()
                    TCSLogDebugWithMark("\(#file):\(#line) - \("Login webhook called in \(#function)")")
                    postWebhookEvent(.login)
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
                isWebLoginConfigured=true
            }
            else {
                optionsSheetIsPresented=true
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
            switch (oldPhase, newPhase) {
            case (_, .active):
                print("Active")
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                UIAccessibility.requestGuidedAccessSession(enabled: true, completionHandler: { enabled in
                    samActive=true
                    webView.loadPage()
                    TCSLogDebugWithMark("\(#file):\(#line) - Logout webhook called on scene phase change to active")
                    TCSLogDebugWithMark("This might be the first session on startup.")
                    postWebhookEvent(.logout)
                    try? KeychainUtil().removeItemInKeychain(account: "xcreds-mobile", service: "xcreds-mobile", group:"UXP6YEHSPW.com.twocanoes.xcreds-mobile")
                })
                loadPage=true
                webView.loadPage()
            case (_, .background):
                
                break
            default:
                TCSLogDebugWithMark("Ignoring phase change from \(oldPhase) to \(newPhase)")
            }
        }
        
    }
}

extension Creds {
    var token: IDToken? {
        guard let tokenString = idToken,
              let data = try? TokenManager().idTokenData(jwtString: tokenString) else { return nil }
        return try? JSONDecoder().decode(IDToken.self, from: data)
    }
    var dictionary: [String: Any]? {
        return try? TokenManager().tokenInfo(fromCredentials: self)
    }
}

extension IDToken:Identifiable {
    var id:String{
        return sub
    }
}
struct IDTokenPrint: View {
    let key: String
    let value: String

    var body: some View {
        HStack {
            Text(key)
                .font(.headline)

            Spacer()

            Text(value)
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}
