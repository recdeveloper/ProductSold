//
//  AppCoordinator.swift
//  ProductSold
//
//  Created by Rob Caraway on 2/12/20.
//  Copyright © 2020 Rob Caraway. All rights reserved.
//

import UIKit

typealias UserToken = String //TODO: as app grows, create actual user object

enum AppState {
    case begin
    case loggedIn(UserToken)
    case login
}

class AppCoordinator {
    
    private(set) var currentState: AppState = .begin
    let navigationController: UINavigationController
    var loginCoordinator: LoginCoordinator?
    var productCoordinator: ProductCoordinator?
    
    init() {
        navigationController = UINavigationController()
        navigationController.view.backgroundColor = .white
    }
    
    func setState(state: AppState) {
        switch state {
        case .begin:
            start()
        case let .loggedIn(token):
            didLogin(token: token)
        default: break //no need to handle login
        }
        currentState = state
    }
    
    private func start() {
        let loginCoordinator = LoginCoordinator(navigationController: navigationController)
        loginCoordinator.start()
        loginCoordinator.delegate = self
        self.loginCoordinator = loginCoordinator
        currentState = .login
    }
    
    private func didLogin(token: String) {
        let productCoordinator = ProductCoordinator(navigationController: self.navigationController, token: token)
        productCoordinator.setState(.begin)
        self.productCoordinator = productCoordinator
    }
}

extension AppCoordinator: LoginCoordinatorDelegate {
    func didSuccessfullyLogin(with token: String) {
        setState(state: .loggedIn(token))
    }
}
