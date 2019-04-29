//
//  ErrorObject.swift
//  HTTPLayer
//
//  Created by Davi Bispo on 29/04/19.
//  Copyright © 2019 Arkd. All rights reserved.
//

import Foundation

public struct ErrorObject<ER: Decodable>: Error {
    public let response: ER?
    public let error: Error?
}
