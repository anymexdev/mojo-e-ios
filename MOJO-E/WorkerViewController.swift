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
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
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
        else if let profile = self.profile where validateForSaving() && title == "Save" {
            profile.email = emailTextField.text!
            profile.userName = usernameTextField.text!
            profile.phone = phoneTextField.text!
            profile.avatarPic = avatarImage.image
            profile.isAvailibity = availableSwitch.on
            profile.syncToFirebase()
            actionButton.setTitle("Edit", forState: .Normal)
            self.toggleEditMode(false)
        }
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        actionButton.setTitle("Edit", forState: .Normal)
        cancelButton.hidden = true
        toggleEditMode(false)
    }
    
    @IBAction func backAction(sender: AnyObject) {
        if let _ = self.profile {
            self.profile!.avatarPic = self.avatarImage.image
        }
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
        cancelButton.hidden = !editable
        changeAvatarButton.hidden = !editable
        phoneTextField.hidden = !editable
        
        usernameLabel.hidden = editable
        emailLabel.hidden = editable
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
            usernameTextField.text = profile.userName
            
            emailLabel.text = profile.email
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
                self.avatarImage.image = profile.avatarPic
                self.avatarImage.contentMode = .ScaleAspectFit
                let profileRef = storage.reference().child("images/\(self.profile!.authenID).png")
                profileRef.dataWithMaxSize(1 * 1024 * 1024, completion: { (data, error) in
                    if let error = error {
                        print(error.description)
                    }
                    else {
                        if let data = data, let imageV = UIImage(data: data) {
                            self.avatarImage.image = imageV
                        }
                    }
                })
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
        return true
        
    }
    
    //MARK: PickerImage Delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        avatarImage.image = image
        avatarImage.contentMode = .ScaleAspectFit
        self.dismissViewControllerAnimated(true) { 
            self.toggleEditMode(true)
            Utility.showIndicatorForView(self.view)
            let data = UIImagePNGRepresentation(image)
            let profilePicRef = storage.reference().child("images/\(self.profile!.authenID).png")
            _ = profilePicRef.putData(data!, metadata: nil) { metadata, error in
                Utility.removeIndicatorForView(self.view)
                if (error != nil) {
                    // Uh-oh, an error occurred!
                } else {
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    let downloadURL = metadata!.downloadURL
                    if let url = downloadURL()?.absoluteString {
                        self.profile?.photoURL = url
                    }
                }
            }
        }
    }
}
