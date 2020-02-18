//
//  LoginViewController.swift
//  ProductSold
//
//  Created by Rob Caraway on 2/12/20.
//  Copyright © 2020 Rob Caraway. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate: AnyObject {
    func didTapLogin(_ loginController: LoginViewController)
}

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    weak var delegate: LoginViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 5.0
    }
    
    func showLogin() {
        indicatorView.stopAnimating()
        emailField.alpha = 1
        passwordField.alpha = 1
        loginButton.alpha = 1
    }
    
    func showLoading() {
        indicatorView.startAnimating()
        emailField.alpha = 0
        passwordField.alpha = 0
        loginButton.alpha = 0
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        delegate?.didTapLogin(self)
    }
}
