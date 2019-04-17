//
//  HTTPInit.swift
//  HTTPLayer
//
//  Created by Davi Bispo on 05/04/19.
//  Copyright © 2019 Arkd. All rights reserved.
//

import Foundation
import os.log

public class HTTPInit {
    
    private var keyToHostAndContext: [ String : ( host: String, context: String ) ] = [:]
    private var keyToHeaders: [ String : [( key: String, value: String )] ] = [:]
    public init() {}

    ///Add a Host and its Context associeted with a Key to be accessed by the Request Methods
    public func add(host: String, withContext context: String, onKey: String) {
        self.keyToHostAndContext[onKey] = (host, context)
    }
    
    ///Add a Header with its Key and Value to a Key to be used by the Request Methods
    public func add(header: (key: String, value: String), onKey: String) {
        if var headerEntry = self.keyToHeaders[onKey] {
            headerEntry.append((header.key, header.value))
        } else {
            self.keyToHeaders[onKey] = [(header.key, header.value)]
        }
    }
    
    ///Set one Host and Context from the List for each respective Key provided to be accessed by the Request Methods. List of Hosts and Contexts and Keys must have the same length.
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
    
    ///Set a List of Headers on the Key provided to be used on Request Methods
    public func set(listOfHeaders headers: [(key: String, value: String)], onKey: String) {
        headers.forEach {
            self.keyToHeaders[onKey]?.append(($0.key, $0.value))
        }
    }
    
    ///Get the Host and Context already setted by its respective Key
    public func getHostAndContext(withKey key: String) -> ( host: String, context: String )? {
        return self.keyToHostAndContext[key]
    }
    
    ///Get the Headers already setted by its respective Key
    public func getHeaders(withKey key: String) -> [( key: String, value: String )]? {
        return self.keyToHeaders[key]
    }
}
