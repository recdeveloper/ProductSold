//
//  Product.swift
//  ProductSold
//
//  Created by Rob Caraway on 2/18/20.
//  Copyright © 2020 Rob Caraway. All rights reserved.
//

import Foundation


//TODO: create a unifying protocol BaseProduct

struct Product: Decodable {
    let name: String
    let description: String
    let style: String
    let brand: String
    let shippingPrice: Int
    let id: Int
    
    enum CodingKeys: String, CodingKey {
        case name = "product_name"
        case description
        case shippingPrice = "shipping_price"
        case style
        case brand
        case id
    }
}

struct ProductRequest: Encodable {
    let product_name: String
    let description: String
    let style: String
    let brand: String
    let shipping_price: Int
}

extension Product {
    func toRequest() -> ProductRequest {
        return ProductRequest(product_name: name, description: description, style: style, brand: brand, shipping_price: shippingPrice)
    }
}


