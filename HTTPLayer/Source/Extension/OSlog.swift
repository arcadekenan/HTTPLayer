//
//  OSlog.swift
//  HTTPLayer
//
//  Created by Davi Bispo on 06/04/19.
//  Copyright © 2019 Arkd. All rights reserved.
//

import Foundation
import os.log

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let HTTPLayer = OSLog(subsystem: subsystem, category: "HTTPLayer")
}
