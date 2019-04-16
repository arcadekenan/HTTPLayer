//
//  HTTPManager.swift
//  HTTPLayer
//
//  Created by Davi Bispo on 05/04/19.
//  Copyright © 2019 Arkd. All rights reserved.
//

import Foundation
import os.log

public class HTTPManager {
    
    private var config: HTTPInit
    public init(_ config: HTTPInit) {
        self.config = config
    }
    
    enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    fileprivate func buildUrl(usingHost host: String, context: String, andService service: String) -> URL? {
        return URL(string: "\(host)\(context)\(service)")
    }
    
    fileprivate func buildUrl(usingHost host: String, context: String, service: String, withQueryParameters parameters: [String : String]?) -> URL? {
        var base: String = "\(host)\(context)\(service)?"
        var firstParameter: Bool = true;
        guard let parameters = parameters else { return URL(string: base) }
        base = "\(base)?"
        parameters.forEach {
            if firstParameter {
                base += "\($0.key)=\($0.value)"
                firstParameter = false
            } else {
                base += "&\($0.key)=\($0.value)"
            }
        }
        return URL(string: base)
    }
    
    fileprivate func buildUrl(usingHost host: String, context: String, service: String, withPathParameters parameters: [String]?) -> URL? {
        var base: String = "\(host)\(context)\(service)"
        guard let parameters = parameters else { return URL(string: base) }
        base = "\(base)/"
        parameters.forEach { base += "\($0)/" }
        return URL(string: base)
    }
    
    fileprivate func taskManager<T>(usingUrl url: URL, httpMethod: HttpMethod, headersKey: String?, bodyParameter: Any?, completion: @escaping (Result<T, Error>) -> ()) where T : Codable  {
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        if let keyVerified = headersKey, let headers = config.getHeaders(withKey: keyVerified) {
            headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        } else {
            os_log("No Headers Setted or Found by the Key Provided", log: OSLog.HTTPLayer, type: .debug)
        }
        if let body = bodyParameter {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                os_log("Unable to Serialize Body Object Provided", log: OSLog.HTTPLayer, type: .debug)
                return
            }
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { completion(.failure(error!)); return }
            do {
                let responseObj = try JSONDecoder().decode(T.self, from: data)
                completion(.success(responseObj))
            }  catch  {
                os_log("Unable to Parse Response to the Object Provided", log: OSLog.HTTPLayer, type: .debug)
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    ///GET Type Request using Query Parameters and expecting JSON as the response.
    public func get<T>(from service: String, usingQueryParameters parameters: [String : String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receiving responseObj: T.Type!, completion: @escaping (Result<T, Error>) -> ()) where T : Codable {
        guard let hostAndContext = config.getHostAndContext(withKey: hostAndContextKey) else {
            os_log("No Host and Context Found to the Key Provided", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        guard let url = buildUrl(usingHost: hostAndContext.host, context: hostAndContext.context, service: service, withQueryParameters: parameters) else {
            os_log("Fail to Build URL using the given host and context", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        taskManager(usingUrl: url, httpMethod: .get, headersKey: headersKey, bodyParameter: nil, completion: completion)
    }
    
    ///GET Type Request using URL Parameters and expecting JSON as the response.
    public func get<T>(from service: String, usingPathParameters parameters: [String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, receiving responseObj: T.Type!, completion: @escaping (Result<T, Error>) -> ()) where T : Codable {
        guard let hostAndContext = config.getHostAndContext(withKey: hostAndContextKey) else {
            os_log("No Host and Context Found to the Key Provided", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        guard let url = buildUrl(usingHost: hostAndContext.host, context: hostAndContext.context, service: service, withPathParameters: parameters) else {
            os_log("Fail to Build URL using the given host and context", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        taskManager(usingUrl: url, httpMethod: .get, headersKey: headersKey, bodyParameter: nil, completion: completion)
    }
    
    ///POST Type Request using Body Object and expecting JSON as the response.
    public func post<T>(to service: String, withBody body: Any?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String, receiving responseObj: T.Type!, completion: @escaping (Result<T, Error>) -> ()) where T : Codable {
        guard let hostAndContext = config.getHostAndContext(withKey: hostAndContextKey) else {
            os_log("No Host and Context Found to the Key Provided", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        guard let url = buildUrl(usingHost: hostAndContext.host, context: hostAndContext.context, andService: service) else {
            os_log("Fail to Build URL using the given host and context", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        taskManager(usingUrl: url, httpMethod: .post, headersKey: headersKey, bodyParameter: body, completion: completion)
    }
    
    ///PUT Type Request using Body Object and/or Query Parameters and expecting JSON as the response.
    public func put<T>(on service: String, withBody body: Any?, andQueryParameters parameters: [String : String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String, receiving responseObj: T.Type!, completion: @escaping (Result<T, Error>) -> ()) where T : Codable {
        guard let hostAndContext = config.getHostAndContext(withKey: hostAndContextKey) else {
            os_log("No Host and Context Found to the Key Provided", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        guard let url = buildUrl(usingHost: hostAndContext.host, context: hostAndContext.context, service: service, withQueryParameters: parameters ?? nil) else {
            os_log("Fail to Build URL using the given host and context", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        taskManager(usingUrl: url, httpMethod: .put, headersKey: headersKey, bodyParameter: body, completion: completion)
    }
    
    ///PUT Type Request using Body Object and/or Path Parameters and expecting JSON as the response.
    public func put<T>(on service: String, withBody body: Any?, andPathParameters parameters: [String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String, receiving responseObj: T.Type!, completion: @escaping (Result<T, Error>) -> ()) where T : Codable {
        guard let hostAndContext = config.getHostAndContext(withKey: hostAndContextKey) else {
            os_log("No Host and Context Found to the Key Provided", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        guard let url = buildUrl(usingHost: hostAndContext.host, context: hostAndContext.context, service: service, withPathParameters: parameters ?? nil) else {
            os_log("Fail to Build URL using the given host and context", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        taskManager(usingUrl: url, httpMethod: .put, headersKey: headersKey, bodyParameter: body, completion: completion)
    }
    
    ///DELETE Type Request using Body Object and/or Query Parameters and expecting JSON as the response.
    public func delete<T>(from service: String, withBody body: Any?, andQueryParameters parameters: [String : String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String, receiving responseObj: T.Type!, completion: @escaping (Result<T, Error>) -> ()) where T : Codable {
        guard let hostAndContext = config.getHostAndContext(withKey: hostAndContextKey) else {
            os_log("No Host and Context Found to the Key Provided", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        guard let url = buildUrl(usingHost: hostAndContext.host, context: hostAndContext.context, service: service, withQueryParameters: parameters ?? nil) else {
            os_log("Fail to Build URL using the given host and context", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        taskManager(usingUrl: url, httpMethod: .delete, headersKey: headersKey, bodyParameter: body, completion: completion)
    }
    
    ///DELETE Type Request using Body Object and/or Path Parameters and expecting JSON as the response.
    public func delete<T>(from service: String, withBody body: Any?, andPathParameters parameters: [String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String, receiving responseObj: T.Type!, completion: @escaping (Result<T, Error>) -> ()) where T : Codable {
        guard let hostAndContext = config.getHostAndContext(withKey: hostAndContextKey) else {
            os_log("No Host and Context Found to the Key Provided", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        guard let url = buildUrl(usingHost: hostAndContext.host, context: hostAndContext.context, service: service, withPathParameters: parameters ?? nil) else {
            os_log("Fail to Build URL using the given host and context", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        taskManager(usingUrl: url, httpMethod: .delete, headersKey: headersKey, bodyParameter: body, completion: completion)
    }

}
