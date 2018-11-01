//
//  DoItVC.swift
//  List it Do it
//
//  Created by Osman Dönmez on 1.11.2018.
//  Copyright © 2018 Osman Dönmez. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import StoreKit

class DoItVC: SwipeTableVC {

    
    @IBOutlet weak var searchBar: UISearchBar!
    let realm = try! Realm()
    var doItItems: Results<DoModel>?
    var listItItem = ListModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.rowHeight = 80.0
        navigationController?.navigationBar.barTintColor = UIColor(hexString: listItItem.backgroundColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = listItItem.name
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.") }
        navBar.barTintColor = UIColor(hexString: listItItem.backgroundColor)
        navBar.tintColor = ContrastColorOf(UIColor(hexString: listItItem.backgroundColor)!, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(UIColor(hexString: listItItem.backgroundColor)!, returnFlat: true)]
        searchBar.barTintColor = UIColor(hexString: listItItem.backgroundColor)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let originalColour = UIColor(hexString: "F6A623") else { fatalError() }
        navigationController?.navigationBar.barTintColor = originalColour
        navigationController?.navigationBar.tintColor = FlatWhite()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: FlatWhite()]
    }


    
    func updateListItItem(listItItem: ListModel) {
        self.listItItem = listItItem
        readDoItItems()
    }
    
    func readDoItItems() {
        doItItems = listItItem.doItems.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateDataModel(at indexPath: IndexPath) {
        if let doItItem = doItItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(doItItem)
                }
            } catch {
                print("Error deleting selected category: \(error)")
            }
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doItItems?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

                if let doItItem = doItItems?[indexPath.row] {
                    cell.textLabel?.text = doItItem.title
                    let listItItemColor = UIColor(hexString: listItItem.backgroundColor)
                    cell.backgroundColor = listItItemColor!.darken(byPercentage: (CGFloat(indexPath.row) / CGFloat((doItItems?.count)!)))
                    cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
                    
                    if doItItem.done == true {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                } else {
                    cell.textLabel?.text = "No do it items added yet."
                }

        return cell
    }
    
    // MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let doItItem = doItItems?[indexPath.row] {
            do {
                try realm.write {
                    doItItem.done = !doItItem.done
                }
            } catch {
                print("Error saving done status: \(error)")
            }
            tableView.reloadData()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func addButtonWasPressed(_ sender: UIBarButtonItem) {
        
        var alertItemField = UITextField()
        let alert = UIAlertController(title: "Add New Do it Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if alertItemField.text != "" {
                let doItItem = DoModel()
                doItItem.title = alertItemField.text!
                do {
                    try self.realm.write {
                        self.listItItem.doItems.append(doItItem)
                    }
                } catch {
                    print("Error saving context: \(error)")
                }
                self.tableView.reloadData()
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            alertItemField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
}

extension DoItVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            doItItems = doItItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "currentDate", ascending: false)
            tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            readDoItItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

