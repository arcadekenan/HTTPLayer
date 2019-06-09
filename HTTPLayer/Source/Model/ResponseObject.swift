//
//  ResponseObject.swift
//  HTTPLayer
//
//  Created by Davi Bispo on 08/06/19.
//  Copyright © 2019 Arkd. All rights reserved.
//

import Foundation

public struct ResponseObject<R: Decodable> {
    public let response: R?
    public let headers: [AnyHashable : Any]?
}
