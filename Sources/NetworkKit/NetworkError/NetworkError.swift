//
//  NetworkError.swift
//
//  Created by Batuhan Baran on 10.02.2023.
//

import Foundation

public enum NetworkError: Error {
    case reachability
    case url
    case responseError
    case urlRequest
    case urlResponse
    case data
    case decoding
    case encoding
    case serviceError(model: Codable)
    case httpError(Data, HTTPURLResponse)
    case urlSession(localizedDescription: String)
    case custom(localizedDescription: String)
    case nonValidStatusCode
    case unknown
}
