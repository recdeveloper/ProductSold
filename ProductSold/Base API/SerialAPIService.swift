//
//  SerialAPIService.swift
//  ProductSold
//
//  Created by Rob Caraway on 2/14/20.
//  Copyright © 2020 Rob Caraway. All rights reserved.
//

import Foundation

enum Result<T> {
    case error(Error?)
    case success(T)
}

class SerialAPIService {
    let session: URLSession
    private var loadingMap = [String: Bool]()
    
    init() {
        let queue = OperationQueue()
        queue.name = "com.ProductSold.highPriority"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInitiated
        session = URLSession(configuration: .default, delegate: nil, delegateQueue: queue)
    }
    
    func loadRequest<T: Decodable>(request: URLRequest, responseType: T.Type, _ completion: @escaping (Result<T>) -> Void) {
        let isLoading = loadingMap[mapString(from: request)]
        guard isLoading == nil || isLoading == false else { return }
        
        loadingMap[mapString(from: request)] = true
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data,
                let objectResponse = try? JSONDecoder().decode(responseType, from: data) {
                DispatchQueue.main.async {
                    completion(.success(objectResponse))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.error(error))
                }
            }
            self.loadingMap[self.mapString(from: request)] = false
        }
        task.resume()
    }
    
    //NOTE: using this rather than URLRequest itself since it doesn't equate httpBody, headers
    //TODO: convert this to Hashable compatibility with URLRequest
    private func mapString(from request: URLRequest) -> String {
        var body: String = ""
        if let httpBody = request.httpBody {
            body = String(data: httpBody, encoding: .utf8) ?? ""
        }
        let headers = request.allHTTPHeaderFields?.values.reduce("", +) ?? ""
        return "\(request.url?.absoluteString ?? "")\(request.httpMethod ?? "")\(body)\(headers)"
    }
}
