//
//  WebView.swift
//  xCreds
//
//  Created by Timothy Perfitt on 4/5/22.
//

import Foundation
@preconcurrency import WebKit
import OIDCLite
import SwiftUI
@available(macOS, deprecated: 11)


class WebView:WKWebView, TokenManagerFeedbackDelegate {
    func invalidCredentials() {
        
    }
    
    
//    var webView:WKWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
    struct WebViewControllerError:Error {

        var errorDescription: String

    }
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        tokenManager.feedbackDelegate=self
//        self.loadPage()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    

    func showLoginSuccessful(){
        UIAccessibility.requestGuidedAccessSession(enabled: false, completionHandler: {_ in
        
            if UserDefaults.standard.bool(forKey: PrefKeys.shouldExitOnSuccessfulAuth.rawValue){
                exit(0);
            }
            else if let filePath = Bundle.main.url(forResource: "swipe_up", withExtension: "html"),
                   let html = try? String(contentsOf: filePath, encoding: .utf8){
                    
                    self.loadHTMLString(html, baseURL: nil)
                
            }
            else {
                self.loadPage()
                
            }
            
        })
    }
    func credentialsUpdated(_ credentials: Creds) {
        TCSLogWithMark()
        var credWithPass = credentials
        credWithPass.password = self.password
        
        if  let idTokenInfo = try? tokenManager.tokenInfo(fromCredentials: credentials), let idTokenObject = idTokenInfo["idToken"] as? IDToken {

            credWithPass.username = idTokenObject.email
        }
        let encoder = PropertyListEncoder()
        
        guard let data = try? encoder.encode(credWithPass) else {
            return
        }

        try? KeychainUtil().storeDataInKeychain(account: "xcreds-mobile", service: "xcreds-mobile", data:data , group:"UXP6YEHSPW.com.twocanoes.xcreds-mobile")
 
        showLoginSuccessful()
//        NotificationCenter.default.post(name: Notification.Name("TCSTokensUpdated"), object: self, userInfo:["credentials":credWithPass]
//                       )

//        updateCredentialsFeedbackDelegate?.credentialsUpdated(credWithPass)
    }
//  
//    @IBOutlet weak var refreshTitleTextField: NSTextField?
//    @IBOutlet weak var cancelButton: NSButton!
//    @available(macOS, deprecated: 11)
    var tokenManager=TokenManager()
    
