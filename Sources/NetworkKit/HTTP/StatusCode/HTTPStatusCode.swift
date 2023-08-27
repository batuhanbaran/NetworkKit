//
//  HTTPStatusCode.swift
//  
//
//  Created by Batuhan Baran on 10.04.2023.
//

import Foundation

enum HTTPStatusCode {
    case ok
    case serverError
    case unknown
    
    init(_ statusCode: Int) {
        switch statusCode {
        case 200 ..< 300:
            self = .ok
            
        case 400 ..< 500:
            self = .serverError
            
        default:
            self = .unknown
        }
    }
}
