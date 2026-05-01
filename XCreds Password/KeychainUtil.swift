//
//  KeychainUtil.swift
//  Tapgo
//
//  Created by Timothy Perfitt on 12/15/25.
//

import CoreFoundation
import Security
import Foundation
struct Credentials {
    var username: String
    var password: String
}
enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

class KeychainUtil {
    
    
    func findPasswordItemInKeychain(account:String, service:String, group:String?=nil) throws -> CFTypeRef{
        var query: [String: Any]
        if let group = group {
            query = [kSecClass as String: kSecClassGenericPassword,
                                        kSecAttrService as String: service,
                                        kSecMatchLimit as String: kSecMatchLimitOne,
                                        kSecAttrAccessGroup as String: group,
                                        kSecReturnAttributes as String: false,
                                        kSecReturnData as String: true]

        }
        else {
            query = [kSecClass as String: kSecClassGenericPassword,
                                        kSecAttrService as String: service,
                                        kSecMatchLimit as String: kSecMatchLimitOne,
                                        kSecReturnAttributes as String: false,
                                        kSecReturnData as String: true]

        }
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else {
            throw KeychainError.noPassword
        }
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
        
        guard let item = item else {
            throw KeychainError.unhandledError(status: status)

        }
        return item
        
    }
    func findDataInKeychain(account:String, service:String, group:String?=nil) throws -> Data {
        var item:CFTypeRef
        item = try findPasswordItemInKeychain(account: account, service: service, group:group)

        guard let existingItem = item as?  Data
        else {
            throw KeychainError.unexpectedPasswordData
        }
        
        return existingItem
    }
    
    func removeItemInKeychain(account:String, service:String,group:String?=nil) throws {
        var query: [String: Any]
        
        if let group = group {
            
            query = [kSecClass as String: kSecClassGenericPassword,
                     kSecAttrAccessGroup as String: group,
                     kSecAttrService as String: service]
        }
        else {
            query = [kSecClass as String: kSecClassGenericPassword,
                     kSecAttrService as String: service]

        }

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }


        
    }
    
    func storeDataInKeychain(account:String, service:String, data:Data, group:String?=nil) throws  {
        var query: [String: Any]
        try removeItemInKeychain(account: account, service: service, group:group)
        if let group = group {
            query = [kSecClass as String: kSecClassGenericPassword,
                     kSecAttrSynchronizable as String: false,
                     kSecAttrAccount as String: account,
                     kSecAttrService as String: service,
                     kSecAttrAccessGroup as String: group,
                     kSecValueData as String: data]
        }
        else {
            query = [kSecClass as String: kSecClassGenericPassword,
                     kSecAttrSynchronizable as String: false,
                     kSecAttrAccount as String: account,
                     kSecAttrService as String: service,
                     kSecValueData as String: data]

        }

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }

    }
}
