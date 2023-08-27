//
//  DataEncoder.swift
//  
//
//  Created by Batuhan Baran on 10.04.2023.
//

import Foundation

final class DataEncoder: JSONEncoder {
    
    private var requestBody: Codable
    
    init(
        requestBody: Codable
    ) {
        self.requestBody = requestBody
        
        super.init()
    }
    
    func encode() throws -> Data? {
        guard !(requestBody is EmptyRequestModel) else { return nil }
        
        return try super.encode(requestBody.self)
    }
}
