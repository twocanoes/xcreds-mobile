//
//  LoginWebView.swift
//  Ease
//
//  Created by Timothy Perfitt on 1/25/26.
//

import SwiftUI
import WebKit

protocol LoginWebViewDelegate {
    func loggedIn(credentials: Creds?)
}

struct LoginWebView: UIViewRepresentable, LoginWebViewDelegate{
    func loggedIn(credentials:Creds?) {
        self.credentials = credentials
        isLoggedIn=true
    }
    
    typealias UIViewType = WebView
    @Binding var webView:WebView
    @Binding var loadPage:Bool
    @Binding var resetOIDC:Bool
    @Binding var isLoggedIn:Bool
    @Binding var credentials:Creds?

    func makeUIView(context: Context) -> WebView {
        
        return webView
    }
    
    func updateUIView(_ uiView: WebView, context: Context) {
        webView.delegate=self
        readDefaults()

        updatePrefsFromManagedPrefs()
        
        if resetOIDC==true {
            isLoggedIn=false
            webView.tokenManager.resetOIDC()
        }
            if loadPage==true{
                webView.loadPage()
                DispatchQueue.main.async { loadPage = false }
        }
    }
    
    
    func makeCoordinator() -> Coordinator {
           return Coordinator()
       }

}


class MyCoordinator {
    @Binding var loadPage: Bool

    init(loadPage: Binding<Bool>) {
        self._loadPage = loadPage
    }
    
}
