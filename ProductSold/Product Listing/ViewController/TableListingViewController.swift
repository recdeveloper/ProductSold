//
//  ProductListViewController.swift
//  ProductSold
//
//  Created by Rob Caraway on 2/14/20.
//  Copyright © 2020 Rob Caraway. All rights reserved.
//

import UIKit

protocol ListingTableDataSource: AnyObject {
    func getItem(at index: Int) -> String?
    func itemCount() -> Int
    func allowsDeletion() -> Bool
}

protocol ListingTableDelegate: AnyObject {
    func didSelect(item: String, at index: Int)
    func requestDeletion(for index: Int)
}

class ListingViewController: UITableViewController {
    weak var dataSource: ListingTableDataSource?
    weak var delegate: ListingTableDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 55
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.itemCount() ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell()
        cell.textLabel?.text = dataSource?.getItem(at: indexPath.row)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard let tableinfo = dataSource else { return .none }
        return tableinfo.allowsDeletion() ? .delete : .none
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delegate?.requestDeletion(for: indexPath.row)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource?.getItem(at: indexPath.row) else { return }
        delegate?.didSelect(item: item, at: indexPath.row)
    }
}
