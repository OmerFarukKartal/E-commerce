//
//  BasketViewController.swift
//  E-commerce
//
//  Created by KARTAL on 23.07.2023.
//

import UIKit
import JGProgressHUD
import SwiftUI

class BasketViewController: UIViewController {
    
    //IBOutlets
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var totalItems: UILabel!
    @IBOutlet weak var basketTotalPriceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkOutButtonOutlet: UIButton!
    
    
    //MARK: Vars
    
    var basket: Basket?
    var allItems: [Item] = []
    var purchasedItemIds : [String] = []
    
    let hud = JGProgressHUD(style: .dark)
    
    
    //MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = footerView
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if MUser.currentUser() != nil {
            loadBasketFromFirestore()
        }else{
            self.updateTotalLabels(true)
        }
        
        loadBasketFromFirestore()
    }
    
    
    
    //MARK: IBActions
    
    @IBAction func checkOutButtonPressed(_ sender: Any) {
        
        if MUser.currentUser()!.onBoard {
            
            tempFunction()
            addItemsToPurchaseHistory(self.purchasedItemIds)
            emptyTheBasket()
        }else{
            self.hud.textLabel.text = "Plese Complate You Profile!"
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 2.0)
        }
        
    }
    
    
    //MARK: Download Basket
    
    private func loadBasketFromFirestore(){
        
        downloadBasketFromFirestore(MUser.currentID()) { (basket) in
            
            self.basket = basket
            self.getBasketItems()
            
        }
    }
    
    private func getBasketItems(){
        
        if basket != nil {
            
            downloadItems(basket!.itemIds) { (allItems) in
                
                self.allItems = allItems
                self.updateTotalLabels(false)
                self.tableView.reloadData()
            }
        }
        
    }
    
    //MARK: Helper Functions
    
    func tempFunction(){
        for item in allItems {
            purchasedItemIds.append(item.id)
        }
    }
    
    
    
    private func updateTotalLabels(_ isEmpty: Bool) {
        if isEmpty {
            totalItems.text = "0"
            basketTotalPriceLabel.text = returnBasketTotalPrice()
        } else {
            totalItems.text = "\(allItems.count)"
            basketTotalPriceLabel.text = returnBasketTotalPrice()
            
        }
        checkoutButtonStatusUpdate()
        
    }
    
    private func returnBasketTotalPrice() -> String {
        var totalPrice = 0.0
        
        for item in allItems {
            totalPrice += item.price
        }
        
        return "Toplam fiyat: " + convertToCurrency(totalPrice).replacingOccurrences(of: "$", with: "₺")
    }
    
    private func emptyTheBasket() {
        
        purchasedItemIds.removeAll()
        allItems.removeAll()
        tableView.reloadData()
        
        basket!.itemIds = []
        updateBasketInFirestore(basket!, withValues: [kITEMIDS : basket!.itemIds!]) { (error) in
            
            if error != nil {
                print("Error updating basket", error!.localizedDescription)
            }
            self.getBasketItems()
        }
        
        
    }
    
    private func addItemsToPurchaseHistory(_ itemIds: [String]) {
        
        if MUser.currentUser() != nil {
            let newItemIds = MUser.currentUser()!.purchasedItemIds + itemIds
            updateCurrentUserInFirestore(withValues: [kPURCHASEDITEMIDS : itemIds]) { (error) in
                
                if error != nil {
                    print("Error Adding Purchased items", error!.localizedDescription)
                }
            }
        }
    }
    
    
    
    //MARK: Navigation
    
    private func showItemView(withItem: Item) {
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "itemView") as! ItemViewController
        itemVC.item = withItem
        
        self.navigationController?.pushViewController(itemVC, animated: true )
    }
    
    
    
    //MARK: Control checkoutbutton
    
    private func checkoutButtonStatusUpdate() {
        
        checkOutButtonOutlet.isEnabled = allItems.count > 0
        
        if checkOutButtonOutlet.isEnabled {
            checkOutButtonOutlet.backgroundColor =  #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)
        } else {
            disabledCheckoutButton()
        }
    }
    
    private func disabledCheckoutButton(){
        
        checkOutButtonOutlet.isEnabled = false
        checkOutButtonOutlet.backgroundColor =  #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
    }
    
    private func removeItemFromBasket (itemId: String) {
        
        for i in 0..<basket!.itemIds.count {
            
            if itemId == basket!.itemIds[i] {
                basket!.itemIds.remove(at: i)
                
                return
            }
        }
    }
}
extension BasketViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        
        cell.generateCell(allItems[indexPath.row])
        
        return cell
        
    }
    
    //MARK: UITableview Delegate
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let itemToDelete = allItems[indexPath.row]
            
            allItems.remove(at: indexPath.row)
            tableView.reloadData()
            removeItemFromBasket(itemId: itemToDelete.id)
            
            updateBasketInFirestore(basket! , withValues: [kITEMIDS: basket!.itemIds!]) { (error) in
                if error != nil {
                    print("error updating the basket", error!.localizedDescription)
                }
                self.getBasketItems()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(withItem: allItems[indexPath.row])
    }
    
}

