//
//  AddGroupTransactionViewController.swift
//  MyExpense
//
//  Created by YUAN GAO on 4/15/17.
//  Copyright © 2017 YUAN GAO. All rights reserved.
//

import UIKit




class AddGroupTransactionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    

    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categPickerView: UIView!
    @IBOutlet weak var categPicker: UIPickerView!
    @IBOutlet weak var payerPickerView: UIView!
    @IBOutlet weak var payerPicker: UIPickerView!
 
    
    @IBOutlet weak var categShown: UITextField!
    @IBOutlet weak var payerShown: UITextField!
    @IBOutlet weak var dateShown: UITextField!
    
    @IBOutlet weak var warning1: UILabel!
    @IBOutlet weak var warning2: UILabel!
    @IBOutlet weak var warning3: UILabel!
    
    @IBOutlet weak var total: UITextField!
    @IBOutlet weak var whiteBack: UIView!
    
    @IBOutlet weak var descriptField: UITextView!
    
    @IBOutlet weak var butShape: UIButton!
    
    
    
    var year: Int = 0
    var month:Int = 0
    var day: Int = 0
    var categ: Int = 0
    var memNames: [String] = []
    var payer = 0;
    var groupID = ""
    var splitWay = -1
    var groupName: String = ""
    

   
//picker functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == payerPicker){
            return memNames.count;
        }
        return categoryStr.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == payerPicker){
            return memNames[row];
        }

        return categoryStr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == payerPicker){
            payerShown.text = memNames[row]
            payer = row

        } else {
            self.categ = row
            categShown.text = categoryStr[row]
        }
        
        
    }
    

    
