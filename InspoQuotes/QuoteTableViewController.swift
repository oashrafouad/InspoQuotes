//
//  QuoteTableViewController.swift
//  InspoQuotes
//
//  Created by Angela Yu on 18/08/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController, SKPaymentTransactionObserver {
    
    @Published private(set) var items = [Product] ()
    let productID = "com.oashrafouad.InspoQuotes.PremiumQuotes"
//    var arePremiumQuotesPurchased = false
    
    var quotesToShow = [
        "Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
        "All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
        "It does not matter how slowly you go as long as you do not stop. – Confucius",
        "Everything you’ve ever wanted is on the other side of fear. — George Addair",
        "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
        "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
    ]
    
    let premiumQuotes = [
        "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
        "I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
        "There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
        "It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
        "Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
        "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self)
        
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
        
        if arePremiumQuotesPurchased() {
            showPremiumQuotes()
        }

    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arePremiumQuotesPurchased() {
            return quotesToShow.count
        }
        else {
            return quotesToShow.count + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
        
        if indexPath.row < quotesToShow.count
        {
            cell.textLabel?.text = quotesToShow[indexPath.row]
            cell.textLabel?.numberOfLines = 0
        }
        else
        {
            cell.textLabel?.text = "Get More Quotes"
            cell.textLabel?.font = .boldSystemFont(ofSize: cell.textLabel!.font.pointSize)
            cell.accessoryType = .disclosureIndicator
        }
        
        // To clear bold font on "Get More Quotes"
        if arePremiumQuotesPurchased() {
            cell.textLabel?.font = .systemFont(ofSize: cell.textLabel!.font.pointSize)
        }
        
        return cell
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == quotesToShow.count
        {
            tableView.cellForRow(at: indexPath)?.selectionStyle = .default // To make only this cell pressable while the others not
            
            buyPremiumQuotes()
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    //MARK: - In-app purchase methods
    
    func buyPremiumQuotes()
    {
        if SKPaymentQueue.canMakePayments()
        {
            print("user can make payments")
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
        }
        else
        {
            print("user can't make payments")
            let alert = UIAlertController(title: "Sorry!", message: "You're restricted from making payments.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            present(alert, animated: true)
        }
    }
    
    func arePremiumQuotesPurchased() -> Bool {
        return UserDefaults.standard.bool(forKey: "com.oashrafouad.InspoQuotes.PremiumQuotes")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                print("transaction successful")
                
                showPremiumQuotes()
                
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .failed:
                if let error = transaction.error {
                    print("transaction failed, error: \(error.localizedDescription)")
                }
                
            case .restored:
                print("transaction restored")
                
                showPremiumQuotes()
                
                navigationItem.setRightBarButton(nil, animated: true)
                
                SKPaymentQueue.default().finishTransaction(transaction)
                
            default:
                print("unknown status")
            }
        }
    }
    
    func showPremiumQuotes() {
        UserDefaults.standard.set(true, forKey: "com.oashrafouad.InspoQuotes.PremiumQuotes")
        
        quotesToShow.append(contentsOf: premiumQuotes)
        tableView.reloadData()
    }
    
    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        SKPaymentQueue.default().restoreCompletedTransactions()
        
    }
}
