//
//  LoginWindowApp.swift
//  LoginWindow
//
//  Created by Timothy Perfitt on 1/24/26.
//

import SwiftUI

@main
struct XCredsMobileApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
