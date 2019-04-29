//
//  HTTPManager.swift
//  HTTPLayer
//
//  Created by Davi Bispo on 05/04/19.
//  Copyright © 2019 Arkd. All rights reserved.
//

import Foundation
import os.log

class HTTPManager {
    
    private var config: HTTPConfig
    public init(_ config: HTTPConfig) {
        self.config = config
    }
    
    enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    fileprivate func handle(HTTPStatusCode code: Int) -> (continue: Bool, message: String) {
        let statusCodeMessage: HTTPStatusCodeMessages = HTTPStatusCodeMessages()
        switch code {
        case 100...199: return (continue: false, message: statusCodeMessage.getHTTPMessage(forCode: code))
        case 200...299: return (continue: true, message: statusCodeMessage.getHTTPMessage(forCode: code))
        case 300...399: return (continue: false, message: statusCodeMessage.getHTTPMessage(forCode: code))
        case 400...499: return (continue: false, message: statusCodeMessage.getHTTPMessage(forCode: code))
        case 500...599: return (continue: false, message: statusCodeMessage.getHTTPMessage(forCode: code))
        default: return (continue: false, message: statusCodeMessage.getHTTPMessage(forCode: code))
        }
    }
    
    fileprivate func buildUrl(usingHost host: String, context: String, andService service: String) -> URL? {
        return URL(string: "\(host)\(context)\(service)")
    }
    