    var password:String?
//    var updateCredentialsFeedbackDelegate: UpdateCredentialsFeedbackProtocol?

//    override func viewWillAppear() {
//        if let refreshTitleTextField = self.refreshTitleTextField {
//            refreshTitleTextField.isHidden = !UserDefaults.standard.bool(forKey: PrefKeys.shouldShowRefreshBanner.rawValue)
//
//
//            if let refreshBannerText = UserDefaults.standard.string(forKey: PrefKeys.refreshBannerText.rawValue) {
//                self.refreshTitleTextField?.stringValue = refreshBannerText
//            }
//
//        }
//
//    }
    func loadPage() {
        Task{ @MainActor in
            TCSLogWithMark("Clearing cookies")
            self.cleanAllCookies()
            TCSLogWithMark()

            self.navigationDelegate = self
            self.clearCookies()
            TCSLogWithMark()
           
            self.navigationDelegate = self
            TCSLogWithMark("Network monitor: adding connectivity status change observer")

            do {
                
                self.customUserAgent = "Mozilla/5.0 (iPad; CPU OS 18_7_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Mobile/15E148 Safari/604.1"
                let url = try await self.getOidcLoginURL()
                TCSLogWithMark("URL: \(url)");

                self.load(URLRequest(url: url))
//                NetworkMonitor.shared.stopMonitoring()
            }
            catch {
                TCSLogWithMark("error: \(error)");

                let loadPageTitle = UserDefaults.standard.string(forKey: PrefKeys.loadPageTitle.rawValue)?.stripped ?? "loadPageTitle"

                let loadPageInfoFromPrefs = UserDefaults.standard.string(forKey: PrefKeys.loadPageInfo.rawValue)?.stripped ?? "loadPageInfo"


               let  loadPageInfo = loadPageInfoFromPrefs + "<br><br>" + (error as? WebViewControllerError ?? WebViewControllerError(errorDescription: error.localizedDescription)).errorDescription

                var html = "<!DOCTYPE html><html><head><style>.center-screen { display: flex;flex-direction: column;justify-content: center;align-items: center;text-align: center;min-height: 100vh;}</style></head><body><div class=\"center-screen\"> <h1>\(loadPageTitle)</h1><p>\(loadPageInfo)</p></div></body></html>"

                
                let defaultsPath = Bundle(for: type(of: self)).path(forResource: "defaults", ofType: "plist")

                //if the user has not modified the screen, then we use our fancy new one.
                if let defaultsPath = defaultsPath,
                    let defaultsDict = NSDictionary(contentsOfFile: defaultsPath) as? Dictionary<String, Any>,
                   let defaultsPageTitle=defaultsDict["loadPageTitle"] as? String, defaultsPageTitle==loadPageTitle,
                   let defaultsPageInfo=defaultsDict["loadPageInfo"] as? String,
                    defaultsPageInfo==loadPageInfoFromPrefs{
                        
                        html = """
                <html>
                  <head>
                    <title>XCreds Network Loading</title>
                    <style>
                      body {
                        font-family: sans-serif;
                        background-image: linear-gradient(rgba(153, 202, 248, 0.65), rgba(255, 255, 255, 1));
                        position: relative;
                      }
                      .center-screen {
                        text-align: center;
                        background: #ffffff;
                        display: table;
                        margin: 0 auto;
                        padding: 1em;
                        border-radius: 1.4em;
                        position: absolute;
                        top: 30%;
                        transform: translate(-50%);
                        left: 50%;
                      }

                      .fade-element {
                        opacity: 0;
                        animation-name: fadeIn;
                        animation-duration: 2s;
                        animation-delay: 2s;
                        animation-fill-mode: forwards;
                      }

                      @keyframes fadeIn {
                        from {
                          opacity: 0;
                        }
                        to {
                          opacity: 1;
                      }

                      .readable {
                        max-width: 32em;
                      }
                    </style>
                  </head>
                  <body>
                    <div class="center-screen">
                      <h1>One Moment...</h1>
                      <p class="readable fade-element" style="animation-delay: 2s;">Please wait one moment to check for a network connection.</p>
                      <p class="readable fade-element" style="animation-delay: 6s;">Sometimes it takes a few seconds to confirm that network access is available.</p>
                      <p style="animation-delay: 10s;" class="readable fade-element">If this page does not reload in a few seconds with the login screen, please check the network connection.</p>
                      <p style="animation-delay: 20s; font-weight: bold; font-size: 1.5em" class="readable fade-element">Ok it may be best to check the network connection now.</p>
                    </div>
                  </body>
                </html>
"""
                    }
                
                loadHTMLString("html", baseURL: nil)

            }
        }
    }

//    @objc func connectivityStatusHandler(notification: Notification) {
//        TCSLogWithMark("Network monitor: handling connectivity status update")
//
//        Task {
//            try? await tokenManager.oidc().getEndpoints()
//            TCSLogWithMark("Refresh webview login")
//            loadPage()
//        }
//    }
//


    private func getOidcLoginURL() async throws -> URL {
        if let url = try await tokenManager.oidc().createLoginURL() {
            return url
        }
        throw WebViewControllerError(errorDescription: "Error getting OIDC URL")
    }



