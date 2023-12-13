//
//  DataEncoder.swift
//  
//
//  Created by Batuhan Baran on 10.04.2023.
//

import Foundation

final class DataEncoder: JSONEncoder {
    
    private var body: Codable?
    
    init(
        body: Codable?
    ) {
        self.body = body
        
        super.init()
    }
    
    func encode() throws -> Data? {
        guard let body else { return nil }
        
        return try super.encode(body.self)
    }
}
