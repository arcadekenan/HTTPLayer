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
 
    private static let httpConfig: HTTPConfig = HTTPConfig()
    private static let httpSecurity: HTTPSecurity = HTTPSecurity()
    private static let httpManager: HTTPManager = HTTPManager(httpConfig, httpSecurity)
    
    ///Set of Methods for Configuring Hosts, Contexts and Headers.
    public class Config {
        
        ///Add a Host and its Context associeted with a Key to be accessed by the Request Methods.
        public static func add(host: String, withContext: String, onKey: String) {
            HTTP.httpConfig.add(host: host, withContext: withContext, onKey: onKey)
        }
        
        ///Add a Header with its Key and Value to a Key to be used by the Request Methods.
        public static func add(header: (key: String, value: String), onKey: String) {
            HTTP.httpConfig.add(header: header, onKey: onKey)
        }
        
        ///Set one Host and Context from the List for each respective Key provided to be accessed by the Request Methods. List of Hosts and Contexts and Keys must have the same length.
        public static func set(listOfHostsAndContexts: [(host: String, context: String)], onRespectiveKeys: [String]) {
            HTTP.httpConfig.set(listOfHostsAndContexts: listOfHostsAndContexts, onRespectiveKeys: onRespectiveKeys)
        }
        
        ///Set a List of Headers on the Key provided to be used on Request Methods.
        public static func set(listOfHeaders: [String : String], onKey: String) {
            HTTP.httpConfig.set(listOfHeaders: listOfHeaders, onKey: onKey)
        }
        
        ///Get the Host and Context already setted by its respective Key.
        public static func getHostAndContext(forKey: String) -> (host: String, context: String)? {
            return HTTP.httpConfig.getHostAndContext(forKey: forKey)
        }
        
        ///Get the Headers already setted by its respective Key.
        public static func getHeaders(forKey: String) -> [String : String]? {
            return HTTP.httpConfig.getHeaders(forKey: forKey)
        }
        
        ///Change Header Value on the Headers Dictionary by its headerKey.
        public static func change(headerValueTo value: String, fromHeaderKey headerKey: String, onKey key: String) {
            HTTP.httpConfig.change(headerValueTo: value, fromHeaderKey: headerKey, onKey: key)
        }
        
        ///Remove Header from Headers Dictinary by its headerKey.
        public static func remove(headerKey: String, onKey key: String) {
            HTTP.httpConfig.remove(headerKey: headerKey, onKey: key)
        }

    }
    
    ///Set of Methods for Configuring Security Parameters.
    public class Security {
        
        ///Enable or Disable SSL pinning.
        public static func set(pinning: Bool) {
            HTTP.httpSecurity.set(pinning: pinning)
        }
        
        ///Enable or Disable Debug Mode. (In Debug Mode the set of Hashs that a server accepts are logged on the console as well as some other informations)
        public static func set(debugMode: Bool) {
            HTTP.httpSecurity.set(debugMode: debugMode)
        }
        
        ///Set a list of Hash Keys SHA256 encoded with Base64 to the server host expecified.
        /// - Parameters:
        ///     - hashes: 3x4g2ft3wylFxPAs31u185PnKApdwI+qyI4h+VGDvZ8=
        ///     - host: example.com
        public static func set(hashes: [String], toHost host: String) {
            HTTP.httpSecurity.set(hashes: hashes, toHost: host)
        }
        
        ///Set a certificate file to the server host expecified.
        /// - Parameters:
        ///     - fileName: The same file name that the certificate located on the application Bundle has.
        ///     - extension: The same extension that the certificate located on the application Bundle has. (Extensions supported are '.cer' and '.crt')
        ///     - host: example.com
        /// - Returns: A Boolean informing if it was possible to retrieve the certificate file from Bundle. True for Success, False for Failed
        public static func set(fileName: String, withExtension ext: String, toHost host: String) -> Bool {
            return HTTP.httpSecurity.set(fileName: fileName, withExtension: ext, toHost: host)
        }
        
        ///Enable or Disable Continue Without Pinning Property. (If enable, even if the SSL pinning is enable, hosts that are not set and/or has no hash keys nor certificate files attached to them, are handled as Default and continue without pinning)
        public static func set(continueWithoutPinning: Bool) {
            HTTP.httpSecurity.set(continueWithoutPinning: continueWithoutPinning)
        }
        
        ///Get Debug Mode status.
        public static func getDebugMode() -> Bool {
            return HTTP.httpSecurity.getDebugMode()
        }

        ///Get SSL Pinning status.
        public static func getPinning() -> Bool {
            return HTTP.httpSecurity.getPinning()
        }
        
        ///Get all Hash Keys setted and its Hosts
        public static func getAllHashesToHost() -> [String : [String]] {
            return HTTP.httpSecurity.getAllHashesToHost()
        }
        
        ///Get all Certificate Files setted and its Hosts
        public static func getAllFileToHost() -> [String : Data?] {
            return HTTP.httpSecurity.getAllFileToHost()
        }
        
        ///Get Continue Without Pinning status.
        public static func getContinueWithoutPinning() -> Bool {
            return HTTP.httpSecurity.getContinueWithoutPinning()
        }
    }
    
    ///Set of Methods for Requests.
    public class Request {
        
        ///GET Type Request without any parameter and expecting JSON as the response.
        public static func get<D: Decodable>(from service: String, withHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type, completion: @escaping (Result<ResponseObject<D>, ErrorObject<EmptyObject>>) -> ()) {
            HTTP.httpManager.get(from: service, withHostAndContext: hostAndContextKey, andHeaders: headersKey, completion: completion)
        }
        
        ///GET Type Request without any parameter, receaving a possible Error Object and expecting JSON as the response.
        public static func get<D: Decodable, ER: Decodable>(from service: String, withHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type, receivingAsError errorObj: ER.Type, completion: @escaping (Result<ResponseObject<D>, ErrorObject<ER>>) -> ()) {
            HTTP.httpManager.get(from: service, withHostAndContext: hostAndContextKey, andHeaders: headersKey, completion: completion)
        }
        
        ///GET Type Request using Query Parameters and expecting JSON as the response.
        public static func get<D: Decodable>(from service: String, usingQueryParameters parameters: [String : String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type, completion: @escaping (Result<ResponseObject<D>, ErrorObject<EmptyObject>>) -> ()) {
            HTTP.httpManager.get(from: service, usingQueryParameters: parameters, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, completion: completion)
        }
        
        ///GET Type Request using Query Parameters, receaving a possible Error Object and expecting JSON as the response.
        public static func get<D: Decodable, ER: Decodable>(from service: String, usingQueryParameters parameters: [String : String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type, receivingAsError errorObj: ER.Type, completion: @escaping (Result<ResponseObject<D>, ErrorObject<ER>>) -> ()) {
            HTTP.httpManager.get(from: service, usingQueryParameters: parameters, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, completion: completion)
        }
        
        ///GET Type Request using Path Parameters and expecting JSON as the response.
        public static func get<D: Decodable>(from service: String, usingPathParameters parameters: [String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type, completion: @escaping (Result<ResponseObject<D>, ErrorObject<EmptyObject>>) -> ()) {
            HTTP.httpManager.get(from: service, usingPathParameters: parameters, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, completion: completion)
        }
        
        ///GET Type Request using Path Parameters, receaving a possible Error Object and expecting JSON as the response.
        public static func get<D: Decodable, ER: Decodable>(from service: String, usingPathParameters parameters: [String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type, receivingAsError errorObj: ER.Type, completion: @escaping (Result<ResponseObject<D>, ErrorObject<ER>>) -> ()) {
            HTTP.httpManager.get(from: service, usingPathParameters: parameters, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, completion: completion)
        }
        
        ///POST Type Request using Body Object and expecting JSON as the response.
        public static func post<E: Encodable, D: Decodable>(to service: String, withBody body: E, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type, completion: @escaping (Result<ResponseObject<D>, ErrorObject<EmptyObject>>) -> ()) {
            HTTP.httpManager.post(to: service, withBody: body, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, completion: completion)
        }
        
        ///POST Type Request using Body Object, receaving a possible Error Object and expecting JSON as the response.
        public static func post<E: Encodable, D: Decodable, ER: Decodable>(to service: String, withBody body: E, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type, receivingAsError errorObj: ER.Type, completion: @escaping (Result<ResponseObject<D>, ErrorObject<ER>>) -> ()) {
            HTTP.httpManager.post(to: service, withBody: body, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, completion: completion)
        }
        
        ///PUT Type Request using Body Object and/or Query Parameters and expecting JSON as the response.
        public static func put<E: Encodable, D: Decodable>(on service: String, withBody body: E, andQueryParameters parameters: [String : String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type, completion: @escaping (Result<ResponseObject<D>, ErrorObject<EmptyObject>>) -> ()) {
            HTTP.httpManager.put(on: service, withBody: body, andQueryParameters: parameters, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, completion: completion)
        }
        
        ///PUT Type Request using Body Object and/or Query Parameters, receaving a possible Error Object and expecting JSON as the response.
        public static func put<E: Encodable, D: Decodable, ER: Decodable>(on service: String, withBody body: E, andQueryParameters parameters: [String : String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type, receivingAsError errorObj: ER.Type, completion: @escaping (Result<ResponseObject<D>, ErrorObject<ER>>) -> ()) {
            HTTP.httpManager.put(on: service, withBody: body, andQueryParameters: parameters, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, completion: completion)
        }
        
        ///PUT Type Request using Body Object and/or Path Parameters and expecting JSON as the response.
        public static func put<E: Encodable, D: Decodable>(on service: String, withBody body: E, andPathParameters parameters: [String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type, completion: @escaping (Result<ResponseObject<D>, ErrorObject<EmptyObject>>) -> ()) {
            HTTP.httpManager.put(on: service, withBody: body, andPathParameters: parameters, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, completion: completion)
        }
        
        ///PUT Type Request using Body Object and/or Path Parameters, receaving a possible Error Object and expecting JSON as the response.
        public static func put<E: Encodable, D: Decodable, ER: Decodable>(on service: String, withBody body: E, andPathParameters parameters: [String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type, receivingAsError errorObj: ER.Type, completion: @escaping (Result<ResponseObject<D>, ErrorObject<ER>>) -> ()) {
            HTTP.httpManager.put(on: service, withBody: body, andPathParameters: parameters, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, completion: completion)
        }
        
        ///DELETE Type Request using Query Parameters and expecting JSON as the response.
        public static func delete<D: Decodable>(from service: String, withQueryParameters parameters: [String : String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type, completion: @escaping (Result<ResponseObject<D>, ErrorObject<EmptyObject>>) -> ()) {
            HTTP.httpManager.delete(from: service, withQueryParameters: parameters, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, completion: completion)
        }
        
        ///DELETE Type Request using Query Parameters, receaving a possible Error Object and expecting JSON as the response.
        public static func delete<D: Decodable, ER: Decodable>(from service: String, withQueryParameters parameters: [String : String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type, receivingAsError errorObj: ER.Type, completion: @escaping (Result<ResponseObject<D>, ErrorObject<ER>>) -> ()) {
            HTTP.httpManager.delete(from: service, withQueryParameters: parameters, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, completion: completion)
        }
        
        ///DELETE Type Request using Path Parameters and expecting JSON as the response.
        public static func delete<D: Decodable>(from service: String, withPathParameters parameters: [String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type, completion: @escaping (Result<ResponseObject<D>, ErrorObject<EmptyObject>>) -> ()) {
            HTTP.httpManager.delete(from: service, withPathParameters: parameters, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, completion: completion)
        }
        
        ///DELETE Type Request using Path Parameters, receaving a possible Error Object and expecting JSON as the response.
        public static func delete<D: Decodable, ER: Decodable>(from service: String, withPathParameters parameters: [String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receivingObjectType responseObj: D.Type, receivingAsError errorObj: ER.Type, completion: @escaping (Result<ResponseObject<D>, ErrorObject<ER>>) -> ()) {
            HTTP.httpManager.delete(from: service, withPathParameters: parameters, fromHostAndContext: hostAndContextKey, andHeaders: headersKey, completion: completion)
        }
    }
}
