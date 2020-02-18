//
//  StyleSession.swift
//  ProductSold
//
//  Created by Rob Caraway on 2/18/20.
//  Copyright © 2020 Rob Caraway. All rights reserved.
//

import Foundation

class StyleSession: ListingTableDataSource {
    
    var styles: [String]?
    
    func getItem(at index: Int) -> String? {
        guard let styles = styles,
            index >= 0 && index < styles.count else { return nil }
        return styles[index]
    }
    
    func itemCount() -> Int { styles?.count ?? 0 }
    func allowsDeletion() -> Bool { false }
}
