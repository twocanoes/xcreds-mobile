//
//  LocalNotificationManager.swift
//  Smart Card Utility
//
//  Created by Timothy Perfitt on 4/16/21.
//  Copyright © 2021 Twocanoes Software. All rights reserved.
//

#if canImport(AppKit)
import AppKit

#endif
import UserNotifications

@objc class LocalNotificationManager: NSObject {
    
    
    @objc public static let sharedManager = LocalNotificationManager()
    

    @objc public func sendNotification(message:String, isDebug:Bool=false, repeatSeconds:Int = 0) {
        
        
        Task {
            do {
                let _ = try await requestAuthorizationForNotifications()
            } catch {
                print(error.localizedDescription)
            }
        }
        
        let content = UNMutableNotificationContent()
        
        content.title = "XCreds Mobile"
        
        content.body = message
        if repeatSeconds > 10 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(repeatSeconds), repeats: repeatSeconds > 60)
            // choose a random identifier
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            // add our notification request
            UNUserNotificationCenter.current().add(request)

        }
        
        
    }
    func requestAuthorizationForNotifications() async throws -> Bool {
        let notificationCenter = UNUserNotificationCenter.current()
        let authorizationOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        do {
            let authorizationGranted = try await notificationCenter.requestAuthorization(options: authorizationOptions)
            return authorizationGranted
        } catch {
            throw error
        }
    }
    func checkCurrentAuthorizationSetting() async  -> UNAuthorizationStatus {
        let notificationCenter = UNUserNotificationCenter.current()

        let currentSettings = await notificationCenter.notificationSettings()
//        switch currentSettings.authorizationStatus {
//        case .authorized:
//            break
//        case .denied:
//            break
//        case .ephemeral:
//            break
//        case .notDetermined:
//            break
//        case .provisional:
//            break
//        @unknown default:
//            fatalError()
//        }
        return currentSettings.authorizationStatus
    }
}
