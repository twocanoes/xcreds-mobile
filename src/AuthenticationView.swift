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

struct AuthenticationView: View {

    @Binding var discoveryURL: String
    @Binding var clientID: String
    @Binding var clientSecret: String
    @Binding var settingsURL: String
    @Binding var redirectURI: String

    @State private var loadPage: Bool = false
    @State private var optionsSheetIsPresented = false
    @State private var timer:Timer?
    @State private var webView = WebView()
    @State private var username:String=""
    @State private var password:String=""
    @State private var samActive = false
    @State private var isWebLoginConfigured = false
    @State private var resetOIDC = false
    @State private var showingPopover = false
    @State private var showingWifiPopover = false
    @State private var wifiNetworks:[WifiNetwork] = []
    @State private var isLoggedIn:Bool = false
    @State private var credentials:Creds?  = nil
    @State private var wifiSelection:WifiNetwork?
    @State private var licenseState:LicenseChecker.LicenseState?

    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @Environment(\.authorizationController) private var authorizationController
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage(PrefKeys.webHookAuthToken.rawValue) var webHookAuthToken: String?
    @AppStorage(PrefKeys.webHookURLString.rawValue) var webHookURLString: String?
    @AppStorage(PrefKeys.license.rawValue) var license: Data?
    
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
    
    fileprivate func LoginWindow() -> some View {
        let width = CGFloat(UserDefaults.standard.float(forKey: PrefKeys.loginWindowWidth.rawValue))
        let height = CGFloat(UserDefaults.standard.float(forKey: PrefKeys.loginWindowHeight.rawValue))

        return LoginWebView(webView:$webView, loadPage:$loadPage, resetOIDC: $resetOIDC, isLoggedIn: $isLoggedIn, credentials: $credentials )
            .refreshable{
                webView.loadPage()
                
            }
            .frame(width: width > 150 ? width: nil,height: height > 150 ? height: nil)
            .ignoresSafeArea()
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

                    if let licenseState = licenseState{
                        switch licenseState{
                            
                        case .valid(expires: let expires):
                            if expires<15{
                                Text("License key will expired in \(expires) days." )
                                    .font(.title)
                                    .foregroundStyle(.red)
                            }
                            
                            if isLoggedIn == false {
                                LoginWindow()
                            }
                        case .invalid:
                            VStack{}

                        case .trial(expires: let expires):
                            if expires<15{
                                Text("Trial will expire in \(expires) days." )
                                    .font(.title)
                                    .foregroundStyle(.red)
                            }
                            if isLoggedIn == false {
                                LoginWindow()
                            }

                        case .trialExpired, .expired:
                            Text("License key expired." )
                                .font(.title)
                                .foregroundStyle(.red)
                        
                        @unknown default:
                            Text("License key expired." )
                                .font(.title)
                                .foregroundStyle(.red)

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
                        if UserDefaults.standard.bool(forKey: PrefKeys.shouldShowSettingsButton.rawValue)==true{
                            Spacer()
                            
                        }
                        
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
            
           
            //verify license
            
            licenseState = LicenseChecker.currentLicenseState(bundleID: Bundle.main.bundleIdentifier ?? "")
                
           
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
            loadPage=true
            readDefaults()
            updatePrefsFromManagedPrefs()
            if discoveryURL.isEmpty == false {
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
