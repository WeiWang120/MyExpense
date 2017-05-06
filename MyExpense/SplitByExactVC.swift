//
//  SplitByExactVC.swift
//  MyExpense
//
//  Created by YUAN GAO on 4/21/17.
//  Copyright © 2017 YUAN GAO. All rights reserved.
//

import UIKit

class MemberTableCell: UITableViewCell{
    @IBOutlet weak var memName: UILabel!
    @IBOutlet weak var memAmount: UITextField!
    
    
    
}

class SplitByExactVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var memberTable: UITableView!
    
    
    @IBOutlet weak var warning1: UILabel!
    @IBOutlet weak var warning2: UILabel!
    @IBOutlet weak var warning3: UILabel!
    
    @IBOutlet weak var whiteBack: UIView!
    
    var year: Int = 0
    var month:Int = 0
    var day: Int = 0
    var categ: Int = 0
    var descript: String = ""
    var memNames: [String] = ["andy", "nancy", "brian", "Hans", "Kathy", "Lisa", "Ruth"]
    var memPairs: [String:String] = [:]
    var payer = 0
    var groupID = ""
    var total:Double = 0
    var groupName = ""
    
    
    
    //table functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return memNames.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "memCell", for: indexPath) as! MemberTableCell
        let name = memNames[indexPath.item]
        cell.memName.text = name
        cell.memAmount.text = memPairs[name]
        if (indexPath.item == payer){
            cell.memAmount.text = "0.0"
            memPairs[name] = "0.0"
            cell.isUserInteractionEnabled = false;
            cell.memAmount.isEnabled = false;
        } else {
            cell.isUserInteractionEnabled = true;
            cell.memAmount.isEnabled = true;
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
    }

    
    @IBAction func memAmountFilling(_ sender: UITextField) {
        let hisValue = sender.text!
        let hisCell = sender.superview?.superview as! MemberTableCell
        let hisName = hisCell.memName.text
        memPairs.updateValue(hisValue, forKey: hisName!)
    }
    
    
    @IBAction func addTransaction(_ sender: UIButton) {
        warning1.isHidden = true
        warning2.isHidden = true
        warning3.isHidden = true
        var isDigit = true
        
        
        //check if valid numbers
        for k in memNames {
            let amount = Double(memPairs[k]!)
            isDigit = isDigit && (amount != nil)
            
        }
        if (isDigit == false) {
            warning1.isHidden = false;
        } else {
            //test if there are negative numbers
            var sum = 0.0
            var isPost = true
            for i in memNames {
                let amt_double = Double(memPairs[i]!)
                isPost = isPost && (amt_double! >= 0.0)
                sum = sum + amt_double!
                }
                if !isPost {
                    warning2.isHidden = false;
                } else {
                    if (sum > self.total){
                       
                        warning3.isHidden = false;
                    } else {
                        
                        //form a dictionary
                        memPairs[memNames[payer]] = String(self.total)
                        var indPay: [String:Double] = [:]
                        for j in memNames {
                            let name = j
                            let pay = Double(memPairs[j]!)
                            indPay[name] = pay
                        }
                        
                        let gexp = GroupExpense.init(payer: memNames[self.payer], gi: self.groupID, yr: self.year, mon: self.month, d: self.day, categ: self.categ, indpay: indPay, descri: self.descript)
                        gexp.uploadGroupExpense()
                        
                        let home = self.storyboard?.instantiateViewController(withIdentifier: "grouptransactionVC") as! GroupTransactionVC
                        home.groupid = self.groupID
                        home.groupNametest = self.groupName
                        //self.present(home, animated: true, completion: nil)
                        navigationController?.pushViewController(home, animated: true)
                        
                    }
                }
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
        for person in memNames {
            self.memPairs[person] = "0.0"
        }
        
        whiteBack.layer.borderColor = UIColor.gray.cgColor;
        whiteBack.layer.borderWidth = 0.0
        whiteBack.layer.cornerRadius = 20;
        whiteBack.layer.masksToBounds = true
        whiteBack.layer.shadowRadius = 2.0
        whiteBack.layer.shadowColor = UIColor.gray.cgColor
        whiteBack.layer.shadowOffset = CGSize(width: 1.0, height:1.0)
        whiteBack.layer.shadowOpacity = 0.6
        whiteBack.layer.shadowRadius = 1.5
        //whiteBack.layer.shouldRasterize = true
        print(groupName)
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
