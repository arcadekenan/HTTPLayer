//
//  POSTResponse.swift
//  HTTPLayerTests
//
//  Created by Davi Bispo on 16/04/19.
//  Copyright © 2019 Arkd. All rights reserved.
//

import Foundation

struct POSTWithBodyParameterResponse: Decodable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
}
