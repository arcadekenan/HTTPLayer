//
//  HTTPPinner.swift
//  HTTPLayer
//
//  Created by Davi Bispo on 07/06/19.
//  Copyright © 2019 Arkd. All rights reserved.
//

import Foundation
import Security
import os.log

class HTTPPinner {
    
    open var expectedBaseUrl : String?
    private var security: HTTPSecurity
    
    fileprivate var localHashList : [String] = []
    
    init(_ expectedUrl : String, _ security: HTTPSecurity)  {
        self.security = security
    }
    
    open func addCertificateHash(_ hash : String) {
        localHashList.append(hash)
    }
    
    open func validateCertificateTrustChain(_ trust: SecTrust) -> Bool {
        guard let baseUrl = expectedBaseUrl, expectedBaseUrl != "" else {
            return false
        }
        
        let policy = SecPolicyCreateSSL(true, baseUrl as CFString)
        
        SecTrustSetPolicies(trust, policy)
        
        var result = SecTrustResultType.invalid
        
        if SecTrustEvaluate(trust, &result) == errSecSuccess {
            return (result == SecTrustResultType.unspecified || result == SecTrustResultType.proceed)
        }
        
        return false
    }
    
    open func validateTrustPublicKeys(_ trust: SecTrust) -> Bool {
        let trustPublicKeys = getPublicKeysFromTrust(trust)
        
        if trustPublicKeys.count == 0 {
            return false
        }
        
        if localHashList.count == 0 && !security.getDebugMode() {
            os_log("No Hash found. Consider using HTTP.Security.debug(true) ", log: OSLog.HTTPLayer, type: .debug)
            return true
        }
        
        if security.getDebugMode() {
            os_log("Hash from the Trust. (The order of hashes printed are from the most specific to least, your domain..root CA)", log: OSLog.HTTPLayer, type: .debug)
            for trustKey in trustPublicKeys {
                os_log("Hash: %s", trustKey)
            }
        }
        
        for trustKey in trustPublicKeys {
            for localKey in localHashList {
                if (localKey == trustKey) {
                    return true
                }
            }
        }
        
        return false
    }
    
    fileprivate func getPublicKeysFromTrust(_ trust: SecTrust) -> [String] {
        var res : [String] = []
        
        for index in 0..<SecTrustGetCertificateCount(trust) {
            if let
                certificate = SecTrustGetCertificateAtIndex(trust, index),
                let publicKey = publicKeyForCertificate(certificate)
            {
                let publicKeyHash = publicKeyRefToHash(publicKey)
                res.append(publicKeyHash)
            }
        }
        
        return res
    }
    
    fileprivate func publicKeyForCertificate(_ certificate: SecCertificate) -> SecKey? {
        var publicKey: SecKey?
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)
        
        if let trust = trust, trustCreationStatus == errSecSuccess {
            publicKey = SecTrustCopyPublicKey(trust)
        }
        
        return publicKey
    }
    
    fileprivate func publicKeyRefToHash(_ publicKeyRef: SecKey) -> String {
        if let keyData = publicKeyRefToData(publicKeyRef) {
            
            var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
            keyData.withUnsafeBytes { _ = CC_SHA256($0.baseAddress, CC_LONG(keyData.count), &hash) }
            let res = Data(hash)
            
            return res.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        }
        
        return ""
    }

    fileprivate func publicKeyRefToData(_ publicKeyRef: SecKey) -> Data? {
        let keychainTag = "X509_KEY"
        var publicKeyData : AnyObject?
        var putResult : OSStatus = noErr
        var delResult : OSStatus = noErr
        
        let putKeyParams : NSMutableDictionary = [
            kSecClass as String : kSecClassKey,
            kSecAttrApplicationTag as String : keychainTag,
            kSecValueRef as String : publicKeyRef,
            kSecReturnData as String : kCFBooleanTrue as Any
        ]
        
        let delKeyParams : NSMutableDictionary = [
            kSecClass as String : kSecClassKey,
            kSecAttrApplicationTag as String : keychainTag,
            kSecReturnData as String : kCFBooleanTrue as Any
        ]
        
        putResult = SecItemAdd(putKeyParams as CFDictionary, &publicKeyData)
        delResult = SecItemDelete(delKeyParams as CFDictionary)
        
        if putResult != errSecSuccess || delResult != errSecSuccess {
            return nil
        }
        
        return publicKeyData as? Data
    }
}
