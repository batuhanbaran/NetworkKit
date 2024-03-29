//
//  DataDecoder.swift
//  
//
//  Created by Batuhan Baran on 7.04.2023.
//

import Foundation

final class DataDecoder<T: NetworkTask>: JSONDecoder {
    
    private var task: T
    private var data: Data
    
    init(task: T, with data: Data) {
        self.task = task
        self.data = data
        
        super.init()
    }
    
    func decode(
        by status: HTTPStatusCode
    ) throws -> Codable {
        switch status {
        case .ok:
            let json = try super.decode(T.ResponseModel.self, from: data)
            return json
        case .serverError:
            throw NetworkError.nonValidStatusCode
        case .unknown:
            throw NetworkError.unknown
        }
    }
}
