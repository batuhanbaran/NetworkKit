//
//  NetworkService.swift
//
//  Created by Batuhan Baran on 25.01.2023.
//

import Foundation

public protocol NetworkServiceProtocol {
    func perform<T: NetworkTask>(task: T, completion: @escaping (Result<T.Response?, NetworkError>) -> ())
}

public final class NetworkService: NetworkServiceProtocol {
    
    // MARK: - Private properties
    private let session: URLSession = {
        let session = URLSession(configuration: .default)
        return session
    }()
    
    // MARK: - Public properties
    public static let shared: NetworkService = NetworkService()
    
    // MARK: - Initializer
    public init() {}
    
    // MARK: - Methods
    public func perform<T>(task: T, completion: @escaping (Result<T.Response?, NetworkError>) -> ()) where T : NetworkTask {
        do {
            
            let urlRequest = try task.makeURLRequest()
            
            session.dataTask(with: urlRequest) { data, response, error in
                guard let data = data else {
                    completion(.failure(.data))
                    return
                }
                
                self.decodeData(for: data, with: task, completion: completion)
            }
            
        } catch {
            completion(.failure(.urlRequest))
        }
        
    }
    
}

fileprivate extension NetworkService {
    
    private func decodeData<T>(for data: Data,
                               with task: T,
                               completion: @escaping (Result<T.Response?, NetworkError>) -> ()) where T : NetworkTask {
        let jsonDecoder = DataDecoder(task: task, with: data)
        
        do {
            
            let json = try jsonDecoder.decode()
            completion(.success(json))
            
        } catch {
            completion(.failure(.decoding))
        }
    }
    
}
