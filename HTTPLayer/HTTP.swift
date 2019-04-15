//
//  HTTP.swift
//  HTTPLayer
//
//  Created by Davi Bispo on 14/04/19.
//  Copyright © 2019 Arkd. All rights reserved.
//

import Foundation

///HTTP Network Manager
public class HTTP {
 
    public static let config: HTTPInit = HTTPInit()
    public static let request: HTTPManager = HTTPManager(config)
}
