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
    associatedtype ServerErrorModel: Codable
    
    var requestBody: RequestModel { get }
    var queryItems: [URLQueryItem]? { get }
    var baseUrl: URL { get set }
    var path: String { get set }
    var allHTTPHeaderFields: HTTPHeaders? { get set }
    var httpMethod: HTTPMethod { get set }
    var timeoutInterval: Double? { get }
}

public extension NetworkTask {
    var timeoutInterval: Double? { return nil }
    var queryItems: [URLQueryItem]? { return nil }
}

extension NetworkTask {
    
    func urlRequest() throws -> URLRequest {
        guard let url = URL(string: path, relativeTo: baseUrl) else { throw NetworkError.url }
        
        var urlRequest = URLRequest(url: url)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        urlComponents?.queryItems      = queryItems
        urlRequest.url                 = urlComponents?.url
        urlRequest.httpMethod          = httpMethod.rawValue
        urlRequest.httpBody            = try? DataEncoder(requestBody: requestBody).encode()
        urlRequest.allHTTPHeaderFields = allHTTPHeaderFields
        urlRequest.timeoutInterval     = timeoutInterval ?? 60.0
        
        return urlRequest
    }
}
