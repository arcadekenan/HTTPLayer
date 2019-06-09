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
    
    public func set(hashes: [String], toHost host: String) {
        self.hashesToHost[host] = hashes
    }
    
    public func getAllHashesToHost() -> [String : [String]] {
        return self.hashesToHost
    }
    
    public func getAllFileToHost() -> [String : Data?] {
        return self.fileToHost
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
