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
 
    private static let httpInit: HTTPInit = HTTPInit()
    private static let httpManager: HTTPManager = HTTPManager(httpInit)
    
    ///Set of Methods for Configuring Hosts, Contexts and Headers
    class Config {
        
        ///Add a Host and its Context associeted with a Key to be accessed by the Request Methods
        static func add(host: String, withContext: String, onKey: String) {
            HTTP.httpInit.add(host: host, withContext: withContext, onKey: onKey)
        }
        
        ///Add a Header with its Key and Value to a Key to be used by the Request Methods
        static func add(header: (key: String, value: String), onKey: String) {
            HTTP.httpInit.add(header: header, onKey: onKey)
        }
        
        ///Set one Host and Context from the List for each respective Key provided to be accessed by the Request Methods. List of Hosts and Contexts and Keys must have the same length.
        static func set(listOfHostsAndContexts: [(host: String, context: String)], onRespectiveKeys: [String]) {
            HTTP.httpInit.set(listOfHostsAndContexts: listOfHostsAndContexts, onRespectiveKeys: onRespectiveKeys)
        }
        
        ///Set a List of Headers on the Key provided to be used on Request Methods
        static func set(listOfHeaders: [(key: String, value: String)], onKey: String) {
            HTTP.httpInit.set(listOfHeaders: listOfHeaders, onKey: onKey)
        }
        
        ///Get the Host and Context already setted by its respective Key
        static func getHostAndContext(forKey: String) -> (host: String, context: String)? {
            return HTTP.httpInit.getHostAndContext(forKey: forKey)
        }
        
        ///Get the Headers already setted by its respective Key
        static func getHeaders(forKey: String) -> [(key: String, value: String)]? {
            return HTTP.httpInit.getHeaders(forKey: forKey)
        }
    }
    
    class Request {
        
        ///GET Type Request without any parameter and expecting JSON as the response.
        static func get<D: Decodable>(from service: String, withHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type!, completion: @escaping (Result<D, Error>) -> ()) {
            HTTP.httpManager.get(from: service, withHostAndContext: hostAndContextKey, andHeaders: headersKey, receivingObjectType: responseObj, completion: completion)
        }
        
        ///GET Type Request using Query Parameters and expecting JSON as the response.
        static func get<D: Decodable>(from service: String, usingQueryParameters parameters: [String : String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type!, completion: @escaping (Result<D, Error>) -> ()) {
            HTTP.httpManager.get(from: service, usingQueryParameters: parameters, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, receivingObjectType: responseObj, completion: completion)
        }
        
        ///GET Type Request using Path Parameters and expecting JSON as the response.
        static func get<D: Decodable>(from service: String, usingPathParameters parameters: [String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type!, completion: @escaping (Result<D, Error>) -> ()) {
            HTTP.httpManager.get(from: service, usingPathParameters: parameters, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, receivingObjectType: responseObj, completion: completion)
        }
        
        ///POST Type Request using Body Object and expecting JSON as the response.
        static func post<E: Encodable, D: Decodable>(to service: String, withBody body: E, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type!, completion: @escaping (Result<D, Error>) -> ()) {
            HTTP.httpManager.post(to: service, withBody: body, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, receivingObjectType: responseObj, completion: completion)
        }
        
        ///PUT Type Request using Body Object and/or Query Parameters and expecting JSON as the response.
        static func put<E: Encodable, D: Decodable>(on service: String, withBody body: E, andQueryParameters parameters: [String : String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type!, completion: @escaping (Result<D, Error>) -> ()) {
            HTTP.httpManager.put(on: service, withBody: body, andQueryParameters: parameters, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, receivingObjectType: responseObj, completion: completion)
        }
        
        ///PUT Type Request using Body Object and/or Path Parameters and expecting JSON as the response.
        static func put<E: Encodable, D: Decodable>(on service: String, withBody body: E, andPathParameters parameters: [String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type!, completion: @escaping (Result<D, Error>) -> ()) {
            HTTP.httpManager.put(on: service, withBody: body, andPathParameters: parameters, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, receivingObjectType: responseObj, completion: completion)
        }
        
        ///DELETE Type Request using Query Parameters and expecting JSON as the response.
        static func delete<D: Decodable>(from service: String, withQueryParameters parameters: [String : String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type!, completion: @escaping (Result<D, Error>) -> ()) {
            HTTP.httpManager.delete(from: service, withQueryParameters: parameters, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, receivingObjectType: responseObj, completion: completion)
        }
        
        ///DELETE Type Request using Path Parameters and expecting JSON as the response.
        static func delete<D: Decodable>(from service: String, withPathParameters parameters: [String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type!, completion: @escaping (Result<D, Error>) -> ()) {
            HTTP.httpManager.delete(from: service, withPathParameters: parameters, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, receivingObjectType: responseObj, completion: completion)
        }
    }
}
