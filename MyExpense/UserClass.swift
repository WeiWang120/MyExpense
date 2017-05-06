//
//  User.swift
//  MyExpense
//
//  Created by YUAN GAO on 4/9/17.
//  Copyright © 2017 YUAN GAO. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class ExpenseUser {
    
    var userId: String = ""
    var transactions : [PersonalExpense]! = []
    
    init(id:String) {
        userId = id
    }
    
    

}
