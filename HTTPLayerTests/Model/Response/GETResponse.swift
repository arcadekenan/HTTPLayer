//
//  GETResponse.swift
//  HTTPLayerTests
//
//  Created by Davi Bispo on 16/04/19.
//  Copyright © 2019 Arkd. All rights reserved.
//

import Foundation

struct GETWithoutParametersResponse: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

struct GETWithPathParametersResponse: Decodable {
    let postId: Int
    let id: Int
    let name: String
    let email: String
    let body: String
}

struct GETWithQueryParametersResponse: Decodable {
    let postId: Int
    let id: Int
    let name: String
    let email: String
    let body: String
}
