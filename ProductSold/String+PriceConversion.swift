//
//  String+PriceConversion.swift
//  ProductSold
//
//  Created by Rob Caraway on 2/18/20.
//  Copyright © 2020 Rob Caraway. All rights reserved.
//

import Foundation

extension String {
    func toPrice() -> Int {
        let string = replacingOccurrences(of: "$", with: "")
        if let floatValue = Float(string) {
            return Int(floatValue * 100)
        }
        return 0
    }
}

extension Int {
    func priceString() -> String {
        return "$\(Float(self) / 100.0)"
    }
}
