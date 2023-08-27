//
//  NetworkService.swift
//
//  Created by Batuhan Baran on 25.01.2023.
//

import Foundation

public protocol NetworkServiceProtocol {
    func perform<T: NetworkTask>(task: T, completion: @escaping (Result<T.ResponseModel?, NetworkError>) -> ())
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
    public func perform<T>(
        task: T,
        completion: @escaping (Result<T.ResponseModel?, NetworkError>) -> ()
    ) where T : NetworkTask {
        do {
            
            let urlRequest = try task.urlRequest()
            resume(task: task, for: urlRequest, completion: completion)
            
        } catch {
            completion(.failure(.urlRequest))
        }
    }
    
}

fileprivate extension NetworkService {
    
    private func resume<T>(
        task: T,
        for urlRequest: URLRequest,
        completion: @escaping (Result<T.ResponseModel?, NetworkError>) -> ()
    ) where T : NetworkTask {
        session.dataTask(with: urlRequest) { data, urlResponse, error in
            guard error == nil else {
                completion(.failure(.urlSession(localizedDescription: error?.localizedDescription ?? "")))
                return
            }
            
            guard let hTTPURLResponse = urlResponse as? HTTPURLResponse else {
                completion(.failure(.responseError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.data))
                return
            }
            
            self.handle(task: task, for: hTTPURLResponse, with: data, completion: completion)
            
        }.resume()
    }
    
    private func handle<T>(
        task: T,
        for urlResponse: HTTPURLResponse,
        with data: Data,
        completion: @escaping (Result<T.ResponseModel?, NetworkError>) -> ()
    ) where T : NetworkTask {
        let statusCode = HTTPStatusCode(urlResponse.statusCode)
        
        switch statusCode {
        case .ok, .serverError:
            self.decodeData(task: task, by: statusCode, with: data, completion: completion)
            
        case .unknown:
            completion(.failure(.unknown))
        }
    }
    
    private func decodeData<T>(
        task: T,
        by statusCode: HTTPStatusCode,
        with data: Data,
        completion: @escaping (Result<T.ResponseModel?, NetworkError>) -> ()
    ) where T : NetworkTask {
        let jsonDecoder = DataDecoder(task: task, with: data)
        
        do {
            
            let json = try jsonDecoder.decode(by: statusCode)
            completion(.success(json as? T.ResponseModel))
            
        } catch {
            completion(.failure(.decoding))
        }
    }
    
}
