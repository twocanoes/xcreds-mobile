//
//  WiFiController.swift
//  XCreds Mobile
//
//  Created by Timothy Perfitt on 3/16/26.
//

import NetworkExtension

class WiFiController{
    static let shared = WiFiController()
    func setupNetwork( complete:@escaping((Bool)->Void)){
        
        guard let ssid = UserDefaults.standard.string(forKey: PrefKeys.ssid.rawValue), let password = UserDefaults.standard.string(forKey: PrefKeys.wifiPassword.rawValue) else {
            return
        }
        
        let hotspotConfig = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: false)//Secured connections
        print(hotspotConfig)
        NEHotspotConfigurationManager.shared.apply(hotspotConfig) {  error in
           if let error = error {
              print("error = ",error)
           }
           else {
              print("Success!")
           }
            complete(true)
        }

        
    }
}
