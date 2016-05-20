//
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import UIKit
import Firebase

class AuthenticationViewController: UIViewController, UITextFieldDelegate  {
    
    // Mark: UI's elements
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var buildVersionLabel: UILabel!
    @IBOutlet weak var rememberSwitch: UISwitch!
    
    
    // MARK: Class's properties
    
    
    // Mark: Application's life cirlce
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    //MARK: Login via Email
    @IBAction func signInAction(sender: AnyObject) {
//        Utility.openAuthenticatedFlow()
        if let email = emailTextField.text, let password = passwordTextField.text where email.count() > 0 && password.count() > 0 {
            myRootRef.authUser(email, password: password) { (error, authData) -> Void in
                if let error = error {
                    // There was an error logging the account
                    if let errorCode = FAuthenticationError(rawValue: error.code) {
                        switch (errorCode) {
                        case .UserDoesNotExist:
                            Utility.showToastWithMessage(kErrorSignInUserDoesNotExist)
                        case .InvalidEmail:
                            Utility.showToastWithMessage(kErrorSignInInvalidEmail)
                        case .InvalidPassword:
                            Utility.showToastWithMessage(kErrorSignInInvalidPassword)
                        case .NetworkError:
                            Utility.showToastWithMessage(kErrorNetwork)
                        default:
                            Utility.showToastWithMessage(kErrorAuthenticationDefault)
                        }
                    }
                } else {
                    print("Successfully created user account with uid: \(authData.uid)")
//                    let myCurrentUsersRef = Firebase(url: "\(kFireBaseUsersUrl)/\(authData.uid)")
                    // load snapshot of user
//                    myCurrentUsersRef.observeSingleEventOfType(.Value, withBlock: {
//                        snapshot in
//                        print(snapshot.value)
//                        if let _ = snapshot.value as? NSDictionary {
//                            print(authData.auth)
//                            Utility.openAuthenticatedFlow()
//                        }
//                        }, withCancelBlock: { error in
//                            print(error.description)
//                            
//                    })
                    let profile = Profile()
                    profile.authenID = authData.uid
                    profile.isRemember = self.rememberSwitch.on
                    profile.isLogged = true
                    profile.email = email
                    profile.password = password
                    profile.saveProfile()
                    Utility.openAuthenticatedFlow()
                }
            }
        }
        else {
            Utility.showToastWithMessage(kErrorEmailIsEmpty)
        }
        
    }
    
    @IBAction func forgotPasswordAction(sender: AnyObject) {
        let url = NSURL(string: "http://google.com")!
        UIApplication.sharedApplication().openURL(url)
    }
    
    @IBAction func signUpAction(sender: AnyObject) {
        self.performSegueWithIdentifier("SignUpSegue", sender: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == passwordTextField {
            view.endEditing(true)
        }
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        return true
    }
    
    func initialize() {
        if let profile = kUserDefault.objectForKey(kUserProfile) as? Profile {
            rememberSwitch.on = profile.isRemember
            if rememberSwitch.on {
                emailTextField.text = profile.email
                passwordTextField.text = profile.password
            }
        }

        //
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AuthenticationViewController.endEditing))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        // Setup delegates
        
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            self.buildVersionLabel.text = "Build version \(version)"
        }
    }
    
    func endEditing() {
        self.view.endEditing(true)
    }
    
}