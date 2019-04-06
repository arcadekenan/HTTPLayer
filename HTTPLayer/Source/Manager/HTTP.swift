//
//  HTTP.swift
//  HTTPLayer
//
//  Created by Davi Bispo on 05/04/19.
//  Copyright © 2019 Arkd. All rights reserved.
//

import Foundation
import os.log

class HTTP {
    
    private static func buildUrl(usingHost host: String, context: String, service: String, withQueryParameters parameters: [String : String]) -> URL? {
        var base: String = "\(host)\(context)\(service)?"
        parameters.forEach { base += "&\($0.key)=\($0.value)" }
        return URL(string: base)
    }
    
    private static func buildURL(usingHost host: String, context: String, service: String, withUrlParameters parameters: [String]) -> URL? {
        var base: String = "\(host)\(context)\(service)"
        parameters.forEach { base += "\($0)/" }
        return URL(string: base)
    }
    
    public static func get<T>(from service: String, usingQueryParameters parameters: [String : String], fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String, receiving responseObj: T.Type!, completion: @escaping (_ data: T?, _ error: Error?) -> ()) where T : Codable {
        guard let hostAndContext = HTTPInit.data.getHostAndContext(withKey: hostAndContextKey) else {
            os_log("No Host and Context Found to the Key Suplied", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        guard let headers = HTTPInit.data.getHttpHeaders(withKey: headersKey) else { return }
        guard let url = buildUrl(usingHost: hostAndContext.host, context: hostAndContext.context, service: service, withQueryParameters: parameters) else { return }
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { completion(nil, error); return }
            do {
                let responseObj = try JSONDecoder().decode(T.self, from: data)
                completion(responseObj, nil)
            }  catch  {
                os_log("Unable no Parse Response to the Object Suplied", log: OSLog.HTTPLayer, type: .debug)
                completion(nil, nil)
            }
        }
        task.resume()
    }
    
    public static func get<T>(from service: String, usingUrlParameters parameters: [String], fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String, receiving responseObj: T.Type!, completion: @escaping (_ data: T?, _ error: Error?) -> ()) where T : Codable {
        guard let hostAndContext = HTTPInit.data.getHostAndContext(withKey: hostAndContextKey) else {
            os_log("No Host and Context Found to the Key Suplied", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        guard let headers = HTTPInit.data.getHttpHeaders(withKey: headersKey) else { return }
        guard let url = buildURL(usingHost: hostAndContext.host, context: hostAndContext.context, service: service, withUrlParameters: parameters) else { return }
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { completion(nil, error); return }
            do {
                let responseObj = try JSONDecoder().decode(T.self, from: data)
                completion(responseObj, nil)
            }  catch  {
                os_log("Unable no Parse Response to the Object Suplied", log: OSLog.HTTPLayer, type: .debug)
                completion(nil, nil)
            }
        }
        task.resume()
    }
    
}
