//
//  NetworkService.swift
//
//  Created by Batuhan Baran on 25.01.2023.
//

import Alamofire
import Combine
import Foundation

public protocol NetworkServiceProtocol {
    @available(iOS 13.0, *)
    func perform<T: NetworkTask>(task: T) -> AnyPublisher<T.Response, NetworkError>
    
    func perform<T: NetworkTask>(task: T, completion: @escaping (Result<T.Response?, NetworkError>) -> ())
}

public final class NetworkService: NetworkServiceProtocol {
    
    // MARK: - Private properties
    private var reachablity = NetworkReachabilityManager.default
    
    private let session: Session = {
        let manager = ServerTrustManager(evaluators: ["newsapi.org": DisabledTrustEvaluator()])
        let configuration = URLSessionConfiguration.af.default
        let session = Session(configuration: configuration, serverTrustManager: manager)
        return session
    }()
    
    private var isReachable: Bool {
        reachablity?.isReachable ?? false
    }
    
    // MARK: - Public properties
    public static let shared: NetworkService = NetworkService()
    
    // MARK: - Initializer
    public init() {}
    
    // MARK: - Methods
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
            switch result.result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(NetworkError.alamofire(wrapped: error)))
            }
        }
    }
}
