//
//  HTTPInit.swift
//  HTTPLayer
//
//  Created by Davi Bispo on 05/04/19.
//  Copyright © 2019 Arkd. All rights reserved.
//

import Foundation
import os.log

class HTTPInit {
    
    private var keyToHostAndContext: [ String : ( host: String, context: String ) ] = [:]
    private var keyToHeaders: [ String : [ String : String ] ] = [:]
    public init() {}

    public func add(host: String, withContext context: String, onKey: String) {
        self.keyToHostAndContext[onKey] = (host, context)
    }
    
    public func add(header: (key: String, value: String), onKey: String) {
        if self.keyToHeaders[onKey] != nil {
            self.keyToHeaders[onKey]?[header.key] = header.value
        } else {
            self.keyToHeaders[onKey] = [header.key : header.value]
        }
    }
    
    public func set(listOfHostsAndContexts list: [( host: String, context: String )], onRespectiveKeys keys: [String]) {
        if list.count == keys.count {
            var index = 0
            list.forEach {
                self.keyToHostAndContext[keys[index]] = ($0.host, $0.context)
                index += 1
            }
        } else {
            os_log("Enable to set list of Hosts and Contexts: List and Keys differs in length", log: OSLog.HTTPLayer, type: .debug)
            return
        }
    }
    
    public func set(listOfHeaders headers: [String : String], onKey: String) {
        self.keyToHeaders[onKey] = headers
    }
    
    public func getHostAndContext(forKey key: String) -> ( host: String, context: String )? {
        return self.keyToHostAndContext[key]
    }
    
    public func getHeaders(forKey key: String) -> [String : String]? {
        return self.keyToHeaders[key]
    }
    
    public func change(headerValueTo value: String, fromHeaderKey headerKey: String, onKey key: String) {
        if var headers = self.keyToHeaders[key] {
            if headers[headerKey] != nil {
                self.keyToHeaders[key]?[headerKey] = value
                os_log("Header Changed", log: OSLog.HTTPLayer, type: .debug)
            } else {
                os_log("No HeaderKey Found", log: OSLog.HTTPLayer, type: .debug)
            }
        } else {
            os_log("No Key Found", log: OSLog.HTTPLayer, type: .debug)
        }
    }
    
    public func remove(headerKey: String, onKey key: String) {
        if var headers = self.keyToHeaders[key] {
            if headers[headerKey] != nil {
                self.keyToHeaders[key]?.removeValue(forKey: headerKey)
                os_log("Header Removed", log: OSLog.HTTPLayer, type: .debug)
            } else {
                os_log("No HeaderKey Found", log: OSLog.HTTPLayer, type: .debug)
            }
        } else {
            os_log("No Key Found", log: OSLog.HTTPLayer, type: .debug)
        }
    }
}
