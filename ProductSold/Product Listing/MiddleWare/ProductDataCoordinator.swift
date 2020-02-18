//
//  ProductDataCoordinator.swift
//  ProductSold
//
//  Created by Rob Caraway on 2/12/20.
//  Copyright © 2020 Rob Caraway. All rights reserved.
//

import Foundation

protocol ProductDataDelegate: AnyObject {
    func productsUpdated()
    func productUpdated(_ product: Product)
    func stylesUpdated()
    func productAdded()
}

class ProductDataCoordinator {
    let apiService: ProductAPIService
    private var products:[Product]?
    var pageSession: PageSession?
    let styleSession = StyleSession()
    weak var delegate: ProductDataDelegate?
    
    init(token: UserToken) {
        apiService = ProductAPIService(token: token)
    }
    
    func getProduct(at index: Int) -> Product? {
        guard let products = products,
        index < products.count && index >= 0 else { return nil }
        return products[index]
    }
    
    func getStyle(at index: Int) -> String? {
        guard let styles = styleSession.styles,
            index >= 0 && index < styles.count else { return nil }
        return styles[index]
    }
    
    func loadProducts() {
        pageSession = PageSession()
        apiService.loadProducts { products in
            self.products = products
            self.delegate?.productsUpdated()
            self.pageSession?.increment()
        }
    }
    
    func loadStyles() {
        apiService.loadStyles { styles in
            self.styleSession.styles = styles
            self.delegate?.stylesUpdated()
        }
    }
    
    func updateProduct(product: Product) {
        apiService.editProduct(product) { success in
            //TODO: could call reload of product to verify its true source of truth
            if success,
                var products = self.products,
                let index = products.firstIndex(where: { $0.id == product.id }) {
                products[index] = product
                self.products = products
                self.delegate?.productUpdated(product)
                self.delegate?.productsUpdated()
            } //TODO: share failure to listener
        }
    }
    
    func createProduct(from request: ProductRequest) {
        apiService.addProduct(request) { success in
            guard success else { return } //FIXME: handle failure
            self.loadProducts() //TODO: chain together observables
            self.delegate?.productAdded()
        }
    }
    
    func deleteProduct(at index: Int) {
        guard let product = getProduct(at: index) else { return }
        apiService.deleteProduct(product.id) { deleted in
            if var products = self.products {
                products.remove(at: index) //TODO: requires thread locking to be more accurate
                self.products = products
                self.delegate?.productsUpdated() //TODO: update by deleting single row
            }
        }
    }
    
    private func loadNextPage() {
        guard let pageSession = pageSession else { return }
        apiService.loadProducts(page: pageSession.page, limit: pageSession.limit) { products in
            if let products = products {
                self.products?.append(contentsOf: products)
                self.delegate?.productsUpdated()
                self.pageSession?.increment()
            }
        }
    }
    
}

extension ProductDataCoordinator: ListingTableDataSource {
   
    func getItem(at index: Int) -> String? {
        guard let products = products,
            index < products.count && index >= 0 else { return nil }
        if index >= products.count - 10 && products.count % 50 == 0 { //simple nextPage checker
            loadNextPage()
        }
        return products[index].name
    }
    
    func itemCount() -> Int { products?.count ?? 0 }
    func allowsDeletion() -> Bool { true }
    
}
