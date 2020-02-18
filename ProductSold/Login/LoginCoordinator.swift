//
//  LoginCoordinator.swift
//  ProductSold
//
//  Created by Rob Caraway on 2/12/20.
//  Copyright © 2020 Rob Caraway. All rights reserved.
//

import UIKit

protocol LoginCoordinatorDelegate: AnyObject {
    func didSuccessfullyLogin(with token: String)
}

class LoginCoordinator {
    
    unowned var navigationController: UINavigationController
    var loginViewController: LoginViewController?
    private let loginService = LoginAPIService()
    weak var delegate: LoginCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        guard let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")  as? LoginViewController else { fatalError("Must have login controller" ) }
        navigationController.pushViewController(loginViewController, animated: false)
        loginViewController.delegate = self
        self.loginViewController = loginViewController
    }
    
}

extension LoginCoordinator: LoginViewControllerDelegate {
   
    func didTapLogin(_ loginController: LoginViewController) {
        loginController.showLoading()
        guard let email = loginController.emailField.text,
            let password = loginController.passwordField.text else { return }
        //TODO: add proper email & password validation
        loginService.login(with: UserCredentials(email: email, password: password)) { (token) in
            loginController.showLogin()
            guard let token = token else { return } //FIXME: handle error
            self.delegate?.didSuccessfullyLogin(with: token)
        }
    }
    
}