//description field
    
    
    @IBAction func datePickerOpen(_ sender: UITextField) {
        datePickerView.isHidden = false
        categPickerView.isHidden = true
        payerPickerView.isHidden = true
        
    }

    @IBAction func categPickerOpen(_ sender: UITextField){
        datePickerView.isHidden = true
        payerPickerView.isHidden = true
        categPickerView.isHidden = false
    }
    
    @IBAction func payerPickerOpen(_ sender: UITextField) {
        payerPickerView.isHidden = false
        datePickerView.isHidden = true
        categPickerView.isHidden = true
    }
    
    
    @IBAction func categPickerDone(_ sender: UIButton) {
        categPickerView.isHidden = true
        categShown.endEditing(true)
    }
    
    
    @IBAction func datePickerDone(_ sender: UIButton) {
        datePickerView.isHidden = true
        let d = datePicker.date
        dateDisplay(d: d)
        dateShown.endEditing(true)
    }
    

    @IBAction func payerPickerDone(_ sender: UIButton) {
        payerPickerView.isHidden = true
        payerShown.endEditing(true)
        //memberTable.reloadData()
        //fix Payer!!!!!!!!!!!!!!!!!!!!!! to be edited

    }
    

    @IBAction func addTransaction(_ sender: UIButton) {
        warning1.isHidden = true
        warning2.isHidden = true
        warning3.isHidden = true
        var isDigit = true
     
        
        
        //test if total number is valid
        let total_dob = Double(total.text!)
        isDigit = (total_dob != nil)
        
        if (isDigit == false) {
            warning1.isHidden = false;
        } else {
            //test if there are negative numbers
            if (total_dob! <= 0.0) {
                warning3.isHidden = false;
            } else {
                let total_pay = total_dob!
                    //split among or exact
                    if splitWay == 2 {
                        let page = self.storyboard?.instantiateViewController(withIdentifier: "SplitPage") as! SplitByExactVC
                        page.groupID = self.groupID
                        page.payer = self.payer
                        page.memNames = self.memNames
                        page.year = self.year
                        page.month = self.month
                        page.day = self.day
                        page.categ = self.categ
                        page.descript = descriptField.text
                        page.total = total_pay
                        page.groupName = self.groupName
                        //self.present(page, animated: true, completion: nil)
                        navigationController?.pushViewController(page, animated: true)
                        
                    
                    } else if splitWay == 1 {
                        //among
                            let page = self.storyboard?.instantiateViewController(withIdentifier: "AmongPage") as! SplitAmongVC
                            page.groupID = self.groupID
                            page.payer = self.payer
                            page.memNames = self.memNames
                            page.year = self.year
                            page.month = self.month
                            page.day = self.day
                            page.categ = self.categ
                            page.descript = descriptField.text
                            page.total = total_pay
                            page.groupName = self.groupName
                            //self.present(page, animated: true, completion: nil)
                            navigationController?.pushViewController(page, animated: true)
                    } else {
                        let memCount = memNames.count
                        var indPay: [String:Double] = [:]
                        let eachPay = round(total_pay/Double(memCount) * 100) / 100
                        for i in 0..<memCount {
                            if i == payer {
                                indPay[memNames[i]] = total_pay
                            } else {
                                indPay[memNames[i]] = eachPay
                            }
                            
                        }
                        let gexp = GroupExpense.init(payer: memNames[self.payer], gi: self.groupID, yr: self.year, mon: self.month, d: self.day, categ: self.categ, indpay: indPay, descri: descriptField.text)
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
            
                guard let groupViewCont = segue.destination as? GroupTransactionVC else { return }
                groupViewCont.groupid = self.groupID
                groupViewCont.groupNametest = self.groupName
            
            
        }
        
        
    }

    
    func dateDisplay(d:Date) {
        let dateFm = DateFormatter()
        dateFm.dateStyle = DateFormatter.Style(rawValue: 2)!
        dateShown.text = dateFm.string(from: d)
        let calendar = self.datePicker.calendar
        year = calendar!.component(.year, from: d)
        month = calendar!.component(.month, from: d)
        day = calendar!.component(.day, from: d)
    }
    

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var sEqualBtn: UIButton!
    @IBOutlet weak var sAmongBtn: UIButton!
    @IBOutlet weak var sExactBtn: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBAction func splitEqualSelected(_ sender: UIButton) {
        splitWay = 0
        
        sEqualBtn.backgroundColor = UIColor(red: 63/255, green: 77/255, blue: 107/255, alpha: 1)
        sAmongBtn.backgroundColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        sExactBtn.backgroundColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        
        nextButton.isHidden = true
        addButton.isHidden = false

        
    }
    
    @IBAction func splitAmongSelected(_ sender: UIButton) {
        
        splitWay = 1
        
        sAmongBtn.backgroundColor = UIColor(red: 63/255, green: 77/255, blue: 107/255, alpha: 1)
        sExactBtn.backgroundColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        sEqualBtn.backgroundColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        addButton.isHidden = true
        nextButton.isHidden = false


    }
    
    @IBAction func splitExactSelected(_ sender: UIButton) {
        
        splitWay = 2
        
        sExactBtn.backgroundColor = UIColor(red: 63/255, green: 77/255, blue: 107/255, alpha: 1)
        sAmongBtn.backgroundColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        sEqualBtn.backgroundColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        addButton.isHidden = true
        nextButton.isHidden = false
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set current day, month, year
        self.dateDisplay(d: Date())
        
        //pass group id to this page
        
        
        
        
        //initialize category picker
        self.categPicker.dataSource = self
        self.categPicker.delegate = self
        
        //initialize member table and payer picker
        //load member

        self.payerPicker.dataSource = self
        self.payerPicker.delegate = self
        self.payer = 0
        self.payerShown.text! = self.memNames[0]

        

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
        nextButton.isHidden = true
        
        sEqualBtn.layer.cornerRadius = 5
        sAmongBtn.layer.cornerRadius = 5
        sExactBtn.layer.cornerRadius = 5
        sEqualBtn.backgroundColor = UIColor(red: 63/255, green: 77/255, blue: 107/255, alpha: 1)
        splitWay = 0 //equal
        print(groupName)
        
        
        // Do any additional setup after loading the view.
    }

}
