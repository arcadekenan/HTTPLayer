//
//  HTTPManager.swift
//  HTTPLayer
//
//  Created by Davi Bispo on 05/04/19.
//  Copyright © 2019 Arkd. All rights reserved.
//

import Foundation
import os.log

class HTTPManager: NSObject, URLSessionDelegate {
    
    private var config: HTTPConfig
    private var security: HTTPSecurity
    public init(_ config: HTTPConfig, _ security: HTTPSecurity) {
        self.config = config
        self.security = security
    }
    
    enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    enum PinningResult {
        case success
        case failed
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
    
    fileprivate func taskManager<D: Decodable, ER: Decodable>(usingUrl url: URL, httpMethod: HttpMethod, headersKey: String?, completion: @escaping (Result<ResponseObject<D>, ErrorObject<ER>>) -> ()) {
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        if let keyVerified = headersKey, let headers = config.getHeaders(forKey: keyVerified) {
            headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        } else {
            os_log("No Headers Setted or Found by the Key Provided", log: OSLog.HTTPLayer, type: .debug)
        }
        let task = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: self, delegateQueue: nil).dataTask(with: request) { (data, response, error) in
            guard let data = data else { completion(.failure(ErrorObject(response: nil, error: error!))); return }
            let httpCodeValidation = self.handle(HTTPStatusCode: (response as! HTTPURLResponse).statusCode)
            os_log("Status Code: %d - %s", (response as! HTTPURLResponse).statusCode, httpCodeValidation.message)
            if httpCodeValidation.continue {
                do {
                    let responseObj = try JSONDecoder().decode(D.self, from: data)
                    completion(.success(ResponseObject(response: responseObj, headers: (response as! HTTPURLResponse).allHeaderFields)))
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
    
    fileprivate func taskManager<E: Encodable, D: Decodable, ER: Decodable>(usingUrl url: URL, httpMethod: HttpMethod, headersKey: String?, bodyParameter: E, completion: @escaping (Result<ResponseObject<D>, ErrorObject<ER>>) -> ()) {
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
        let task = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: self, delegateQueue: nil).dataTask(with: request) { (data, response, error) in
            guard let data = data else { completion(.failure(ErrorObject(response: nil, error: error!))); return }
            let httpCodeValidation = self.handle(HTTPStatusCode: (response as! HTTPURLResponse).statusCode)
            os_log("Status Code: %d - %s", (response as! HTTPURLResponse).statusCode, httpCodeValidation.message)
            if httpCodeValidation.continue {
                do {
                    let responseObj = try JSONDecoder().decode(D.self, from: data)
                    completion(.success(ResponseObject(response: responseObj, headers: (response as! HTTPURLResponse).allHeaderFields)))
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
    
    fileprivate func setupPinner(_ host: String, _ hashes: [String]) -> HTTPPinner {
        let pinner = HTTPPinner(host, security)
        hashes.forEach { hash in
            pinner.addCertificateHash(hash)
        }
        
        return pinner
    }
    
    fileprivate func validate(pinner: HTTPPinner, trust: SecTrust, challenge: URLAuthenticationChallenge) -> (isTrustChainValid: Bool, trustPublicKeysResult: PinningResult){
        
        var isTrustChainValid = true
        if (!pinner.validateCertificateTrustChain(trust)) {
            os_log("Invalid Certificate Chain", log: OSLog.HTTPLayer, type: .debug)
            isTrustChainValid = false
        }
        
        if (pinner.validateTrustPublicKeys(trust)) {
            return (isTrustChainValid, .success)
        } else {
            os_log("Pinning Activated: Being Challenged", log: OSLog.HTTPLayer, type: .debug)
            print("couldn't validate trust for \(challenge.protectionSpace.host)")
            return (isTrustChainValid, .failed)
        }
    }
    
    fileprivate func validate(certificateFile cert: Data, trust: SecTrust, challenge: URLAuthenticationChallenge) -> PinningResult {
        let certificate =  SecTrustGetCertificateAtIndex(trust, 0)
        let policies = NSMutableArray()
        policies.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
        SecTrustSetPolicies(trust, policies)
        var result:SecTrustResultType =  SecTrustResultType(rawValue: 0)!
        SecTrustEvaluate(trust, &result)
        let isServerTRusted: Bool = (result == SecTrustResultType.unspecified || result == SecTrustResultType.proceed)
        let remoteCertificateData: NSData = SecCertificateCopyData(certificate!)
        if(isServerTRusted && remoteCertificateData.isEqual(to: cert)){
            return .success
        }
        else{
            return .failed
        }
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if security.getPinning() {
            os_log("Pinning Activated: Being Challenged", log: OSLog.HTTPLayer, type: .debug)
            guard let trust = challenge.protectionSpace.serverTrust else {
                os_log("Invalid Server Trust", log: OSLog.HTTPLayer, type: .debug)
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            let credential = URLCredential(trust: trust)
            
            if !security.getAllHashesToHost().isEmpty {
                if let hash = security.getAllHashesToHost()[challenge.protectionSpace.host] {
                    let validationResult = validate(pinner: setupPinner(challenge.protectionSpace.host, hash), trust: trust, challenge: challenge)
                    if validationResult.isTrustChainValid {
                        challenge.sender?.cancel(challenge)
                    }
                    if validationResult.trustPublicKeysResult == .success {
                        os_log("Challenge Won", log: OSLog.HTTPLayer, type: .debug)
                        completionHandler(.useCredential, credential)
                    } else if validationResult.trustPublicKeysResult == .failed {
                        os_log("Challenge Lost, couldn't validate Trust Public Keys", log: OSLog.HTTPLayer, type: .debug)
                        completionHandler(.cancelAuthenticationChallenge, nil)
                    }
                }
            } else if !security.getAllFileToHost().isEmpty {
                if let data = security.getAllFileToHost()[challenge.protectionSpace.host], let cert = data {
                    let validationResult = validate(certificateFile: cert, trust: trust, challenge: challenge)
                    if validationResult == .success {
                        os_log("Challenge Won", log: OSLog.HTTPLayer, type: .debug)
                        completionHandler(.useCredential, credential)
                    } else if validationResult == .failed {
                        os_log("Challenge Lost, couldn't validate Trust Public Keys", log: OSLog.HTTPLayer, type: .debug)
                        completionHandler(.cancelAuthenticationChallenge, nil)
                    }
                }
            }
            if security.getContinueWithoutPinning() {
                os_log("Challenge Canceled, no host and/or certificates found but continuing as Default anyways", log: OSLog.HTTPLayer, type: .debug)
                completionHandler(.performDefaultHandling, nil)
            } else {
                os_log("Challenge Canceled, no host and/or certificates found", log: OSLog.HTTPLayer, type: .debug)
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        }
        completionHandler(.performDefaultHandling, nil)
    }
    
    public func get<D: Decodable, ER: Decodable>(from service: String, withHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, completion: @escaping (Result<ResponseObject<D>, ErrorObject<ER>>) -> ()) {
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
    
    public func get<D: Decodable, ER: Decodable>(from service: String, usingQueryParameters parameters: [String : String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, completion: @escaping (Result<ResponseObject<D>, ErrorObject<ER>>) -> ()) {
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
    
    public func get<D: Decodable, ER: Decodable>(from service: String, usingPathParameters parameters: [String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, completion: @escaping (Result<ResponseObject<D>, ErrorObject<ER>>) -> ()) {
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
    
    public func post<E: Encodable, D: Decodable, ER: Decodable>(to service: String, withBody body: E, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, completion: @escaping (Result<ResponseObject<D>, ErrorObject<ER>>) -> ()) {
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
    
    public func put<E: Encodable, D: Decodable, ER: Decodable>(on service: String, withBody body: E, andQueryParameters parameters: [String : String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, completion: @escaping (Result<ResponseObject<D>, ErrorObject<ER>>) -> ()) {
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
    
    public func put<E: Encodable, D: Decodable, ER: Decodable>(on service: String, withBody body: E, andPathParameters parameters: [String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, completion: @escaping (Result<ResponseObject<D>, ErrorObject<ER>>) -> ()) {
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
    
    public func delete<D: Decodable, ER: Decodable>(from service: String, withQueryParameters parameters: [String : String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, completion: @escaping (Result<ResponseObject<D>, ErrorObject<ER>>) -> ()) {
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
    
    public func delete<D: Decodable, ER: Decodable>(from service: String, withPathParameters parameters: [String]?, fromHostAndContext hostAndContextKey: String, andHeaders headersKey: String?, completion: @escaping (Result<ResponseObject<D>, ErrorObject<ER>>) -> ()) {
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
