//
//  Untitled.swift
//  XCreds Mobile
//
//  Created by Timothy Perfitt on 9/13/26.
//

import UIKit
import ProductLicense
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Task{
            await VersionCheck.shared.reportUsage()
        }
        
        return true
    }
    
}
