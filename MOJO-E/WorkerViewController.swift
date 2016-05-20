//
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import UIKit
import Firebase

class WorkerViewController: UIViewController {

    //MARK: UI element
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var confirmLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var actionButton: UIButton!
    
    // Mark: Class's properties
    var profile = Profile.get()
    
    //MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        toggleEditMode(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: UI's Action
    @IBAction func buttonAction(sender: AnyObject) {
        let title = actionButton.titleForState(.Normal)
        if title == "Edit" {
            actionButton.setTitle("Save", forState: .Normal)
            cancelButton.hidden = false
            toggleEditMode(true)
        }
        else if let profile = profile where validateForSaving() && title == "Save" {
            profile.email = emailTextField.text!
            profile.password = passwordTextField.text!
            profile.userName = usernameTextField.text!
            profile.syncToFirebase()
            self.backAction(passwordTextField)
        }
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        actionButton.setTitle("Edit", forState: .Normal)
        cancelButton.hidden = true
        toggleEditMode(false)
    }
    
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: Functions
    func toggleEditMode(editable: Bool) {
        usernameTextField.hidden = !editable
        emailTextField.hidden = !editable
        passwordTextField.hidden = !editable
        confirmPasswordTextField.hidden = !editable
        cancelButton.hidden = !editable
        
        usernameLabel.hidden = editable
        emailLabel.hidden = editable
        passwordLabel.hidden = editable
        confirmLabel.hidden = editable
    }
    
    func initialize() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.endEditing))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        usernameTextField.becomeFirstResponder()
        if let profile = profile {
            emailTextField.text = profile.email
            passwordTextField.text = profile.password
            confirmPasswordTextField.text = profile.password
            usernameTextField.text = profile.userName
            
            emailLabel.text = profile.email
            passwordLabel.text = profile.password
            confirmLabel.text = profile.password
            usernameLabel.text = profile.userName
        }
    }
    
    func endEditing() {
        self.view.endEditing(true)
    }
    
    private func validateForSaving() -> Bool {
        if let name = usernameTextField.text where name.count() < 4 {
            Utility.showToastWithMessage("Username should be at least 4 characters")
            return false
        }
        if let email = emailTextField.text where email.count() < 4 {
            Utility.showToastWithMessage("Email is not valid")
            return false
        }
        else {
            let email = emailTextField.text
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            if !emailTest.evaluateWithObject(email) {
                Utility.showToastWithMessage("Email is not valid")
                return false
            }
        }
        if let password = passwordTextField.text where password.count() < 6 {
            Utility.showToastWithMessage("Password should be at least 6 characters")
            return false
        }
        else {
            let password = passwordTextField.text
            let numberRegEx  = ".*[0-9]+.*"
            let passwordTest = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
            if !passwordTest.evaluateWithObject(password) {
                Utility.showToastWithMessage("Password should include at least 1 number")
                return false
            }
        }
        if let password = passwordTextField.text, let confirm = confirmPasswordTextField.text where password != confirm {
            Utility.showToastWithMessage("Confirm password doesn't match")
            return false
        }
        return true
        
    }
    
}
