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
    case data
    case decoding
    
    var reason: String {
        switch self {
        case .reachability:
            return "No internet connection."
        case .url:
            return "URL is nil."
        case .responseError:
            return "Response is nil."
        case .urlRequest:
            return "URLRequest cannot build."
        case .data:
            return "Data is nil."
        case .decoding:
            return "Decoding error."
        }
    }
}
