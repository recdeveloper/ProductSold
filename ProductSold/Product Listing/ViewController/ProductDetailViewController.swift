//
//  ProductDetailViewController.swift
//  ProductSold
//
//  Created by Rob Caraway on 2/15/20.
//  Copyright © 2020 Rob Caraway. All rights reserved.
//

import UIKit

protocol DetailDelegate: AnyObject {
    func didRequestStyles()
    func didCommitChanges(_ model: DetailViewModel)
    func willReturnToPreviousScreen()
}


class ProductDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var styleLabel: UILabel!
    @IBOutlet weak var styleButton: UIButton!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var brandField: UITextField!
    @IBOutlet weak var commitButton: UIButton!
    
    var detailSource: DetailViewModel? { //TODO: this should ideally bind data to views
        didSet {
            if isViewLoaded {
                reloadViews()
            }
        }
    }
    weak var delegate: DetailDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        nameField.delegate = self
        descriptionTextView.delegate = self
        brandField.delegate = self
        priceField.delegate = self
        commitButton.layer.cornerRadius = 5.0
        reloadViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent {
            delegate?.willReturnToPreviousScreen()
        }
        super.viewWillDisappear(animated)
    }
    
    private func reloadViews() {
        nameField.text = detailSource?.name
        descriptionTextView.text = detailSource?.description ?? ""
        styleButton.setTitle(detailSource?.style ?? "None", for: .normal)
        brandField.text = detailSource?.brand
        priceField.text = detailSource?.price.priceString() ?? "0"
    }
    
    @IBAction func styleDidTap(_ sender: Any) {
        updateViewModel()
        delegate?.didRequestStyles()
    }
    
    @IBAction func didCommit(_ sender: Any) {
        updateViewModel()
        guard let model = detailSource else { return }
        delegate?.didCommitChanges(model)
    }
    
    func updateViewModel() {
        let viewModel = DetailViewModel(name: nameField.text ?? "",
                                        description: descriptionTextView.text ?? "",
                                        style: styleButton.titleLabel?.text ?? "",
                                        brand: brandField.text ?? "",
                                        price: priceField.text?.toPrice() ?? 0)
        self.detailSource = viewModel
    }
    
}

extension ProductDetailViewController: UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        updateViewModel()
        return true
    }
    
}
