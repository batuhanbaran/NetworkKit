//
//  NetworkTask.swift
//
//  Created by Batuhan Baran on 25.01.2023.
//

import Foundation

public protocol NetworkTask {
    typealias HTTPHeaders = [String: String]
    
    associatedtype Request: Codable
    associatedtype Response: Codable
    associatedtype ServerError: Codable
    
    var url: URL? { get set }
    var method: HTTPMethodType { get }
    var headers: HTTPHeaders? { get set }
    var request: Request { get set }
    var serverError: ServerError? { get set }
}

extension NetworkTask {

    func urlRequest() throws -> URLRequest {
        guard let url = url else { throw NetworkError.url }
        
        var urlRequest = URLRequest(url: url)
        
        switch method {
        case .get, .delete:
            let encoder = DataEncoder(request: request)
            let encodedDictionary = try encoder.encodeAsDictionary()
            let urlComponents = prepareQueryItems(from: encodedDictionary)
           
            guard let url = urlComponents?.url else { throw NetworkError.url }
            
            urlRequest = URLRequest(url: url)
            
        case .post, .put:
            let encoder = DataEncoder(request: request)
            let encodedData = try encoder.encode()
            
            urlRequest.httpMethod = method.rawValue
            urlRequest.httpBody = encodedData
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        
        return urlRequest
    }
    
    private func prepareQueryItems(from dictionary: [String: Any]) -> URLComponents? {
        guard let url = url else { return nil }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = dictionary.map({ key, value in
            return URLQueryItem(name: key, value: value as? String)
        })
        
        return urlComponents
    }
    
}
