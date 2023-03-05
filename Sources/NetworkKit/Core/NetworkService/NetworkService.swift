//
//  NetworkService.swift
//
//  Created by Batuhan Baran on 25.01.2023.
//

import Alamofire
import Combine
import Foundation

public protocol NetworkServicing {
    @available(iOS 13.0, *)
    func perform<T: NetworkTask>(task: T) -> AnyPublisher<T.Response, NetworkError>
    
    func perform<T: NetworkTask>(task: T, completion: @escaping (Result<T.Response?, NetworkError>) -> ())
}

public struct NetworkService: NetworkServicing {

    public static let shared: NetworkService = NetworkService()
    
    public init() {}
    
    private var session = Session.default
    private var reachablity = NetworkReachabilityManager.default
    
    private var isReachable: Bool {
        reachablity?.isReachable ?? false
    }
    
    @available(iOS 13.0, *)
    public func perform<T>(task: T) -> AnyPublisher<T.Response, NetworkError> where T : NetworkTask {
        guard isReachable else {
            return Fail(error: NetworkError.reachability).eraseToAnyPublisher()
        }
        
        guard let url = task.url else {
            return Fail(error: NetworkError.url).eraseToAnyPublisher()
        }
        
        return session.request(url,
                               method: HTTPMethod(rawValue: task.method.rawValue),
                               parameters: task.request,
                               headers: HTTPHeaders(task.headers ?? [:]))
        .validate()
        .publishDecodable(type: T.Response.self)
        .value()
        .mapError { NetworkError.alamofire(wrapped: $0) }
        .eraseToAnyPublisher()
    }
    
    public func perform<T>(task: T, completion: @escaping (Result<T.Response?, NetworkError>) -> ()) where T : NetworkTask {
        guard isReachable else {
            completion(.failure(.reachability))
            return
        }
        
        guard let url = task.url else {
            completion(.failure(.url))
            return
        }
        
        session.request(url,
                        method: HTTPMethod(rawValue: task.method.rawValue),
                        parameters: task.request,
                        headers: HTTPHeaders(task.headers ?? [:]))
        .validate()
        .responseDecodable(of: T.Response.self) { result in
            guard result.response != nil else {
                completion(.failure(.responseError))
                return
            }

            completion(.success(result.value))
        }
    }
}
