//
//  AddMeTransaction.swift
//  MyExpense
//
//  Created by YUAN GAO on 4/9/17.
//  Copyright © 2017 YUAN GAO. All rights reserved.
//

import UIKit

class AddMeTransaction: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var user:String = "default"
    
    
    
    @IBOutlet weak var dateShown: UITextField!
    @IBOutlet weak var categShown: UITextField!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var CategPickerView: UIView!
    @IBOutlet weak var CategPicker: UIPickerView!
    @IBOutlet weak var amountFilled: UITextField!
    @IBOutlet weak var incomeBtn: UIButton!
    @IBOutlet weak var expenseBtn: UIButton!
    @IBOutlet weak var warning: UILabel!
    @IBOutlet weak var whiteBack: UIView!
    @IBOutlet weak var addBtn: UIButton!
    
    var year: Int = 0
    var month:Int = 0
    var day: Int = 0
    var categ: Int = 0
    var isIncome: Double = -1.0
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryStr.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryStr[row]
    }
    
    @IBAction func datePickerOpen(_ sender: UITextField) {
        CategPickerView.isHidden = true
        datePickerView.isHidden = false
        
    }
    
    @IBAction func catPickerOpen(_ sender: UITextField) {
        datePickerView.isHidden = true
        CategPickerView.isHidden = false
        
    }
    
    
    @IBAction func IncomePressed(_ sender: UIButton) {
        incomeBtn.backgroundColor = UIColor(red: 63/255, green: 77/255, blue: 107/255, alpha: 1)
        expenseBtn.backgroundColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        isIncome = 1.0
        
    }
    @IBAction func ExpensePressed(_ sender: UIButton) {
        
        expenseBtn.backgroundColor = UIColor(red: 63/255, green: 77/255, blue: 107/255, alpha: 1)
        incomeBtn.backgroundColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        isIncome = -1.0
        
        
    }
    
    @IBAction func amountFilled(_ sender: UITextField) {
        warning.isHidden = true;
    }
    
    @IBAction func AddPressed(_ sender: UIButton) {
        //if not casting
        print("Category is " + String(categ))
        let amount = Double(amountFilled.text!)
        if (amount == nil){
            print("wrong input")
            warning.isHidden = false;
            amountFilled.endEditing(true)
        } else {
            let trueAmt = isIncome * amount!
            let newExp = PersonalExpense(user: self.user, yr: year, mon: month, d: day, categ: categ, amt: trueAmt)
            
            newExp.uploadExpense();
            print("uploaded")
            let home = self.storyboard?.instantiateViewController(withIdentifier: "Homepage")
            self.present(home!, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func DatePickedDone(_ sender: UIButton) {
        let date = DatePicker.date
        dateDisplay(d: date)
        datePickerView.isHidden = true
        dateShown.endEditing(true)
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categ = row
        categShown.text = categoryStr[row]
        
        
    }
    
    @IBAction func CategPickerDone(_ sender: UIButton) {
        
        CategPickerView.isHidden = true
        categShown.endEditing(true)
    }
    
    func dateDisplay(d:Date) {
        let dateFm = DateFormatter()
        dateFm.dateStyle = DateFormatter.Style(rawValue: 2)!
        dateShown.text = dateFm.string(from: d)
        let calendar = self.DatePicker.calendar
        year = calendar!.component(.year, from: d)
        month = calendar!.component(.month, from: d)
        day = calendar!.component(.day, from: d)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "cancelAddSegue" {
            guard let mainVC = segue.destination as? myViewController else { return }
            mainVC.user = self.user
        }
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        whiteBack.layer.borderColor = UIColor.gray.cgColor;
        whiteBack.layer.borderWidth = 0.0
        whiteBack.layer.cornerRadius = 20;
        whiteBack.layer.masksToBounds = true
        whiteBack.layer.shadowRadius = 2.0
        whiteBack.layer.shadowColor = UIColor.gray.cgColor
        whiteBack.layer.shadowOffset = CGSize(width: 1.0, height:1.0)
        whiteBack.layer.shadowOpacity = 0.6
        whiteBack.layer.shadowRadius = 1.5
        whiteBack.layer.shouldRasterize = true
        
        
        

        expenseBtn.backgroundColor = UIColor(red: 63/255, green: 77/255, blue: 107/255, alpha: 1)
        expenseBtn.layer.cornerRadius = 5;
        expenseBtn.layer.masksToBounds = true;
        incomeBtn.layer.cornerRadius = 5;
        incomeBtn.layer.masksToBounds = true;
        addBtn.layer.cornerRadius = 5;
        addBtn.layer.masksToBounds = true;
        
        CategPicker.dataSource = self
        CategPicker.delegate = self
        
        dateDisplay(d: Date())

        
        
        
        //dateShown.text =
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



