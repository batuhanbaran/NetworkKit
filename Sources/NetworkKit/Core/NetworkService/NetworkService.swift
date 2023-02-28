//
//  NetworkService.swift
//
//  Created by Batuhan Baran on 25.01.2023.
//

import Alamofire
import Combine
import Foundation

public protocol NetworkService {
    typealias Success = NetworkServiceTask.Response?
    typealias Failure = NetworkError
    
    typealias NetworkServiceResultBlock = (Result<Success, Failure>) -> ()
    
    @available(iOS 13.0, *)
    typealias NetworkServicePublisher = AnyPublisher<NetworkServiceTask.Response, Failure>
    
    associatedtype NetworkServiceTask: NetworkTask
    
    init(task: NetworkServiceTask)
    func perform(task: NetworkServiceTask, completion: @escaping NetworkServiceResultBlock)
}

extension NetworkService {
    
    private var session: Session {
        AF
    }
    
    private var isReachable: Bool {
        guard let reachabilityManager = NetworkReachabilityManager() else { return false }
        return reachabilityManager.isReachable
    }
    
    public func perform(task: NetworkServiceTask, completion: @escaping NetworkServiceResultBlock) {
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
        .responseDecodable(of: NetworkServiceTask.Response.self) { result in
            guard result.response != nil else {
                completion(.failure(.responseError))
                return
            }

            completion(.success(result.value))
        }
    }
    
    @available(iOS 13.0, *)
    public func perform(task: NetworkServiceTask) -> NetworkServicePublisher {
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
        .publishDecodable(type: NetworkServiceTask.Response.self)
        .value()
        .mapError { NetworkError.alamofire(wrapped: $0) }
        .eraseToAnyPublisher()
    }
}
