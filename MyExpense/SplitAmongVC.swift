//
//  SplitAmongVC.swift
//  MyExpense
//
//  Created by YUAN GAO on 4/21/17.
//  Copyright © 2017 YUAN GAO. All rights reserved.
//

import UIKit


class NameCell: UITableViewCell{
    @IBOutlet weak var memName: UILabel!
    
    
    
}


class SplitAmongVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var memberTable: UITableView!
    

    @IBOutlet weak var whiteBack: UIView!
    
    @IBOutlet weak var payerName: UILabel!
    @IBOutlet weak var eachAmt: UILabel!
    
    @IBOutlet weak var warning: UILabel!
    
    var year: Int = 0
    var month:Int = 0
    var day: Int = 0
    var categ: Int = 0
    var descript: String = ""
    var memNames: [String] = ["andy", "nancy", "brian", "Hans", "Kathy", "Lisa", "Ruth"]
    var memSplited: [Bool] = Array(repeating: false, count: 0)
    var payer = 0
    var groupID = ""
    var total:Double = 0
    var paidNum = 0.0
    var eachPay = 0.0
    var groupName = ""
    
    
    
    //table functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return memNames.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "memCell", for: indexPath) as! NameCell
        let name = memNames[indexPath.item]
        cell.memName.text = name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        warning.isHidden = true
        paidNum = paidNum + 1.0
        memSplited[indexPath.item] = true
        refreshSinglePay()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        paidNum -= 1
        refreshSinglePay()
    }
    
    func refreshSinglePay() {
        if paidNum == 0{
            eachAmt.text = String (total)
        } else {
            eachAmt.text = String(format: "%.2f", total/paidNum)
            eachPay = total/paidNum
        }

        
    }
    
    
    
    @IBAction func addTransaction(_ sender: UIButton) {
        if paidNum == 0 {
            warning.isHidden = false
        
        } else {
            var indPay: [String:Double] = [:]
            let eachPay = round(self.total/Double(paidNum) * 100) / 100
            let memCount = memNames.count

            for  i in 0..<memCount {
                if memSplited[i] == true {
                    if i == payer {
                        indPay[memNames[i]] = self.total
                    } else {
                        indPay[memNames[i]] = eachPay
                    }
                } else {
                    indPay[memNames[i]] = 0.0
                }
                
            }
            
            let gexp = GroupExpense.init(payer: memNames[self.payer], gi: self.groupID, yr: self.year, mon: self.month, d: self.day, categ: self.categ, indpay: indPay, descri: self.descript)
            gexp.uploadGroupExpense()
            
            let home = self.storyboard?.instantiateViewController(withIdentifier: "grouptransactionVC") as! GroupTransactionVC
            home.groupNametest = self.groupName
            home.groupid = self.groupID
            //self.present(home, animated: true, completion: nil)
            navigationController?.pushViewController(home, animated: true)
        }
        
        
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "cancelSegue" {
            
                guard let addGroupTrans = segue.destination as? AddGroupTransactionViewController else { return }
                addGroupTrans.groupID = self.groupID
                addGroupTrans.memNames = self.memNames
                addGroupTrans.groupName = self.groupName
            
        }
        
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.memberTable.dataSource = self
        self.memberTable.delegate = self
        
        self.memberTable.layer.masksToBounds = true
        self.memberTable.layer.borderColor = UIColor(red: 63/255, green: 77/255, blue: 107/255, alpha: 1).cgColor
        self.memberTable.layer.borderWidth = 2.0
        self.memberTable.layer.cornerRadius = 10
        self.memberTable.allowsMultipleSelection = true
        self.payerName.text = memNames[payer]
        self.eachAmt.text = String (self.total)
        // Do any additional setup after loading the view.
        let memNum = memNames.count
        self.memSplited = Array(repeating: false, count: memNum)
        self.memSplited[self.payer] = true
        
        
        whiteBack.layer.borderColor = UIColor.gray.cgColor;
        whiteBack.layer.borderWidth = 0.0
        whiteBack.layer.cornerRadius = 20;
        whiteBack.layer.masksToBounds = true
        whiteBack.layer.shadowRadius = 2.0
        whiteBack.layer.shadowColor = UIColor.gray.cgColor
        whiteBack.layer.shadowOffset = CGSize(width: 1.0, height:1.0)
        whiteBack.layer.shadowOpacity = 0.6
        whiteBack.layer.shadowRadius = 1.5
       // whiteBack.layer.shouldRasterize = true
        print(self.groupName)
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
