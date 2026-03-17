//
//  LoginWebView.swift
//  Ease
//
//  Created by Timothy Perfitt on 1/25/26.
//

import SwiftUI
import WebKit


struct LoginWebView: UIViewRepresentable {
    typealias UIViewType = WebView
    @Binding var webView:WebView
    @Binding var loadPage:Bool
    @Binding var resetOIDC:Bool
      
    func makeUIView(context: Context) -> WebView {
        
        return webView
    }
    
    func updateUIView(_ uiView: WebView, context: Context) {
        
        updatePrefsFromManagedPrefs()
        
        if resetOIDC==true {
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
