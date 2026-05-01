//
//  CredentialProviderViewController.swift
//  XCreds Password
//
//  Created by Timothy Perfitt on 4/30/26.
//

import AuthenticationServices

class CredentialProviderViewController: ASCredentialProviderViewController {
    
    /*
     Prepare your UI to list available credentials for the user to choose from. The items in
     'serviceIdentifiers' describe the service the user is logging in to, so your extension can
     prioritize the most relevant credentials in the list.
     */
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
    }
    
    /*
     Implement this method if your extension supports showing credentials in the QuickType bar.
     When the user selects a credential from your app, this method will be called with the
     ASPasswordCredentialIdentity your app has previously saved to the ASCredentialIdentityStore.
     Provide the password by completing the extension request with the associated ASPasswordCredential.
     If using the credential would require showing custom UI for authenticating the user, cancel
     the request with error code ASExtensionError.userInteractionRequired.
     
     override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
     let databaseIsUnlocked = true
     if (databaseIsUnlocked) {
     let passwordCredential = ASPasswordCredential(user: "j_appleseed", password: "apple1234")
     self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
     } else {
     self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code:ASExtensionError.userInteractionRequired.rawValue))
     }
     }
     */
    
    /*
     Implement this method if provideCredentialWithoutUserInteraction(for:) can fail with
     ASExtensionError.userInteractionRequired. In this case, the system may present your extension's
     UI and call this method. Show appropriate UI for authenticating the user then provide the password
     by completing the extension request with the associated ASPasswordCredential.
     
     override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
     }
     */
    
    @IBAction func cancel(_ sender: AnyObject?) {
        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
    }
    
    @IBAction func passwordSelected(_ sender: AnyObject?) {
        //        let passwordCredential = ASPasswordCredential(user: "j_appleseed", password: "apple1234")
        //        self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
        
        
        
        let passwordItem = try? KeychainUtil().findDataInKeychain(account: "xcreds-mobile", service: "xcreds-mobile", group: "UXP6YEHSPW.com.twocanoes.xcreds-mobile")
        
        
        guard let passwordItem = passwordItem  else {
            self.extensionContext.cancelRequest(withError: NSError(domain: "none", code: -1))
            
            return
        }
        
        let decoder = PropertyListDecoder()
        
        guard let credential = try? decoder.decode(Creds.self, from: passwordItem), let username = credential.username, let password = credential.password else {
            self.extensionContext.cancelRequest(withError: NSError(domain: "none", code: -1))
            
            return
            
        }
        let passwordCredential = ASPasswordCredential(user: username, password: password)
        
        
        self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
        
    }
    
}
