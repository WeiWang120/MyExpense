//
//  addPageVC.swift
//  MyExpense
//
//  Created by Zimu Wang on 4/15/17.
//  Copyright © 2017 YUAN GAO. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

import UIKit

protocol addGroupCellDelegate {
    func addGroupCell(didSelect cell:addGroupCell)
    func addGroupCell(cell:addGroupCell, editingChangedInTextField newText:String)
}

extension addGroupCell {
    func didSelectCell() {
        textfield.becomeFirstResponder()
        delegate?.addGroupCell(didSelect: self)
    }
    
}

class addGroupCell : UITableViewCell {
    
   
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var textfield: UITextField!
    var delegate: addGroupCellDelegate?
   
    override func awakeFromNib() {
        super.awakeFromNib()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(addGroupCell.didSelectCell))
        addGestureRecognizer(gesture)
    }


    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        if let text = sender.text {
            //let currentTag = sender.tag
            //self.members[currentTag] = sender.text!
            delegate?.addGroupCell(cell: self, editingChangedInTextField: text)
            
        }
        
    }

}

extension addGroupViewController: addGroupCellDelegate {
    
    func addGroupCell (didSelect cell:addGroupCell) {
        if let indexPath = tableview.indexPath(for: cell){
            print("didSelect cell: \(indexPath)")
        }
    }
    
    func addGroupCell(cell:addGroupCell, editingChangedInTextField newText:String) {
        if let indexPath = tableview.indexPath(for: cell){
            print("editingChangedInTextField: \"\(newText)\" in cell: \(indexPath.row)")
            //if (indexPath.row < membersNum) {
                //members[indexPath.row] = newText;
            //}
            members[indexPath.row] = newText;
            
            

        }
    }
}


class addGroupViewController : UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableview: UITableView!
    var user: String = "";
    var membersNum = 0;
    var names:[String] = []
    var members: [String] = [""];
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var descriptionTF: UITextField!

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return membersNum + 1;
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        membersNum += 1;
        members.append("");
        let indexpath = NSIndexPath(row: membersNum - 1, section: 0)
        let cell = tableview.cellForRow(at: indexpath as IndexPath) as! addGroupCell
        cell.addButton.isHidden = true;
        cell.textfield.isHidden = false;
        cell.textfield.isEnabled = true;
        
        tableview.beginUpdates()
        tableview.insertRows(at: [IndexPath(row: membersNum, section: 0)], with: .automatic)
        tableview.endUpdates()
    }
    
 
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addgroupcell") as! addGroupCell
        cell.delegate = self
        
        if (indexPath.row == membersNum) {
            print("row is: \(indexPath.row)")
            cell.addButton.isHidden = false;
            cell.textfield.isEnabled = false;
            cell.textfield.text = "";
            
        }
        else if indexPath.row == 0 {
            cell.textfield.text = user;
            members[indexPath.row] = user;
            cell.addButton.isHidden = true;
            cell.textfield.isHidden = false;
            cell.textfield.isEnabled = false;
        }
        else {
            cell.textfield.text = members[indexPath.row];
            cell.addButton.isHidden = true;
            cell.textfield.isHidden = false;
            cell.textfield.isEnabled = true;
        }
        
        
        
        return cell
        /*
        let cell =  tableView.dequeueReusableCell(withIdentifier: "addgroupcell", for: indexPath) as! addGroupCell
        let index = indexPath.row;
        if index == membersNum { //last row
            cell.addButton.isHidden = false;
        }
        else {
            cell.addButton.isHidden = true;
            cell.textfield.isHidden = false;
        }
        
        return cell*/
        
        
    }
    
    func checkUsername(name: String) -> Int {
        
        /*var exist: Int = 0;
        let ref = FIRDatabase.database().reference()
        ref.observe(FIRDataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            let a = postDict["users"] as? [String : AnyObject] ?? [:]
            for (_,value) in a{
                if (value as? String == name) {
                    return 1
                }
            }
            
        })
        
        return exist*/
        return 1;
    }
    
    
    func check(name: String) -> Bool{
        var exist = false;
            for thename in names{
                if (thename as? String == name) {
                    exist = true;
                }
            }
        return exist;
    }
    
    
    
    @IBAction func submitAddGroup(_ sender: UIButton) {
        var filtered = [String: String]();
        let name = groupName.text;
        let des = descriptionTF.text;
        if (name?.isEmpty)! {
            msgAlert(msg: "Please Enter a Valid Group Name");
        }
        
        var validAddGroup: Bool = true;
        for name in members {
            let trimmedString = name.trimmingCharacters(in: .whitespaces)
            if !trimmedString.isEmpty {
                //print(trimmedString);
                
                let exist = check(name: name)
                print(exist);
                if (!exist) {
                    validAddGroup = false;
                    msgAlert(msg: "Please Add a Registered Member");
                    
                }
                else {
                    let keyExists = (filtered[name] != nil)
                    if keyExists {
                        validAddGroup = false;
                        msgAlert(msg: "Duplicate Member Names");
                    }
                    else { filtered.updateValue("0", forKey: name) }
                }
                
                
            }
        }
        if (validAddGroup) {
            addGroup(groupName: name!, description: des!, members: filtered);
        }
        
    }
    
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
        
        let home = self.storyboard?.instantiateViewController(withIdentifier: "Homepage") as! CustomTabBarViewController
        home.selectedIndex = 1;
        UserDefaults.standard.set(true, forKey: "second")
        
        self.present(home, animated: true, completion: nil)
    }
    
    func msgAlert(msg: String) {
        let alertController = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func backButtonClicked(_ sender: UIButton) {
        let home = self.storyboard?.instantiateViewController(withIdentifier: "Homepage") as! CustomTabBarViewController
        home.selectedIndex = 1;
        UserDefaults.standard.set(true, forKey: "second")
        self.present(home, animated: true, completion: nil)
    }
    
    func fetchNames(){
        let ref = FIRDatabase.database().reference()
        ref.observe(FIRDataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            let a = postDict["users"] as? [String : AnyObject] ?? [:]
            for (key,_) in a{
               self.names.append(key)
            }
        })

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.user = UserDefaults.standard.object(forKey: "username") as! String
        self.tableview.dataSource = self
        self.membersNum = 1;
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchNames()
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
            
        }
    }
    
}
