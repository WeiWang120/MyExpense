//
//  MeTransaction.swift
//  MyExpense
//
//  Created by YUAN GAO on 4/9/17.
//  Copyright © 2017 YUAN GAO. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth


struct PersonalExpense {
    
    var year: Int = 1990
    var month: Int = 1
    var date: Int = 30
    var username: String = ""
    var category: Int = 0
    var amount : Double = 0
    
    init(user:String, yr:Int, mon:Int, d:Int, categ: Int, amt: Double) {
        self.year = yr
        self.username = user
        self.month = mon
        self.date = d
        self.category = categ
        self.amount = amt
        
    }

    
     func uploadExpense(){
        let ref = FIRDatabase.database().reference()
        let key = ref.child("transactions").child(self.username).childByAutoId().key
        let wholeDate = [ "year": self.year,
                     "month": self.month,
                     "day": self.date]
        let transaction = [
            "category": self.category,
            "date": wholeDate,
            "money": self.amount
            ] as [String : Any]
        
        let childUpdates = ["/transactions/\(self.username)/\(key)/": transaction]
        ref.updateChildValues(childUpdates)
        
        
    }

    


}
