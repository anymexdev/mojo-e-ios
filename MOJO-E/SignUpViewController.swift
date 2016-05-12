//
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    //MARK: UI element
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    
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
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: UI ACtion
    @IBAction func finishAction(sender: AnyObject) {
        if let name = usernameTextField.text where name.count() > 0 {
            if let email = emailTextField.text, let password = passwordTextField.text where email.count() > 0 && password.count() > 0 {
                myRootRef.createUser(email, password: password,
                     withValueCompletionBlock: { error, result in
                        if let error = error {
                            if let errorCode = FAuthenticationError(rawValue: error.code) {
                                switch (errorCode) {
                                case .NetworkError:
                                    Utility.showToastWithMessage(kErrorNetwork)
                                default:
                                    Utility.showToastWithMessage(error.description)
                                }
                            }
                        } else {
//                            usersRef.childByAppendingPath(currentUser?.uId).childByAppendingPath("username").setValue(usernameTextField.text!)
                            var data = Dictionary<String, String>()
                            data["userName"] = name
                            data["email"] = email
                            usersRef.childByAutoId().setValue(data)
                            Utility.openAuthenticatedFlow()
                            /*
                            myRootRef.authUser(self.emailTextField.text, password: self.passwordTextField.text) { (error, authData) -> Void in
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
                                    Utility.openAuthenticatedFlow()
                                }
                            }
                            */
                        }
                })
            }
            else {
                Utility.showToastWithMessage(kErrorEmailIsEmpty)
            }
        } else {
            Utility.showToastWithMessage(kErrorNameIsEmpty)
        }
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func initialize() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.endEditing))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        usernameTextField.becomeFirstResponder()
    }
    
    func endEditing() {
        self.view.endEditing(true)
    }
    
}
