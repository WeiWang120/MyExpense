//
//  GroupTransaction.swift
//  MyExpense
//
//  Created by 杜梓宸 on 4/15/17.
//  Copyright © 2017 YUAN GAO. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

struct GroupExpense {
    var groupid : String = ""
    var payer : String = ""
    var category: Int = 0
    var year: Int = 0
    var month: Int = 0
    var day: Int = 0
    var description: String = ""
    var individualpay: [String:Double] = ["":0]
    let payamount: Double = 0.0
    init(payer:String, gi: String, yr:Int, mon:Int, d:Int, categ: Int, indpay: [String:Double], descri: String){
        self.payer = payer
        self.year = yr
        self.month = mon
        self.day = d
        self.category = categ
        self.individualpay = indpay
        self.groupid = gi
        self.description = descri
    }
    
    func uploadGroupExpense(){
        
        var upload = true
        var members:[String:Double] = [:]
        var owed = 0.0
        let ref = FIRDatabase.database().reference()
        ref.observe(FIRDataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            let groupsDB = postDict["groups"] as? [String : AnyObject] ?? [:]
            let group = groupsDB[self.groupid] as? [String : AnyObject] ?? [:]
            let memberDB = group["members"] as? [String : AnyObject] ?? [:]
            print(memberDB)
            for (key,value) in memberDB {
                members[key] = value as? Double ?? 0.0
            }
            print(members)
            for (key,value) in self.individualpay{
                if (key == self.payer){
                    owed = value + owed
                }else{
                    owed = owed - value
                }
            }
            for (key,value) in self.individualpay{
                if key == self.payer{
                    members[key] = owed + members[key]!
                }else{
                    members[key] = value * -1 + members[key]!
                }
            }
            if upload {
                ref.child("/groups/\(self.groupid)/members/").setValue(members)
                upload = false
            }
        })

        let key = ref.child("groups").child(self.groupid).child("transactions").childByAutoId().key
        let wholeDate = [ "year": self.year,
                          "month": self.month,
                          "day": self.day]
        let totalTransaction = [
            "description":self.description,
            "category": self.category,
            "date": wholeDate,
            "money": self.individualpay,
            "payer": self.payer
            ]  as [String : Any]
        //let groupchildUpdates = ["/groups/\(self.groupid)/transactions/\(key)/": totalTransaction]
        
        
        ref.child("/groups/\(self.groupid)/transactions/\(key)/").updateChildValues(totalTransaction)
        //let n = self.individualpay.count
        for value in individualpay{
            let ref = FIRDatabase.database().reference()
            let key = ref.child("transactions").child(value.key).childByAutoId().key
            let wholeDate = [ "year": self.year,
                              "month": self.month,
                              "day": self.day]
            let money = value.value * -1
            let transaction = [
                "category": self.category,
                "date": wholeDate,
                "money": money
                ] as [String : Any]
            let childUpdates = ["/transactions/\(value.key)/\(key)/": transaction]
            ref.updateChildValues(childUpdates)
        }
    }
}

