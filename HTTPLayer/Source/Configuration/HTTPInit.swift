//
//  HTTPInit.swift
//  HTTPLayer
//
//  Created by Davi Bispo on 05/04/19.
//  Copyright © 2019 Arkd. All rights reserved.
//

import Foundation

public class HTTPInit {
    
    public static let data: HTTPInit = HTTPInit()
    private var keyToHostAndContext: [ String : ( host: String, context: String ) ] = [:]
    private var keyToHttpHeaders: [ String : [( key: String, value: String )] ] = [:]
    
    public init() {}
    
    public func add(host: String, withContext context: String, onKey: String) {
        self.keyToHostAndContext[onKey] = (host, context)
    }
    
    public func add(header: (key: String, value: String), onKey: String) {
        self.keyToHttpHeaders[onKey]?.append((header.key, header.value))
    }
    
    public func getHostAndContext(withKey key: String) -> ( host: String, context: String )? {
        return self.keyToHostAndContext[key]
    }
    
    public func getHttpHeaders(withKey key: String) -> [( key: String, value: String )]? {
        return self.keyToHttpHeaders[key]
    }
}
