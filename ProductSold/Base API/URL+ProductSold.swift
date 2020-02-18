//
//  URL+ProductSold.swift
//  ProductSold
//
//  Created by Rob Caraway on 2/14/20.
//  Copyright © 2020 Rob Caraway. All rights reserved.
//

import Foundation


typealias Host = String

//FIXME: would make this an enum if we had several hosts to keep track of
extension Host {
    static func productSoldHost() -> String {
        return "cscodetest.herokuapp.com"
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
}

extension URL {
    
    static func productSoldURL(with path: String, queryItems:[URLQueryItem]? = nil) -> URL? {
        var components = URLComponents()
        components.host = Host.productSoldHost()
        components.scheme = "https" //TODO: https to constant variable
        components.path = "/api\(path)"
        components.queryItems = queryItems
        return components.url
    }

}
