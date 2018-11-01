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
import StoreKit

class ListItVC: SwipeTableVC {

    let realm = try! Realm()
    var listArray: Results<ListModel>?
    //Real product identifier will be entered after being a member of Apple developer programme.
    let productIdentifier = "testProductIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self)
        tableView.rowHeight = 80.0
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
    
    override func updateDataModel(at indexPath: IndexPath) {
        if let listItItem = self.listArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(listItItem)
                }
            } catch {
                print("Error deleting selected category: \(error)")
            }
            tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if isPurchased() == false {
            if indexPath.row < 2 {
                if let listItItem = listArray?[indexPath.row] {
                    cell.textLabel?.text = listItItem.name
                    cell.backgroundColor = UIColor(hexString: listArray?[indexPath.row].backgroundColor ?? "F6A623")
                    cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
                    cell.accessoryType = .none
                    
                } else {
                    cell.textLabel?.text = "No List it categoris added yet."
                }
            } else {
                navigationItem.rightBarButtonItem?.isEnabled = false
                cell.textLabel?.text = "Get Unlimited List it Categories"
                cell.textLabel?.textColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                cell.accessoryType = .disclosureIndicator
            }
        } else {
            if let listItItem = listArray?[indexPath.row] {
                cell.textLabel?.text = listItItem.name
                cell.backgroundColor = UIColor(hexString: listArray?[indexPath.row].backgroundColor ?? "F6A623")
                cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
                cell.accessoryType = .none

            } else {
                cell.textLabel?.text = "No List it categories added yet."
            }
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isPurchased() == false && indexPath.row == 2 {
            //buyUnlimitedListIt()

            //To test the buying function without apple developer membership unlimitedListItEnable() function can be used directly.
             unlimitedListItEnable()
            
        } else {
        guard let listIt = listArray?[indexPath.row] else { return }
        performSegue(withIdentifier: "goToDoIt", sender: listIt)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDoIt" {
            guard let doItVC = segue.destination as? DoItVC else { return }
            assert(sender as? ListModel != nil)
            doItVC.updateListItItem(listItItem: sender as! ListModel)
        }
    }
    
    // MARK: - In-App Purchase Methods
    
    func buyUnlimitedListIt() {
        if SKPaymentQueue.canMakePayments() {
            //User can make payment
            print("user can make the payment")
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productIdentifier
            SKPaymentQueue.default().add(paymentRequest)
        } else {
            //User can't make payment
            print("Unable to make a payment!")
        }
    }
    
    func isPurchased() -> Bool {
        let purchaseStatus = UserDefaults.standard.bool(forKey: "purchased")
        return purchaseStatus
    }
    
    func unlimitedListItEnable() {
        UserDefaults.standard.set(true, forKey: "purchased")
        navigationItem.rightBarButtonItem?.isEnabled = true
        tableView.reloadData()
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

extension ListItVC: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                // User payment succesfull
                unlimitedListItEnable()
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .failed {
                // Payment failed
                if let error = transaction.error {
                    print("Transaction failed due to error: \(error.localizedDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
}
