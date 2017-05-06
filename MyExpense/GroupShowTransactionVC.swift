//
//  GroupShowTransactionVC.swift
//  MyExpense
//
//  Created by 杜梓宸 on 4/20/17.
//  Copyright © 2017 YUAN GAO. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase



class TransacionCell : UITableViewCell {
    
    @IBOutlet weak var member: UILabel!
    @IBOutlet weak var payerAmount: UILabel!
    @IBOutlet weak var eachAmount: UILabel!
    
}


class GroupShowTransactionVC: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var transactionTable: UITableView!
    var user: String!
    var transactionArray: GroupExpense!
    var moneyAndMember: [String: Double] = [:]
    var currentMonth: Int!
    var currentDay: Int!
    var currentYear: Int!
    var payer: String!
    var members: [String] = []
    var money: [Double] = []
    var descriptionFromFB: String!
    var currentGroup: String!
    var selectedTransaction: String!
    var currentGroupName: String!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.user = UserDefaults.standard.object(forKey: "username") as! String
        transactionTable.dataSource = self
        self.transactionTable.separatorStyle = UITableViewCellSeparatorStyle.none
        self.transactionTable.backgroundColor = UIColor.init(red: 248/255, green: 249/255, blue: 249/255, alpha: 1)
        //self.transactionTable.backgroundColor = UIColor.black;
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchDataFromFirebase();
            
            
            DispatchQueue.main.async {
                self.transactionTable.reloadData()
            }
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //
        let cell =  tableView.dequeueReusableCell(withIdentifier: "grouptransactioncell", for: indexPath) as! TransacionCell
        if self.payer == members[indexPath.row] {
            cell.payerAmount.text = "$ " + String(money[indexPath.row])
            cell.eachAmount.text = ""
        }
        else {
            cell.eachAmount.text = "$ " + String(money[indexPath.row])
            cell.payerAmount.text = ""
        }
        //cell.eachAmount.text = String(moneyAndMember[indexPath.row])
        cell.member.text = members[indexPath.row]// moneyAndMember[indexPath.row].key
        let home = self.storyboard?.instantiateViewController(withIdentifier: "AddGroupTransactionVC") as! AddGroupTransactionViewController
        home.groupName = self.currentGroupName
        
        return cell
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "backSegue" {
            
            guard let groupTrans = segue.destination as? GroupTransactionVC else { return }
            groupTrans.groupid = self.currentGroup
            groupTrans.groupNametest = self.currentGroupName
            
        }
        
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    private func fetchDataFromFirebase() {
        let ref = FIRDatabase.database().reference()
        
        ref.observe(FIRDataEventType.value, with: { (snapshot) in
            
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            let a = postDict["groups"] as? [String : AnyObject] ?? [:]
            let myGroupTransactions = a[self.currentGroup] as? [String : AnyObject] ?? [:]
            let oneTransaction = myGroupTransactions["transactions"] as? [String: AnyObject] ?? [:]
            let selectTransaction = oneTransaction[self.selectedTransaction] as? [String: AnyObject] ??
                [:]
            print(selectTransaction)
            let date = selectTransaction["date"] as? [String : AnyObject] ?? [:]
            print(date)
            let category = selectTransaction["category"] as! Int
            self.category.text = categoryStr[category]
            self.categoryImage.image = UIImage(named: categoryStr[category] + ".img")
            let money = selectTransaction["money"]! as! [String: Double]
            self.currentMonth = date["month"]! as! Int
            self.currentYear = date["year"] as! Int
            self.currentDay = date["day"]! as! Int
            self.payer = selectTransaction["payer"]! as! String
            self.descriptionFromFB = selectTransaction["description"] as! String
            self.descriptionLabel.text = self.descriptionFromFB
            self.transactionArray = GroupExpense(payer:self.payer, gi : self.currentGroup, yr:self.currentYear, mon:self.currentMonth, d:self.currentDay, categ: category, indpay: money, descri: self.descriptionFromFB)
            self.date.text = "\(self.currentMonth!)/\(self.currentDay!)/\(self.currentYear!)"
            self.moneyAndMember = self.transactionArray.individualpay
            self.money.removeAll()
            self.members.removeAll()
            for value in self.moneyAndMember {
                self.money.append(value.value)
                self.members.append(value.key)
            }
            self.transactionTable.reloadData()
            
            
            
        })
    }
    
    
}
