//
//  HTTPInit.swift
//  HTTPLayer
//
//  Created by Davi Bispo on 05/04/19.
//  Copyright © 2019 Arkd. All rights reserved.
//

import Foundation

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
        self.keyToHeaders[onKey]?.append((header.key, header.value))
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
