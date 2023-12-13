//
//  NetworkService.swift
//
//  Created by Batuhan Baran on 25.01.2023.
//

import Foundation
import Combine

public protocol NetworkServiceProtocol {
    func perform<T: NetworkTask>(
        _ task: T,
        completionHandler: @escaping (Result<Codable, NetworkError>) -> ()
    )
    
    @available(iOS 15.0, *)
    func perform<T: NetworkTask>(_ task: T) async throws -> Codable
    
    @available(iOS 13.0, *)
    func perform<T: NetworkTask>(_ task: T) -> AnyPublisher<Codable, NetworkError>
}

public final class NetworkService: NetworkServiceProtocol {
    
    // MARK: - Private properties
    private var session: URLSession = {
        let session = URLSession(configuration: .default)
        return session
    }()
    
    // MARK: - Public properties
    public static let shared: NetworkService = NetworkService()
    
    // MARK: - Initializer
    public init() {}
    
    // MARK: - Methods
    public func perform<T>(
        _ task: T,
        completionHandler: @escaping (Result<Codable, NetworkError>) -> ()
    ) where T : NetworkTask {
        do {
            
            let urlRequest = try task.urlRequest()
            resume(task, for: urlRequest, completionHandler: completionHandler)
            
        } catch {
            completionHandler(.failure(.urlRequest))
        }
    }
    
    @available(iOS 15.0, *)
    public func perform<T>(_ task: T) async throws -> Codable where T : NetworkTask {
        do {
            
            let urlRequest = try task.urlRequest()
            let (data, urlResponse) = try await session.data(for: urlRequest)
            
            return try await handle(task, for: urlResponse, with: data)
            
        } catch {
            throw NetworkError.urlRequest
        }
    }
    
    @available(iOS 13.0, *)
    public func perform<T>(_ task: T) -> AnyPublisher<Codable, NetworkError> where T : NetworkTask {
        do {
            
            let urlRequest = try task.urlRequest()
            return session.dataTaskPublisher(for: urlRequest)
                   .tryMap { data, urlResponse in
                       guard let httpUrlResponse = urlResponse as? HTTPURLResponse else {
                           throw NetworkError.urlResponse
                       }
                       
                       let hTTPStatusCode = HTTPStatusCode(httpUrlResponse.statusCode)
                       return try DataDecoder(task: task, with: data).decode(by: hTTPStatusCode)
                       
                   }.mapError { error in
                       return NetworkError.custom(localizedDescription: error.localizedDescription)
                   }
                   .eraseToAnyPublisher()
            
        } catch {
            return Fail(error: NetworkError.urlRequest).eraseToAnyPublisher()
        }
    }
}

extension NetworkService {
    
    private func resume<T>(
        _ task: T,
        for urlRequest: URLRequest,
        completionHandler: @escaping (Result<Codable, NetworkError>) -> ()
    ) where T : NetworkTask {
        session.dataTask(with: urlRequest) { data, urlResponse, error in
            self.handle(task, for: urlResponse, with: data, completionHandler: completionHandler)
        }.resume()
    }
    
    private func handle<T>(
        _ task: T,
        for urlResponse: URLResponse?,
        with data: Data?,
        completionHandler: @escaping (Result<Codable, NetworkError>) -> ()
    ) where T : NetworkTask {
        guard let data else {
            completionHandler(.failure(.data))
            return
        }
        
        guard let httpUrlResponse = urlResponse as? HTTPURLResponse else {
            completionHandler(.failure(.urlResponse))
            return
        }
        
        self.decode(task, for: httpUrlResponse, with: data, completionHandler: completionHandler)
    }
    
    private func decode<T>(
        _ task: T,
        for httpUrlResponse: HTTPURLResponse,
        with data: Data,
        completionHandler: @escaping (Result<Codable, NetworkError>) -> ()
    ) where T : NetworkTask {
        let jsonDecoder = DataDecoder(task: task, with: data)
        let hTTPStatusCode = HTTPStatusCode(httpUrlResponse.statusCode)
        
        do {
            let json = try jsonDecoder.decode(by: hTTPStatusCode)
            completionHandler(.success(json))
            
        } catch {
            completionHandler(.failure(.decoding))
        }
    }
    
}

extension NetworkService {
    
    private func handle<T>(
        _ task: T,
        for urlResponse: URLResponse,
        with data: Data
    ) async throws -> Codable where T : NetworkTask {
        guard let httpUrlResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkError.urlResponse
        }
        
        return try await decode(task, for: httpUrlResponse, with: data)
    }
    
    private func decode<T>(
        _ task: T,
        for httpUrlResponse: HTTPURLResponse,
        with data: Data
    ) async throws -> Codable where T : NetworkTask {
        let jsonDecoder = DataDecoder(task: task, with: data)
        let hTTPStatusCode = HTTPStatusCode(httpUrlResponse.statusCode)
        
        do {
            return try jsonDecoder.decode(by: hTTPStatusCode) as? T.ResponseModel
            
        } catch {
            throw NetworkError.decoding
        }
    }
    
}
