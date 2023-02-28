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

    var url: URL? { get }
    var method: HTTPMethodType { get }
    var headers: HTTPHeaders? { get set }
    var request: Request { get set }
}
