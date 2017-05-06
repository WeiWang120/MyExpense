//
//  GroupSectionVC.swift
//  MyExpense
//
//  Created by Zimu Wang on 4/15/17.
//  Copyright © 2017 YUAN GAO. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase




class groupCell : UITableViewCell {
    
    @IBOutlet weak var oweResult: UILabel!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var holder: UIView!
    var id: String = "";
}


class groupViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var groupNameArray: [String] = [];
    var groupIdArray: [String] = [];
    var user: String = "Carl";
    var debtArray:[Double] = []
    @IBOutlet weak var tableview: UITableView!
    
    func addGroup(groupName:String, description: String, members: [String: String]){
        let ref = FIRDatabase.database().reference()
        let key = ref.child("groups").childByAutoId().key
        let newGroup = [
            "description": description,
            "groupname": groupName,
            "members": members
            ] as [String : Any]
        let childUpdates = ["/groups/\(key)/": newGroup]
        ref.updateChildValues(childUpdates)
        
        for value in members{
            let group = [key:groupName]
            ref.child("users/\(value.key)/groups").updateChildValues(group)
            //print(value.key)
        }
        
        
    }
    
    
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
    
    func fetchGroupName() {
        let ref = FIRDatabase.database().reference()
        
        ref.observe(FIRDataEventType.value, with: { (snapshot) in
            self.groupNameArray.removeAll();
            self.groupIdArray.removeAll();
            
            self.groupNameArray.removeAll();
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            let usersDB = postDict["users"] as? [String : AnyObject] ?? [:]
            let groups = usersDB[self.user] as? [String : AnyObject] ?? [:]
            let groupsDict = groups["groups"] as? [String : AnyObject] ?? [:]
            self.debtArray.removeAll()
            for (id, groupName) in groupsDict{
                self.groupIdArray.append(id);
                self.groupNameArray.append(groupName as! String);
                self.fetchDebt(groupid: id)
            }
            self.tableview.reloadData()
            
        })
        
    }
    
    func fetchDebt(groupid:String){
        
        let ref = FIRDatabase.database().reference()
        
        ref.observe(FIRDataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            let groupsDB = postDict["groups"] as? [String : AnyObject] ?? [:]
            let group = groupsDB[groupid] as? [String : AnyObject] ?? [:]
            
            let membersDB = group["members"] as? [String : AnyObject] ?? [:]
            
            for (key,value) in membersDB{
                if key == self.user{
                    self.debtArray.append((value as? Double ?? 0)!)
                }
            }
            if self.debtArray.count == self.groupNameArray.count {
                self.tableview.reloadData()
            }
        })
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return debtArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! groupCell
        cell.backgroundColor = UIColor.clear
        cell.groupName.text = self.groupNameArray[indexPath.row];
        cell.id = self.groupIdArray[indexPath.row];
 
        let money = self.debtArray[indexPath.row]
        if money < 0 {
            cell.oweResult.text = "You owed $\(String(-1.0 * money))"
        } else {
            cell.oweResult.text = "You paid $\(String(money))"
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let grouptransactionVC = self.storyboard?.instantiateViewController(withIdentifier: "grouptransactionVC") as! GroupTransactionVC
        
        grouptransactionVC.groupNametest = self.groupNameArray[indexPath.row]
        grouptransactionVC.groupid = self.groupIdArray[indexPath.row]
        navigationController?.pushViewController(grouptransactionVC, animated: true)
        
        //self.present(grouptransactionVC, animated: true, completion: nil)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        self.user = UserDefaults.standard.object(forKey: "username") as! String
        self.tableview.dataSource = self
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchGroupName();
            
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
            
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.user = UserDefaults.standard.object(forKey: "username") as! String
        self.tableview.dataSource = self
        self.tableview.delegate = self
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchGroupName();
            
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
        //self.tableview.separatorStyle = UITableViewCellSeparatorStyle.none
        
    }
    
}
