//
//  ProductCoordinator.swift
//  ProductSold
//
//  Created by Rob Caraway on 2/12/20.
//  Copyright © 2020 Rob Caraway. All rights reserved.
//

import UIKit

enum ProductState {
    case begin
    case productList
    case productDetail(Product) //TODO: could add a .create state
}

class ProductCoordinator {
    unowned let navigationController: UINavigationController
    var productListController: ListingViewController?
    var detailController: ProductDetailViewController?
    var stylesListController: ListingViewController?
    let dataCoordinator: ProductDataCoordinator
    var currentState: ProductState?
    
    var selectedProduct: Product? {
        switch currentState {
        case let .productDetail(product):
            return product
        default:
            return nil
        }
    }
    
    init(navigationController: UINavigationController, token: UserToken) {
        self.navigationController = navigationController
        dataCoordinator = ProductDataCoordinator(token: token)
        dataCoordinator.delegate = self
    }
    
    func setState(_ state: ProductState) {
        switch state {
        case .begin:
            start()
        case let .productDetail(product):
            showDetail(of: product)
        default: break
        }
        currentState = state
    }
    
    //MARK: state transitions
    private func start() {
        guard let productListController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProductListViewController")  as? ListingViewController else { fatalError("Must have listing controller" ) }
        self.navigationController.viewControllers = [productListController]
        self.productListController = productListController
        self.productListController?.dataSource = self.dataCoordinator
        self.productListController?.title = "Products"
        self.productListController?.delegate = self
        let navButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createDidTap))
        self.productListController?.navigationItem.rightBarButtonItem = navButton
        dataCoordinator.loadProducts()
        setState(.productList)
    }
    
    private func showDetail(of product: Product) {
        guard let detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProductDetailViewController")  as? ProductDetailViewController else { fatalError("Must have detail controller" ) }
        self.navigationController.pushViewController(detailController, animated: true)
        let viewModel = DetailViewModel(name: product.name, description: product.description, style: product.style, brand: product.brand, price: product.shippingPrice)
        detailController.detailSource = viewModel
        detailController.delegate = self
        detailController.title = "Edit Product"
        self.detailController = detailController
    }
    
    private func showStyles() {
        guard let styleListController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProductListViewController")  as? ListingViewController else { fatalError("Must have listing controller" ) }
        self.activeNavigationController().pushViewController(styleListController, animated: true)
        styleListController.dataSource = self.dataCoordinator.styleSession
        styleListController.title = "Styles"
        styleListController.delegate = self
        dataCoordinator.loadStyles()
        self.stylesListController = styleListController
    }
    
    
    //MARK: actions
    @objc func createDidTap() {
        guard let detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProductDetailViewController")  as? ProductDetailViewController else { fatalError("Must have detail controller" ) }
        let viewModel = DetailViewModel(name: "", description: "", style: "None", brand: "", price: 0)
        detailController.detailSource = viewModel
        detailController.delegate = self
        self.detailController = detailController
        detailController.title = "Create Product"
        let nav = UINavigationController(rootViewController: detailController)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didCancelCreation))
        detailController.navigationItem.leftBarButtonItem = cancelButton
        self.navigationController.present(nav, animated: true, completion: nil)
    }
    
    @objc func didCancelCreation() {
        self.navigationController.dismiss(animated: true, completion: nil)
    }
    
    //MARK: convenience
    private func activeNavigationController() -> UINavigationController {
        if let nav = self.navigationController.presentedViewController as? UINavigationController {
            return nav
        }else {
            return navigationController
        }
    }
    
}

//MARK: data updates
extension ProductCoordinator: ProductDataDelegate {
    
    func productAdded() {
        navigationController.dismiss(animated: true, completion: nil)
    }
    
    func productUpdated(_ product: Product) {
        if selectedProduct?.id == product.id && navigationController.topViewController == detailController {
            navigationController.popViewController(animated: true)
        }
    }
    
    func stylesUpdated() {
        self.stylesListController?.tableView.reloadData()
    }
    
    func productsUpdated() {
        self.productListController?.tableView.reloadData()
    }
}

//MARK: listing listener
extension ProductCoordinator: ListingTableDelegate {
    
    func requestDeletion(for index: Int) {
        dataCoordinator.deleteProduct(at: index)
    }
    
    func didSelect(item: String, at index: Int) {
        if activeNavigationController().topViewController?.title == "Styles" {
            if var detailModel = detailController?.detailSource {
                detailModel.style = item
                detailController?.detailSource = detailModel
                activeNavigationController().popViewController(animated: true)
            }
        } else {
            guard let product = dataCoordinator.getProduct(at: index) else { return }
            setState(.productDetail(product))
        }
    }
}

//MARK: detail listener
extension ProductCoordinator: DetailDelegate {
    func willReturnToPreviousScreen() {
        setState(.productList)
    }
    
    func didRequestStyles() {
        showStyles()
    }
    
    func didCommitChanges(_ model: DetailViewModel) {
        if let product = selectedProduct {
            let updatedProduct = Product(name: model.name,
                   description: model.description,
                   style: model.style,
                   brand: model.brand,
                   shippingPrice: model.price,
                   id: product.id)
            dataCoordinator.updateProduct(product: updatedProduct)
        } else {
            let request = ProductRequest(product_name: model.name,
                                         description: model.description,
                                         style: model.style,
                                         brand: model.brand,
                                         shipping_price: model.price)
            dataCoordinator.createProduct(from: request)
        }
    }
}

