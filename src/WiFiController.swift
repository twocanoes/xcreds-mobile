//
//  WiFiController.swift
//  XCreds Mobile
//
//  Created by Timothy Perfitt on 3/16/26.
//

import NetworkExtension


struct WifiNetwork: Identifiable, Hashable{
    let name: String
    let password:String
    let id = UUID()
}
class WiFiController{
    static let shared = WiFiController()
    func setupNetwork(_ wifiNetwork:WifiNetwork, complete:@escaping((Bool)->Void)){
        
        let hotspotConfig = NEHotspotConfiguration(ssid: wifiNetwork.name, passphrase: wifiNetwork.password, isWEP: false)//Secured connections
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
