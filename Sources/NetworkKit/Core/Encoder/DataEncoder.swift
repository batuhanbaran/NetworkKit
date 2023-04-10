//
//  DataEncoder.swift
//  
//
//  Created by Batuhan Baran on 10.04.2023.
//

import Foundation

final class DataEncoder: JSONEncoder {
    
    private var request: Codable
    
    init(request: Codable) {
        self.request = request
        
        super.init()
    }
    
    func encodeAsDictionary() throws -> [String: Any] {
        try request.asDictionary()
    }
    
    func encode() throws -> Data {
        try super.encode(request.self)
    }
}

fileprivate extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