    private func clearCookies() {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                                 for: records,
                                 completionHandler: {
                print("Removing Cookie")
            })
        }

        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
   
    func showErrorMessageAndDeny(_ message:String){
    }
    func tokenError(_ err: String) {
        TCSLogErrorWithMark("authFailure: \(err)")
//        XCredsAudit().auditError(err)

        //TODO: need to post this?
        NotificationCenter.default.post(name: Notification.Name("TCSTokensUpdated"), object: self, userInfo:["error":err])

    }
}
@available(macOS, deprecated: 11)
extension WebView: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        let idpHostName = UserDefaults.standard.value(forKey: PrefKeys.idpHostName.rawValue)
        var idpHostNames = UserDefaults.standard.value(forKey: PrefKeys.idpHostNames.rawValue)

        if idpHostNames == nil && idpHostName != nil {
            idpHostNames=[idpHostName]
        }
        let passwordElementID:String? = UserDefaults.standard.value(forKey: PrefKeys.passwordElementID.rawValue) as? String

        TCSLogWithMark("inserting javascript to get password")
        webView.evaluateJavaScript("result", completionHandler: { response, error in
            if error != nil {
//                TCSLogWithMark(error?.localizedDescription ?? "unknown error")
                TCSLogWithMark("password not found")
            }
            else {
                if let responseDict = response as? NSDictionary, let ids = responseDict["ids"] as? Array<String>, let passwords = responseDict["passwords"] as? Array<String> {
                    
                    guard passwords.count > 0 else {
                        TCSLogWithMark("No passwords set")
                        return
                        
                    }

                    TCSLogWithMark("found password elements with ids:\(ids)")

                    guard let host = navigationAction.request.url?.host else {

                        return
                    }
                    var foundHostname = ""
                    if  let idpHostNames = idpHostNames as? Array<String?>,
                        idpHostNames.contains(host) {
                        foundHostname=host

                    }
                    else if ["login.microsoftonline.com", "login.live.com", "accounts.google.com"].contains(host) || host.contains("okta.com"){
                        foundHostname=host

                    }
                    else {
                        TCSLogWithMark("hostname (\(host)) not matched so not looking for password")
                        return
                    }

                    TCSLogWithMark("host matches custom idpHostName \(foundHostname)")


                    if passwords.count==3, passwords[1]==passwords[2] {
                        TCSLogWithMark("found 3 password fields. so it is a reset password situation")
                        TCSLogWithMark("========= password set===========")
                        self.password=passwords[2]
                    }
                    else if passwords.count==2, passwords[0]==passwords[1] {
                        TCSLogWithMark("found 2 password fields. so it is a reset password situation")
                        TCSLogWithMark("========= password set===========")
                        self.password=passwords[1]
                    }
                    else if let passwordElementID = passwordElementID{
                        TCSLogWithMark("the id is defined in prefs (\(passwordElementID)) so seeing if that field is on the page.")

                    // we have a mapped field defined in prefs so only check this.
                        if ids.count==1, ids[0]==passwordElementID, passwords.count==1 {
                            TCSLogWithMark("========= password set===========")
                            self.password=passwords[0]
                        }
                        else {

                            TCSLogWithMark("did not find a single password field on the page with the specified ID so not setting password")
                        }

                    }
                    //
                    else if passwords.count==1 {
                        TCSLogWithMark("found 1 password field on the specified page with the set idpHostName. setting password.")
                        TCSLogWithMark("========= password set===========")
                        self.password=passwords[0]

                    }
                    else {
                        TCSLogWithMark("No passwords found on page")
                    }
                }
                else {
                    
                    TCSLogWithMark("password not set")

                }
            }
        })
        decisionHandler(.allow)

    }

 
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //this inserts javascript to copy passwords to a variable. Sometimes the
        //div gets removed before we can evaluate it so this helps. It works by
        // attaching to keydown. At each keydown, it attaches to password elements
        // for keyup. When a key is released, it copies all the passwords to an array
        // to be read later.

        TCSLogWithMark("adding listener for password")
        var pathURL:URL?
        let bundle = Bundle.main
        
        TCSLogWithMark()
        pathURL = bundle.url(forResource: "get_pw", withExtension: "js")
        
        

        guard let pathURL = pathURL else {
            TCSLogErrorWithMark("get_pw.js not found")
            return
        }

        let javascript = try? String(contentsOf: pathURL, encoding: .utf8)

        guard let javascript = javascript else {
            return
        }
        webView.evaluateJavaScript(javascript, completionHandler: { response, error in
            if (error != nil){
                
                TCSLogWithMark(error?.localizedDescription ?? "unknown listener error")
                if UserDefaults.standard.bool(forKey: "reloadPageOnError")==true {
                    TCSLogWithMark("reloading page")
                    self.loadPage()
                }
            }
            else {
                TCSLogWithMark("inserted javascript for password setup")
            }
        })

    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        TCSLogErrorWithMark(error.localizedDescription)


    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        TCSLogWithMark("Redirect error. if the error is \"Could not connect to the server.\", it is probably safe to ignore. If the error is \"unsupported URL\", please check your redirectURL in prefs matches the one defined in your OIDC app. Error: \(error.localizedDescription)")
    }
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        Task{
            guard let url = webView.url else {
                return
            }
            TCSLogWithMark("WebDel:: Did Receive Redirect for: \(url.absoluteString)")

            TCSLogWithMark("URL: \(url.absoluteString)")
            let redirectURI = try await tokenManager.oidc().redirectURI
            TCSLogWithMark("URL: \(url.absoluteString)")
            TCSLogWithMark("redirectURI: \(redirectURI)")

            if (url.absoluteString.starts(with: (redirectURI))) {
                TCSLogWithMark("got redirect URI match. separating URL")
                var code = ""
                let fullCommand = url.absoluteString
                let pathParts = fullCommand.components(separatedBy: "&")
                for part in pathParts {
                    if part.contains("code=") {
                        TCSLogWithMark("found code=. cleaning up.")

                        code = part.replacingOccurrences(of: redirectURI + "?" , with: "").replacingOccurrences(of: "code=", with: "")
                        TCSLogWithMark("getting tokens")

                        
                        do {
                            let shouldUseBasicAuth = UserDefaults.standard.bool(forKey: PrefKeys.shouldUseBasicAuth.rawValue)
                            let tokenResponse = try await tokenManager.oidc().getToken(code: code, basicAuth: shouldUseBasicAuth)
                            TCSLogWithMark("got token. Token ID: \(tokenResponse.idToken ?? "" )")
                            tokenManager.tokenResponse(tokens: tokenResponse)

                        }
                        catch{
                            TCSLogWithMark("error: \(error)")
                        }

                        return
                    }
                }
            }
        }

    }

    private func queryToDict(query: String) -> [String:String]? {
        let components = query.components(separatedBy: "&")
        var dictionary = [String:String]()

        for pairs in components {
            let pair = pairs.components(separatedBy: "=")
            if pair.count == 2 {
                dictionary[pair[0]] = pair[1]
            }
        }

        if dictionary.count == 0 {
            return nil
        }

        return dictionary
    }


}

//TODO: Integrate?
//extension WebViewController: OIDCLiteDelegate {
//
////    func authFailure(message: String) {
////        TCSLogErrorWithMark("authFailure: \(message)")
////        NotificationCenter.default.post(name: Notification.Name("TCSTokensUpdated"), object: self, userInfo:[:])
////
////    }
//
//
//}
extension String {
    func sanitized() -> String {
        // see for ressoning on charachrer sets https://superuser.com/a/358861
        let invalidCharacters = CharacterSet(charactersIn: "\\/:*?\"<>| ")
            .union(.newlines)
            .union(.illegalCharacters)
            .union(.controlCharacters)

        return self
            .components(separatedBy: invalidCharacters)
            .joined(separator: "")
    }

    mutating func sanitize() -> Void {
        self = self.sanitized()
    }
}
extension WKWebView {

    func cleanAllCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        print("All cookies deleted")

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("Cookie ::: \(record) deleted")
            }
        }
    }

    func refreshCookies() {
        self.configuration.processPool = WKProcessPool()
    }
   

}
