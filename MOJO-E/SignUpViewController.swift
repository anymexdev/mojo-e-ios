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
    @IBOutlet weak var userNameTextField: UITextField!
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
        if usernameTextField.text?.characters.count > 4 {
            if let email = emailTextField.text {
                myRootRef.createUser(email, password: passwordTextField.text!,
                     withValueCompletionBlock: { error, result in
                        if error != nil {
                            if let errorCode = FAuthenticationError(rawValue: error.code) {
                                switch (errorCode) {
                                case .NetworkError:
                                    Utility.showToastWithMessage(kErrorNetwork)
                                default:
                                    Utility.showToastWithMessage(kErrorSignUpCantCreateUser)
                                }
                            }
                        } else {
//                            usersRef.childByAppendingPath(currentUser?.uId).childByAppendingPath("username").setValue(usernameTextField.text!)
                            myRootRef.authUser(self.emailTextField.text, password: self.passwordTextField.text) { (error, authData) -> Void in
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
                                        if let _ = snapshot.value as? NSDictionary {
                                            Utility.openAuthenticatedFlow()
                                        }
                                        }, withCancelBlock: { error in
                                    })
                                }
                            }
                        }
                })
            }
        } else {
            if !(usernameTextField.text?.characters.count > 4) {
                Utility.showToastWithMessage(kErrorUserNameShort)
            }
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
        emailTextField.enabled = false
    }
    
    func endEditing() {
        self.view.endEditing(true)
    }
    
}
