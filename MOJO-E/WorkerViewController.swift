//
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices

class WorkerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: UI element
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var confirmLabel: UILabel!
    @IBOutlet weak var specialitiesLabel: UILabel!
    @IBOutlet weak var companiesLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var changeAvatarButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var availableSwitch: UISwitch!
    @IBOutlet weak var avatarImage: UIImageView!
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
            profile.phone = phoneTextField.text!
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
    
    @IBAction func changeAvatar(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.allowsEditing = false
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: Functions
    func toggleEditMode(editable: Bool) {
        usernameTextField.hidden = !editable
        emailTextField.hidden = !editable
        passwordTextField.hidden = !editable
        confirmPasswordTextField.hidden = !editable
        cancelButton.hidden = !editable
        changeAvatarButton.hidden = !editable
        phoneTextField.hidden = !editable
        
        usernameLabel.hidden = editable
        emailLabel.hidden = editable
        passwordLabel.hidden = editable
        confirmLabel.hidden = editable
        phoneLabel.hidden = editable
    }
    
    func initialize() {
        self.avatarImage.layer.borderColor = Utility.greenL0Color().CGColor
        self.avatarImage.layer.borderWidth = 2
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.endEditing))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WorkerViewController.keyboardWillChangeFrameNotification(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
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
        profile?.syncFromFirebase({ (profile) in
            if let profile = profile {
                self.profile = profile
                self.companiesLabel.text = profile.companies
                self.specialitiesLabel.text = profile.specialties
                self.phoneLabel.text = profile.phone
                self.phoneTextField.text = profile.phone
                self.availableSwitch.on = profile.isAvailibity
                Utility.downloadImage(profile.photoURL, viewToDisplay: self.avatarImage)
            }
        })
    }
    
    func endEditing() {
        self.view.endEditing(true)
    }
    
    func keyboardWillChangeFrameNotification(notification: NSNotification) {
        let n = KeyboardNotification(notification)
        let keyboardFrame = n.frameEndForView(self.view)
        let animationDuration = n.animationDuration
        let animationCurve = n.animationCurve
        let viewFrame = self.view.frame
        let newBottomOffset = viewFrame.maxY - keyboardFrame.minY
        print("newBottomOffset is \(newBottomOffset)")
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(animationDuration,
                                   delay: 0,
                                   options: UIViewAnimationOptions(rawValue: UInt(animationCurve << 16)),
                                   animations: {
                                    if newBottomOffset > 0 {
                                        // Keyboard will show
                                        self.bottomConstraint.constant = -newBottomOffset
                                    }
                                    else {
                                        // keyboard will hide
                                        self.bottomConstraint.constant = 0
                                        
                                    }
                                    self.view.layoutIfNeeded()
            },
                                   completion: nil
        )
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
    
    //MARK: PickerImage Delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        avatarImage.image = image
        avatarImage.contentMode = .ScaleAspectFit
        self.dismissViewControllerAnimated(true) { 
            self.toggleEditMode(true)
        }
    }
}
