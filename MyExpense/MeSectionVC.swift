//
//  MeViewController.swift
//  MyExpense
//
//  Created by Zimu Wang on 4/9/17.
//  Copyright © 2017 YUAN GAO. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase


class TransactionTableViewCell: UITableViewCell{
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var money: UILabel!
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var lineView: UIView!
}


class myViewController: UIViewController ,  UITableViewDataSource {
    
    @IBOutlet weak var totalAmount: UILabel!
    var months = ["", "Jan", "Feb", "Mar","Apr", "May", "Jun",
                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var date: UITextField!
    
    
    @IBOutlet weak var tableview: UITableView!
    var transactionArray:[PersonalExpense] = []
    var user:String = "default"
    var currentMonth: Int = 1;
    var currentYear: Int = 2017;
    var total = 0.0;
    
    let newView: MonthYearPickerView = MonthYearPickerView()


    
    @IBAction func menuClicked(_ sender: UIButton) {
        UserDefaults.standard.set("default", forKey: "username")
        let alert = UIAlertController(title: "Log Out", message: "You have successfully logged out", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: {
            action in
            let logInViewController = self.storyboard?.instantiateViewController(withIdentifier: "login") as! ViewController
            self.present(logInViewController, animated: true, completion: nil)
        }
        )
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    private func fetchDataFromFirebase(month:Int, year:Int) {
        let ref = FIRDatabase.database().reference()
        
        ref.observe(FIRDataEventType.value, with: { (snapshot) in
            
            self.transactionArray.removeAll();
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            let a = postDict["transactions"] as? [String : AnyObject] ?? [:]
            let myTransactions = a[self.user] as? [String : AnyObject] ?? [:]
            self.total = 0.0
            for (_,value) in myTransactions{
                
                let date = value["date"] as? [String : AnyObject] ?? [:]
                let monthFromFB = date["month"]! as! Int
                let yearFromFB = date["year"]! as! Int
                if (monthFromFB == month) && (yearFromFB == year) {
                    let category = value["category"]! as! Int
                    let money = value["money"]! as! Double
                    let day = date["day"]! as! Int
                    let myTransaction = PersonalExpense(user: self.user, yr: year, mon: month, d: day, categ: category, amt: money)
                    self.transactionArray.append(myTransaction)
                    self.total = self.total + money
                }
            
            }
            
            self.tableview.reloadData()
            self.totalAmount.text = String(self.total)
            
        })
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return transactionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TransactionTableViewCell
        let ind = indexPath.row
        let catInd = transactionArray[ind].category
        cell.category?.text = categoryStr[catInd]
        cell.money?.text = String(transactionArray[ind].amount)
        if transactionArray[ind].amount > 0 {
            //cell.money.textColor = UIColor.init(red: 58/255, green: 189/255, blue: 160/255, alpha: 1);
        }
        else {
            //cell.money.textColor = UIColor.red;
            
        }
        
        cell.date?.text = months[transactionArray[ind].month]
        cell.day?.text = String(transactionArray[ind].date)
        
        let imgName = categoryStr[catInd] + ".png";
        cell.icon?.image = UIImage(named: imgName)
        
        cell.backgroundColor = UIColor.clear
  
        cell.holder.layer.borderColor = UIColor.gray.cgColor;
        cell.holder.layer.borderWidth = 0.0
        cell.holder.layer.cornerRadius = 5
        cell.holder.layer.masksToBounds = false
        cell.holder.layer.shadowRadius = 2.0
        cell.holder.layer.shadowColor = UIColor.gray.cgColor
        cell.holder.layer.shadowOffset = CGSize(width: 1.0, height:1.0)
        cell.holder.layer.shadowOpacity = 0.6
        cell.holder.layer.shadowRadius = 1.5
        cell.holder.layer.shouldRasterize = true

        return cell
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.user = UserDefaults.standard.object(forKey: "username") as! String
        let dateNow = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM, yyyy"
        date.text = dateFormatter.string(for: dateNow);
        dateFormatter.dateFormat = "MM"
        currentMonth = Int(dateFormatter.string(from: dateNow))!;
        dateFormatter.dateFormat = "yyyy"
        currentYear = Int(dateFormatter.string(from: dateNow))!;
        
        tableview.dataSource = self
        tableview.backgroundColor = UIColor.init(red: 225/255, green: 234/255, blue: 243/255, alpha: 1);
        
        //picker view
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.blackTranslucent
        toolBar.tintColor = UIColor.white
        toolBar.backgroundColor = UIColor.black
        let okBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(myViewController.donePressed))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        label.font = UIFont(name: "Helvetica", size: 12)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.text = "Select a Date"
        label.textAlignment = NSTextAlignment.center
        let textBtn = UIBarButtonItem(customView: label)
        toolBar.setItems([flexSpace,textBtn,flexSpace,okBarBtn], animated: true)
        self.date.inputAccessoryView = toolBar
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchDataFromFirebase(month: self.currentMonth, year: self.currentYear);
            
            
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
            
        }
        
    }
    
    @IBAction func changeDate(_ sender: UITextField) {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = newView
    }
    
    //finish changing date
    func donePressed(_ sender: UIBarButtonItem) {
        if newView.month != 0 {
            currentMonth = newView.month
            currentYear = newView.year
        }
        date.text = months[currentMonth] + ", " + String(currentYear)
        
        self.date.resignFirstResponder()
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchDataFromFirebase(month: self.currentMonth, year: self.currentYear);
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
            
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addSegue" {
            guard let addVC = segue.destination as? AddMeTransaction else { return }
            addVC.user = self.user
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    
}
