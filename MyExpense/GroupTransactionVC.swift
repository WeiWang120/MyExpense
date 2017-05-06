//
//  GroupTransactionVC.swift
//  MyExpense
//
//  Created by 王巍 on 4/20/17.
//  Copyright © 2017 YUAN GAO. All rights reserved.
//

import UIKit
import FirebaseDatabase




class groupTransactionCell : UITableViewCell {
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var money: UILabel!
    
    @IBOutlet weak var holder: UIView!
    
}

class GroupTransactionVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var groupName: UILabel!
    
  
    
    
    var user: String = "";
    var groupNametest: String = ""
    var transactionArray:[GroupExpense] = []
    var transactionID:[String] = []
    var members:[String] = []
    var groupid:String!
    var indivualpay:[String:Double] = [:]
    func fetchGroupTransactions() {
        let ref = FIRDatabase.database().reference()
        
        ref.observe(FIRDataEventType.value, with: { (snapshot) in
            
            self.transactionArray.removeAll()
            self.transactionID.removeAll()
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            let a = postDict["groups"] as? [String : AnyObject] ?? [:]
            let b = a[self.groupid] as? [String : AnyObject] ?? [:]
            let membersFromDB = b["members"] as? [String : AnyObject] ?? [:]
            let groupTransactions = b["transactions"] as? [String : AnyObject] ?? [:]
            self.members.removeAll()
            for (key,_) in membersFromDB{
                self.members.append(key)
            }
            
            for (key,value) in groupTransactions{
                self.transactionID.append(key)
                let date = value["date"] as? [String : AnyObject] ?? [:]
                let transpayer = value["payer"] as! String
                let category = value["category"]! as! Int
              
                let monthFromFB = date["month"]! as! Int
                let yearFromFB = date["year"]! as! Int
                let dayFromFB = date["day"]! as! Int
                
                self.indivualpay = value["money"] as? [String : Double] ?? [:]
                let description = value["description"] as! String
                let groupTransaction = GroupExpense(payer: transpayer, gi: self.groupid, yr: yearFromFB, mon: monthFromFB, d: dayFromFB, categ: category, indpay: self.indivualpay, descri:description)
                self.transactionArray.append(groupTransaction)
            }
            self.tableview.reloadData()
            //self.totalAmount.text = String(self.total)
            
        })
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return transactionArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "groupTransactionCell", for: indexPath) as! groupTransactionCell
        let year = self.transactionArray[indexPath.row].year
        let month = self.transactionArray[indexPath.row].month
        let day = self.transactionArray[indexPath.row].day
        let payer = self.transactionArray[indexPath.row].payer
        let indivualpay = self.transactionArray[indexPath.row].individualpay
        let money = indivualpay[user]!
        let date = "\(year)-\(month)-\(day)"
        var debt = ""
        if user ==  payer{
            debt = "You paid $\(money)"
        }else{
            debt = "You owe \(payer) $\(money)"
        }
        cell.date.text = date
        cell.money.text = debt
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let groupdetailtransactionVC = self.storyboard?.instantiateViewController(withIdentifier: "detailtransactionVC") as! GroupShowTransactionVC
        groupdetailtransactionVC.currentGroup = self.groupid
        groupdetailtransactionVC.currentGroupName = self.groupNametest
        print(groupdetailtransactionVC.currentGroupName)
        groupdetailtransactionVC.selectedTransaction = self.transactionID[indexPath.row]
        navigationController?.pushViewController(groupdetailtransactionVC, animated: true)
        //self.present(groupdetailtransactionVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addGroupTranSegue" {
            
            guard let addGroupTrans = segue.destination as? AddGroupTransactionViewController else { return }
            addGroupTrans.groupName = self.groupNametest
            addGroupTrans.groupID = self.groupid
            addGroupTrans.memNames = self.members
            
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.groupName.text = self.groupNametest
        self.user = UserDefaults.standard.object(forKey: "username") as! String
        self.tableview.dataSource = self
        self.tableview.delegate = self
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchGroupTransactions();
            
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
            
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
