//
//  ViewController.swift
//  MyExpense
//
//  Created by YUAN GAO on 4/7/17.
//  Copyright © 2017 YUAN GAO. All rights reserved.
//


import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController {
    
    
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    
    @IBOutlet weak var signUpEmail: UITextField!
    @IBOutlet weak var signUpPassword: UITextField!
    @IBOutlet weak var signUpConfirm: UITextField!
    @IBOutlet weak var signUpUsername: UITextField!
    var validUsername: Bool = true;
    var userName: String = "default"
    
    @IBOutlet weak var invalidUsername: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBAction func login(_ sender: UIButton) {
        if loginEmail.text == "" {
            msgAlert(msg: "Please enter your email")
            
        }
        else if loginPassword.text == "" {
            msgAlert(msg: "Please enter your password")
        }
        else {
            FIRAuth.auth()?.signIn(withEmail: loginEmail.text!, password: loginPassword.text!) { (user, error) in
                
                if error == nil {
                    self.spinner.isHidden = false;
                    self.spinner.startAnimating()
                    print("You have successfully logged in")
                    self.fetchUsernameFromFirebase(uid: (user?.uid)!)
                    //self.loadHomePage()
                    
                } else {
                    self.msgAlert(msg: (error?.localizedDescription)!)
                    
                }
            }
            
        }
        
    }
    
    @IBAction func checkUsername(_ sender: Any) {
        validUsername = true;
        let ref = FIRDatabase.database().reference()
        ref.observe(FIRDataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            let a = postDict["users"] as? [String : AnyObject] ?? [:]
            for (_,value) in a{
                if (value as? String == self.signUpUsername.text) {
                    self.validUsername = false;
                }
            }
            if self.validUsername {
                self.invalidUsername.isHidden = true;
            }
            else {
                self.invalidUsername.isHidden = false;
            }
            
        })
        
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        if signUpUsername.text == "" {
            msgAlert(msg: "Please enter your preferred username")
        }
        else if signUpEmail.text == "" {
            msgAlert(msg: "Please enter your email")
            
        }
        else if signUpPassword.text == "" {
            msgAlert(msg: "Please enter your password")
            
        }
        else if signUpConfirm.text == "" {
            msgAlert(msg: "Please confirm your password")
        }
        else if signUpConfirm.text != signUpPassword.text {
            msgAlert(msg: "Your confirmed password is different from your entered password")
        }
            
        else if validUsername{
            self.invalidUsername.isHidden = true;
            FIRAuth.auth()?.createUser(withEmail: signUpEmail.text!, password: signUpPassword.text!) { (user, error) in
                
                if error == nil {
                    if let currentUser = FIRAuth.auth()?.currentUser{//sign up successfully
                        let uid = currentUser.uid
                        let ref = FIRDatabase.database().reference()
                        let username: String = self.signUpUsername.text!
                        let userid = [uid:username]
                        let newuser = [username:"groups"]
                        UserDefaults.standard.set(self.signUpUsername.text!, forKey: "username")
                        /*save to user object*/
                        
                        ref.child("users").updateChildValues(userid)
                        ref.child("users").updateChildValues(newuser)
                        self.loadHomePage();

                        
                    }
                    self.invalidUsername.text = "";
                    self.invalidUsername.isHidden = true;
                    
                    
                } else {
                    self.msgAlert(msg: (error?.localizedDescription)!)
                }
            }
        }
        
        
    }
    
    
    
    func msgAlert(msg: String) {
        let alertController = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func loadHomePage() {
        let home = self.storyboard?.instantiateViewController(withIdentifier: "Homepage") as! CustomTabBarViewController
        
        self.present(home, animated: true, completion: nil)
    }
    
    
    func fetchUsernameFromFirebase(uid:String) {
        
        let ref = FIRDatabase.database().reference()
        
        ref.observe(FIRDataEventType.value, with: { (snapshot) in
            
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            let a = postDict["users"] as? [String : AnyObject] ?? [:]
            let ur = a[uid]! as! String
            UserDefaults.standard.set(ur, forKey: "username")
            self.spinner.stopAnimating()
            self.loadHomePage()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background5-1")!);
        UserDefaults.standard.set(false, forKey: "second")
        //self.view.alpha = 0.8;
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

