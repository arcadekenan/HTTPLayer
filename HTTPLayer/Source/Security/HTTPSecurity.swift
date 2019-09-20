//
//  HTTPSecurity.swift
//  HTTPLayer
//
//  Created by Davi Bispo on 07/06/19.
//  Copyright © 2019 Arkd. All rights reserved.
//

import Foundation
import os.log

class HTTPSecurity{
    
    private var hashesToHost: [String : [String]] = [:]
    private var fileToHost: [String : Data?] = [:]
    private var pinning: Bool = false
    private var continueWithoutPinning: Bool = false
    private var trustItAllNoMatterWhat: Bool = false
    private var debug: Bool = false
    public init() {}
    
    public func set(debugMode: Bool) {
        self.debug = debugMode
    }
    
    public func getDebugMode() -> Bool {
        return self.debug
    }
    
    public func set(pinning: Bool) {
        self.pinning = pinning
    }
    
    public func getPinning() -> Bool {
        return self.pinning
    }
    
    public func set(continueWithoutPinning: Bool) {
        self.continueWithoutPinning = continueWithoutPinning
    }
    
    public func getContinueWithoutPinning() -> Bool {
        return self.continueWithoutPinning
    }
    
    public func set(trustItAllNoMatterWhat: Bool) {
        self.trustItAllNoMatterWhat = trustItAllNoMatterWhat
    }
    
    public func getTrustItAllNoMatterWhat() -> Bool {
        return self.trustItAllNoMatterWhat
    }
    
    public func set(hashes: [String], toHost host: String) {
        self.hashesToHost[host] = hashes
    }
    
    public func getAllHashesToHost() -> [String : [String]] {
        return self.hashesToHost
    }
    
    public func findHashs(byHost host: String, inHostsAndContexts hosts: [ String : ( host: String, context: String ) ]) -> [String]? {
        var hashes: [String]?
        hosts.forEach { item in
            if item.value.host.contains(host) {
                hashes = getAllHashesToHost()[item.key]
            }
        }
        return hashes
    }
    
    public func getAllFileToHost() -> [String : Data?] {
        return self.fileToHost
    }
    
    public func findFile(byHost host: String, inHostsAndContexts hosts: [ String : ( host: String, context: String ) ]) -> Data?? {
        var file: Data??
        hosts.forEach { item in
            if item.value.host.contains(host) {
                file = getAllFileToHost()[item.key]
            }
        }
        return file
    }
    
    public func set(fileName: String, withExtension ext: String, toHost host: String) -> Bool {
        if let path = Bundle.main.path(forResource: fileName, ofType: ext){
            do {
                fileToHost[host] = try Data(contentsOf: URL(fileURLWithPath: path))
                return true
            } catch {
                return false
            }
        } else {
            return false
        }
    }

}
