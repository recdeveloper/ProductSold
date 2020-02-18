//
//  ProductAPIService.swift
//  ProductSold
//
//  Created by Rob Caraway on 2/12/20.
//  Copyright © 2020 Rob Caraway. All rights reserved.
//

import Foundation

struct ProductRequestInfo {
    let path: String
    let method: String
    let queryItems: [URLQueryItem]
}

enum ProductPath: String {
    case list = "/products"
    case create = "/product"
    case edit = "/product/"
    case styles = "/styles"
}

extension URLRequest {
    
    //TODO: This should probably be a factory class
    static func productRequest(path: ProductPath, pathValue: String? = nil, token: UserToken, method: HTTPMethod = .get, queryItems:[URLQueryItem]? = nil) -> URLRequest? {
        guard let url = URL.productSoldURL(with: path.rawValue + (pathValue ?? ""), queryItems: queryItems) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if method == .post || method == .put {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}


private struct StylesResponse: Decodable {
    let styles: [String]?
}

private struct ProductResponse: Decodable {
    let products: [Product]
}

private struct ProductChangeResponse: Decodable {
    let message: String
    let id: Int
    enum CodingKeys: String, CodingKey {
        case id = "product_id"
        case message
    }
}

//TODO: Move to an observable pattern using RxSwift, PromiseKit, Combine
class ProductAPIService: SerialAPIService {
    private let jwtToken: UserToken
    
    init(token: UserToken) {
        jwtToken = token
    }
    
    //TODO: proper guard fail handling
    func loadProducts(page: Int = 0, limit: Int = 50, _ completion: @escaping ([Product]?) -> Void) {
        var queryItems = [URLQueryItem]()
        if page > 0 {
            queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
        }
        if limit > 0 && limit != 50 {
            queryItems.append(URLQueryItem(name: "limit", value: "\(limit)"))
        }
        guard let request = URLRequest.productRequest(path: .list, token: jwtToken, queryItems: queryItems) else { return }
        loadRequest(request: request, responseType: ProductResponse.self) { result in
            switch result {
            case let .success(response):
                completion(response.products)
            default:
                completion(nil) //TODO: handle error
            }
        }
    }
    
    func addProduct(_ product: ProductRequest, _ completion: @escaping (Bool) -> Void) {
        guard var request = URLRequest.productRequest(path: .create, token: jwtToken, method: .post),
            let jsonBody = try? JSONEncoder().encode(product) else { return }
        request.httpBody = jsonBody
        loadRequest(request: request, responseType: ProductChangeResponse.self) { result in
            switch result {
            case .success(_):
                completion(true)
            default:
                completion(false) //TODO: handle error
            }
        }
    }
    
    func editProduct(_ product: Product, _ completion: @escaping (Bool) -> Void) {
        let productRequest = product.toRequest()
        guard var request = URLRequest.productRequest(path: .edit, pathValue: "\(product.id)", token: jwtToken, method: .put),
            let jsonBody = try? JSONEncoder().encode(productRequest) else { return }
        request.httpBody = jsonBody
        loadRequest(request: request, responseType: ProductChangeResponse.self) { result in
            switch result {
            case .success(_):
                completion(true)
            default:
                completion(false) //TODO: handle error
            }
        }
    }
    
    func deleteProduct(_ productId: Int, _ completion:@escaping (Bool) -> Void) {
        guard let request = URLRequest.productRequest(path: .edit, pathValue: "\(productId)", token: jwtToken, method: .delete)
            else { return }
        loadRequest(request: request, responseType: ProductChangeResponse.self) { result in
            switch result {
            case .success(_):
                completion(true)
            default:
                completion(false) //TODO: handle error
            }
        }
    }
    
    func loadStyles(_ completion: @escaping ([String]?) -> Void) {
        guard let request = URLRequest.productRequest(path: .styles, token: jwtToken) else { return }
        loadRequest(request: request, responseType: StylesResponse.self) { (result) in
            switch result {
            case let .success(response):
                completion(response.styles)
            default: completion(nil) //TODO: handle error
            }
        }
    }
}
