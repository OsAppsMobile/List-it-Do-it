//
//  ListItVC.swift
//  List it Do it
//
//  Created by Osman Dönmez on 1.11.2018.
//  Copyright © 2018 Osman Dönmez. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ListItVC: UITableViewController {

    let realm = try! Realm()
    var listArray: Results<ListModel>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readListItems()
    }
    
    func saveListItem(listItem: ListModel) {
        do {
            try realm.write {
                realm.add(listItem)
            }
        } catch {
            print("Error saving context: \(error)")
        }
        tableView.reloadData()
    }

    func readListItems() {
        
        listArray = realm.objects(ListModel.self)
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)

        cell.textLabel?.text = listArray?[indexPath.row].name ?? "No categories for List it added yet."
        cell.backgroundColor = UIColor(hexString: listArray?[indexPath.row].backgroundColor ?? "1D9BF6")
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let listIt = listArray?[indexPath.row] else { return }
        performSegue(withIdentifier: "goToDoIt", sender: listIt)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDoIt" {
            guard let doItVC = segue.destination as? DoItVC else { return }
            assert(sender as? ListModel != nil)
            doItVC.updateListItItem(listItItem: sender as! ListModel)
        }
    }
    
    @IBAction func addButonWasPressed(_ sender: UIBarButtonItem) {
        
        var alertItemField = UITextField()
        let alert = UIAlertController(title: "Add New List it Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            if alertItemField.text != "" {
                let listItem = ListModel()
                listItem.name = alertItemField.text!
                listItem.backgroundColor = UIColor.randomFlat.hexValue()
                self.saveListItem(listItem: listItem)
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            alertItemField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    

}
