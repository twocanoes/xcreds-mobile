//
//  RootView.swift
//  XCreds Mobile
//
//  Created by Steve Brokaw on 8/21/26.
//

import SwiftUI

struct RootView: View {
    @AppStorage(PrefKeys.discoveryURL.rawValue) 
    var discoveryURL: String = ""
    @AppStorage(PrefKeys.clientSecret.rawValue) 
    var clientSecret: String = ""
    @AppStorage(PrefKeys.clientID.rawValue)
    var clientID: String = ""
    @AppStorage(PrefKeys.scopes.rawValue) 
    var scopes: String = ""
    @AppStorage("settingsURL") 
    var settingsURL: String = ""
    @AppStorage(PrefKeys.redirectURI.rawValue) 
    var redirectURI:String = ""

    var body: some View {
        if showAuthentication {
            AuthenticationView(
                discoveryURL: $discoveryURL,
                clientID: $clientID,
                clientSecret: $clientSecret,
                settingsURL: $settingsURL,
                redirectURI: $redirectURI
            )
        }
        else {
            InspectorView()
        }
    }
    var showAuthentication: Bool {
        return !discoveryURL.isEmpty &&
            !clientSecret.isEmpty &&
            !redirectURI.isEmpty
    }
}

#Preview {
    RootView()
}
