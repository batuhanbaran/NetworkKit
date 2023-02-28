//
//  NetworkError.swift
//
//  Created by Batuhan Baran on 10.02.2023.
//

import Alamofire
import Foundation

public enum NetworkError: Error {
    case reachability
    case url
    case responseError
    case alamofire(wrapped: AFError)
    
    var reason: String {
        switch self {
        case .reachability:
            return "No internet connection."
        case .url:
            return "URL is nil."
        case .responseError:
            return "Response is nil."
        case .alamofire(let wrapped):
            return wrapped.localizedDescription
        }
    }
}
