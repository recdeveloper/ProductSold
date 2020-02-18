//
//  PageSession.swift
//  ProductSold
//
//  Created by Rob Caraway on 2/18/20.
//  Copyright © 2020 Rob Caraway. All rights reserved.
//

import Foundation

class PageSession {
    private(set) var page = 0
    let limit = 50
}

extension PageSession {
    func increment() {
        page += 1
    }
}
