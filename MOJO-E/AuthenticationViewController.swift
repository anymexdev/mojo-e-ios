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
    
    // MARK: Class's properties
    
    
    // Mark: Application's life cirlce
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
        //
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AuthenticationViewController.endEditing))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        // Setup delegates
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
    
    
    func setCurrentUser(uid: String, data: NSDictionary ) {
//        UserInfo.sharedInstance().currentUserInfo = User.createInManagedObjectContext(appDelegate.managedObjectContext, uid: uid, data: data)
//        currentUser = User.createInManagedObjectContext(appDelegate.managedObjectContext, uid: uid, data: data)
//        if let _ = try? appDelegate.managedObjectContext.save() {
//            // Save ok
//            print("Coredata save OK")
//        }
//        else {
//            // Save error
//            print("Coredata save Error")
//        }
     }
    
    //MARK: Login via Email
    @IBAction func signInAction(sender: AnyObject) {
        myRootRef.authUser(emailTextField.text, password: passwordTextField.text) { (error, authData) -> Void in
            if error != nil {
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
                let myCurrentUsersRef = Firebase(url: "\(kFireBaseUsersUrl)/\(authData.uid)")
                // load snapshot of user
                myCurrentUsersRef.observeSingleEventOfType(.Value, withBlock: {
                    snapshot in
                    print(snapshot.value)
                    if let data = snapshot.value as? NSDictionary {
                        self.setCurrentUser(authData.uid, data: data)
                        print(authData.auth)
                        Utility.openAuthenticatedFlow()
                    }
                    }, withCancelBlock: { error in
                        print(error.description)
                        
                })
              // self.setCurrentUser(authData.uid, data: newUser)
               
            }
        }
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
        
    }
    
    func endEditing() {
        self.view.endEditing(true)
    }
    
}