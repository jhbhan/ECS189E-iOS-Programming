//
//  WalletViewController.swift
//  ECS189E
//
//  Created by Jason 반 on 11/2/18.
//  Copyright © 2018 Zhiyi Xu. All rights reserved.
//

import UIKit

class WalletViewController: UIViewController, UITableViewDataSource {
    
    
    var wallet: Wallet = Wallet.init()
    var accounts: [Account] = []
    var numRow = 0;
    
    @IBAction func tapUserName(_ sender: Any) {
        self.accountTable.isUserInteractionEnabled = false
    }
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var accountTable: UITableView!
    
    
    //Tableview number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let num = self.accounts.count
        return num
    }//end numRows
    
    //TableView set each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "accountCells", for: indexPath)
        let currentAccount = accounts[indexPath.row]
        tableCell.textLabel?.text = currentAccount.name
        tableCell.detailTextLabel?.text = String(currentAccount.amount)

        return tableCell
    }//end setting each cell
    

    //end editing and save name when touched elsewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.wallet.userName = userName.text
        Api.setName(name: self.wallet.userName ?? "") { (response, error) in
            guard response != nil, error == nil else{
                return
            }
            
        }
        
        self.view.endEditing(true)
        self.accountTable.isUserInteractionEnabled = true
    }//end touchesBegan
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //API call, repsonse is not nil and error is nil
        Api.user() { response, error in
            guard response != nil else{
                guard error != nil else{
                    return
                }
                return
            }
            //setting up wallet, accounts, and text labels
            self.wallet = Wallet.init(data: response!, ifGenerateAccounts: true)
            self.accounts = self.wallet.accounts
            let formatAmount = String(format: "%.2f", self.wallet.totalAmount) // "3.14"
            self.totalAmountLabel.text = "Total amount in your bank account is $" + formatAmount
            if self.wallet.userName == ""{
                self.userName.text = "Tap to set userName"
            }
            else{
            self.userName.text = self.wallet.userName
            }
            //reload data to update TableView
            self.accountTable.reloadData()
        }
        
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
