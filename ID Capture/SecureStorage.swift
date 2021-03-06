//
//  SecureStorage.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 02/01/2020.
//  Copyright © 2020 Applied Recognition Inc. All rights reserved.
//

import Foundation
import CommonCrypto

class SecureStorage {
    
    private static let keyPrefix = "com.appliedrec."
    
    enum commonKeys: String {
        case intellicheckPassword
    }
    
    static func setString(_ string: String, forKey key: String) throws {
        guard let value = string.data(using: .utf8) else {
            throw NSError()
        }
        let account = keyPrefix + key
        let attributes: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account as CFString,
            kSecValueData: value as CFData
        ]
        var status = SecItemAdd(attributes as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let toUpdate: [CFString: CFData] = [
                kSecValueData: value as CFData
            ]
            status = SecItemUpdate(attributes as CFDictionary, toUpdate as CFDictionary)
            if status != errSecSuccess {
                throw NSError()
            }
        } else if status != errSecSuccess {
            throw NSError()
        }
    }
    
    static func getString(forKey key: String) throws -> String? {
        let account = keyPrefix + key
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account as CFString,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: true
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess, let data = item as? Data, let value = String(data: data, encoding: .utf8) {
            return value
        } else if status == errSecItemNotFound {
            return nil
        }
        throw NSError()
    }
    
    static func deleteValue(forKey key: String) throws {
        let account = keyPrefix + key
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account as CFString
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw NSError()
        }
    }
}
