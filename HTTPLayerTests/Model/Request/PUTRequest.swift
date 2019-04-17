//
//  PUTRequest.swift
//  HTTPLayerTests
//
//  Created by Davi Bispo on 17/04/19.
//  Copyright © 2019 Arkd. All rights reserved.
//

import Foundation

struct PUTWithBodyAndQueryParametersRequest: Encodable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
}

struct PUTWithBodyAndPathParametersRequest: Encodable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
}