    fileprivate func buildUrl(usingHost host: String, context: String, service: String, withQueryParameters parameters: [String : String]?) -> URL? {
        var base: String = "\(host)\(context)\(service)"
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
    
    fileprivate func taskManager<D: Decodable, ER: Decodable>(usingUrl url: URL, httpMethod: HttpMethod, headersKey: String?, completion: @escaping (Result<D, ErrorObject<ER>>) -> ()) {
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        if let keyVerified = headersKey, let headers = config.getHeaders(forKey: keyVerified) {
            headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        } else {
            os_log("No Headers Setted or Found by the Key Provided", log: OSLog.HTTPLayer, type: .debug)
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { completion(.failure(ErrorObject(response: nil, error: error!))); return }
            let httpCodeValidation = self.handle(HTTPStatusCode: (response as! HTTPURLResponse).statusCode)
            os_log("Status Code: %d - %s", (response as! HTTPURLResponse).statusCode, httpCodeValidation.message)
            if httpCodeValidation.continue {
                do {
                    let responseObj = try JSONDecoder().decode(D.self, from: data)
                    completion(.success(responseObj))
                }  catch  {
                    os_log("Unable to Parse Response to the Object Provided", log: OSLog.HTTPLayer, type: .debug)
                    completion(.failure(ErrorObject(response: nil, error: error)))
                }
            } else {
                if ER.self == EmptyObject.self {
                    completion(.failure(ErrorObject(response: nil, error: error)))
                } else {
                    do {
                        let responseObj = try JSONDecoder().decode(ER.self, from: data)
                        completion(.failure(ErrorObject(response: responseObj, error: error)))
                    }  catch  {
                        os_log("Unable to Parse Response to the Object Provided", log: OSLog.HTTPLayer, type: .debug)
                        completion(.failure(ErrorObject(response: nil, error: error)))
                    }
                }
            }
        }
        task.resume()
    }
    
    fileprivate func taskManager<E: Encodable, D: Decodable, ER: Decodable>(usingUrl url: URL, httpMethod: HttpMethod, headersKey: String?, bodyParameter: E, completion: @escaping (Result<D, ErrorObject<ER>>) -> ()) {
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        if let keyVerified = headersKey, let headers = config.getHeaders(forKey: keyVerified) {
            headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        } else {
            os_log("No Headers Setted or Found by the Key Provided", log: OSLog.HTTPLayer, type: .debug)
        }
        do {
            request.httpBody = try JSONEncoder().encode(bodyParameter)
        } catch {
            os_log("Unable to Serialize Body Object Provided", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { completion(.failure(ErrorObject(response: nil, error: error!))); return }
            let httpCodeValidation = self.handle(HTTPStatusCode: (response as! HTTPURLResponse).statusCode)
            os_log("Status Code: %d - %s", (response as! HTTPURLResponse).statusCode, httpCodeValidation.message)
            if httpCodeValidation.continue {
                do {
                    let responseObj = try JSONDecoder().decode(D.self, from: data)
                    completion(.success(responseObj))
                }  catch  {
                    os_log("Unable to Parse Response to the Object Provided", log: OSLog.HTTPLayer, type: .debug)
                    completion(.failure(ErrorObject(response: nil, error: error)))
                }
            } else {
                if ER.self == EmptyObject.self {
                    completion(.failure(ErrorObject(response: nil, error: error)))
                } else {
                    do {
                        let responseObj = try JSONDecoder().decode(ER.self, from: data)
                        completion(.failure(ErrorObject(response: responseObj, error: error)))
                    }  catch  {
                        os_log("Unable to Parse Response to the Object Provided", log: OSLog.HTTPLayer, type: .debug)
                        completion(.failure(ErrorObject(response: nil, error: error)))
                    }
                }
            }
        }
        task.resume()
    }
    
    public func get<D: Decodable, ER: Decodable>(from service: String, withHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, completion: @escaping (Result<D, ErrorObject<ER>>) -> ()) {
        guard let hostAndContext = config.getHostAndContext(forKey: hostAndContextKey) else {
            os_log("No Host and Context Found to the Key Provided", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        guard let url = buildUrl(usingHost: hostAndContext.host, context: hostAndContext.context, andService: service) else {
            os_log("Fail to Build URL using the given host and context", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        taskManager(usingUrl: url, httpMethod: .get, headersKey: headersKey, completion: completion)
    }
    
    public func get<D: Decodable, ER: Decodable>(from service: String, usingQueryParameters parameters: [String : String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, completion: @escaping (Result<D, ErrorObject<ER>>) -> ()) {
        guard let hostAndContext = config.getHostAndContext(forKey: hostAndContextKey) else {
            os_log("No Host and Context Found to the Key Provided", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        guard let url = buildUrl(usingHost: hostAndContext.host, context: hostAndContext.context, service: service, withQueryParameters: parameters) else {
            os_log("Fail to Build URL using the given host and context", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        taskManager(usingUrl: url, httpMethod: .get, headersKey: headersKey, completion: completion)
    }
    
    public func get<D: Decodable, ER: Decodable>(from service: String, usingPathParameters parameters: [String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, completion: @escaping (Result<D, ErrorObject<ER>>) -> ()) {
        guard let hostAndContext = config.getHostAndContext(forKey: hostAndContextKey) else {
            os_log("No Host and Context Found to the Key Provided", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        guard let url = buildUrl(usingHost: hostAndContext.host, context: hostAndContext.context, service: service, withPathParameters: parameters) else {
            os_log("Fail to Build URL using the given host and context", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        taskManager(usingUrl: url, httpMethod: .get, headersKey: headersKey, completion: completion)
    }
    
    public func post<E: Encodable, D: Decodable, ER: Decodable>(to service: String, withBody body: E, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, completion: @escaping (Result<D, ErrorObject<ER>>) -> ()) {
        guard let hostAndContext = config.getHostAndContext(forKey: hostAndContextKey) else {
            os_log("No Host and Context Found to the Key Provided", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        guard let url = buildUrl(usingHost: hostAndContext.host, context: hostAndContext.context, andService: service) else {
            os_log("Fail to Build URL using the given host and context", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        taskManager(usingUrl: url, httpMethod: .post, headersKey: headersKey, bodyParameter: body, completion: completion)
    }
    
    public func put<E: Encodable, D: Decodable, ER: Decodable>(on service: String, withBody body: E, andQueryParameters parameters: [String : String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, completion: @escaping (Result<D, ErrorObject<ER>>) -> ()) {
        guard let hostAndContext = config.getHostAndContext(forKey: hostAndContextKey) else {
            os_log("No Host and Context Found to the Key Provided", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        guard let url = buildUrl(usingHost: hostAndContext.host, context: hostAndContext.context, service: service, withQueryParameters: parameters ?? nil) else {
            os_log("Fail to Build URL using the given host and context", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        taskManager(usingUrl: url, httpMethod: .put, headersKey: headersKey, bodyParameter: body, completion: completion)
    }
    
    public func put<E: Encodable, D: Decodable, ER: Decodable>(on service: String, withBody body: E, andPathParameters parameters: [String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, completion: @escaping (Result<D, ErrorObject<ER>>) -> ()) {
        guard let hostAndContext = config.getHostAndContext(forKey: hostAndContextKey) else {
            os_log("No Host and Context Found to the Key Provided", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        guard let url = buildUrl(usingHost: hostAndContext.host, context: hostAndContext.context, service: service, withPathParameters: parameters ?? nil) else {
            os_log("Fail to Build URL using the given host and context", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        taskManager(usingUrl: url, httpMethod: .put, headersKey: headersKey, bodyParameter: body, completion: completion)
    }
    
    public func delete<D: Decodable, ER: Decodable>(from service: String, withQueryParameters parameters: [String : String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, completion: @escaping (Result<D, ErrorObject<ER>>) -> ()) {
        guard let hostAndContext = config.getHostAndContext(forKey: hostAndContextKey) else {
            os_log("No Host and Context Found to the Key Provided", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        guard let url = buildUrl(usingHost: hostAndContext.host, context: hostAndContext.context, service: service, withQueryParameters: parameters ?? nil) else {
            os_log("Fail to Build URL using the given host and context", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        taskManager(usingUrl: url, httpMethod: .delete, headersKey: headersKey, completion: completion)
    }
    
    public func delete<D: Decodable, ER: Decodable>(from service: String, withPathParameters parameters: [String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, completion: @escaping (Result<D, ErrorObject<ER>>) -> ()) {
        guard let hostAndContext = config.getHostAndContext(forKey: hostAndContextKey) else {
            os_log("No Host and Context Found to the Key Provided", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        guard let url = buildUrl(usingHost: hostAndContext.host, context: hostAndContext.context, service: service, withPathParameters: parameters ?? nil) else {
            os_log("Fail to Build URL using the given host and context", log: OSLog.HTTPLayer, type: .debug)
            return
        }
        taskManager(usingUrl: url, httpMethod: .delete, headersKey: headersKey, completion: completion)
    }

}
