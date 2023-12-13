//
//  NetworkTask.swift
//
//  Created by Batuhan Baran on 25.01.2023.
//

import Foundation

public protocol NetworkTask {
    typealias HTTPHeaders = [String: String]
    
    associatedtype RequestModel: Codable
    associatedtype ResponseModel: Codable
    
    var body: Codable? { get }
    var queryItems: [URLQueryItem]? { get }
    var baseUrl: URL { get set }
    var path: String { get set }
    var timeoutInterval: Double? { get }
    var allHTTPHeaderFields: HTTPHeaders? { get set }
    var httpMethod: HTTPMethod { get set }
}

public extension NetworkTask {
    var timeoutInterval: Double? { return nil }
    var queryItems: [URLQueryItem]? { return nil }
    var body: Codable? { return nil }
}

extension NetworkTask {
    
    func urlRequest() throws -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme           = "https"
        urlComponents.host             = baseUrl.host
        urlComponents.path             = path
        urlComponents.queryItems       = queryItems
        
        guard let url = urlComponents.url else { throw NetworkError.url }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod          = httpMethod.rawValue
        urlRequest.httpBody            = try? DataEncoder(body: body).encode()
        urlRequest.allHTTPHeaderFields = allHTTPHeaderFields
        urlRequest.timeoutInterval     = timeoutInterval ?? 60.0
        
        return urlRequest
    }
}
