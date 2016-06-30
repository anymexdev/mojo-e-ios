///
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import Foundation

class Profile: NSObject, NSCoding {
    
    // MARK: Class's constructors
//    override init() {
//        super.init()
//    }
    
    // MARK: Class's properties
    var rating : Float = 3
    var ratingCount : Int = 0
    var userName = ""
    var photoURL = ""
    var location = ""
    var phone = ""
    var verify = false
    var rate1: Float = 0
    var rate2: Float = 0
    var rate3: Float = 0
    var rate4: Float = 0
    var rate5: Float = 0
    var createAt = "2016-01-01"
    var email = ""
    var password = ""
    var authenID = ""
    var isRemember = false
    var isLogged = false
    var isAdmin = false
    var isAvailibity = true
    var companies = ""
    var specialties = "Software developer"
    var avatarPic: UIImage?
    
    required convenience init?(coder decoder: NSCoder) {
        guard let name = decoder.decodeObjectForKey("name") as? String,
            let photoURL = decoder.decodeObjectForKey("photoURL") as? String,
            let email = decoder.decodeObjectForKey("email") as? String,
            let password = decoder.decodeObjectForKey("password") as? String,
            let authenID = decoder.decodeObjectForKey("authenID") as? String,
            let location = decoder.decodeObjectForKey("location") as? String,
            let companies = decoder.decodeObjectForKey("companies") as? String,
            let specialties = decoder.decodeObjectForKey("specialties") as? String,
            let phone = decoder.decodeObjectForKey("phone") as? String,
            let createAt = decoder.decodeObjectForKey("createAt") as? String
            else { return nil }
        
        self.init()
        self.userName = name
        self.createAt = createAt
        self.photoURL = photoURL
        self.rating = decoder.decodeFloatForKey("rating")
        self.ratingCount = decoder.decodeIntegerForKey("ratingCount")
        self.verify = decoder.decodeBoolForKey("verify")
        self.location = location
        self.phone = phone
        self.email = email
        if let avatarData = decoder.decodeObjectForKey("avatarPic") as? NSData {
            self.avatarPic = UIImage(data: avatarData)
        }
        self.password = password
        self.authenID = authenID
        self.isRemember = decoder.decodeBoolForKey("isRemember")
        self.isAvailibity = decoder.decodeBoolForKey("isAvailibity")
        self.isAdmin = decoder.decodeBoolForKey("isAdmin")
        self.companies = companies
        self.specialties = specialties
        self.isLogged = decoder.decodeBoolForKey("isLogged")
        self.rate1 = decoder.decodeFloatForKey("rate1")
        self.rate2 = decoder.decodeFloatForKey("rate2")
        self.rate3 = decoder.decodeFloatForKey("rate3")
        self.rate4 = decoder.decodeFloatForKey("rate4")
        self.rate5 = decoder.decodeFloatForKey("rate5")
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.companies, forKey: "companies")
        if let image = self.avatarPic {
            let data = UIImagePNGRepresentation(image)
            coder.encodeObject(data, forKey: "avatarPic")
        }
        coder.encodeObject(self.specialties, forKey: "specialties")
        coder.encodeObject(self.userName, forKey: "name")
        coder.encodeBool(self.isAvailibity, forKey: "isAvailibity")
        coder.encodeBool(self.isAdmin, forKey: "isAdmin")
        coder.encodeBool(self.isRemember, forKey: "isRemember")
        coder.encodeBool(self.isLogged, forKey: "isLogged")
        coder.encodeObject(self.email, forKey: "email")
        coder.encodeObject(self.password, forKey: "password")
        coder.encodeObject(self.authenID, forKey: "authenID")
        coder.encodeObject(self.photoURL, forKey: "photoURL")
        coder.encodeFloat(self.rating, forKey: "rating")
        coder.encodeInteger(self.ratingCount, forKey: "ratingCount")
        coder.encodeBool(self.verify, forKey: "verify")
        coder.encodeObject(self.location, forKey: "location")
        coder.encodeObject(self.phone, forKey: "phone")
        coder.encodeFloat(self.rate1, forKey: "rate1")
        coder.encodeFloat(self.rate2, forKey: "rate2")
        coder.encodeFloat(self.rate3, forKey: "rate3")
        coder.encodeFloat(self.rate4, forKey: "rate4")
        coder.encodeFloat(self.rate5, forKey: "rate5")
        coder.encodeObject(self.createAt, forKey: "createAt")
    }
    
    func syncToFirebase() {
        myRootRef.child("users").child(self.authenID).child("userName").setValue(self.userName)
        myRootRef.child("users").child(self.authenID).child("email").setValue(self.email)
        myRootRef.child("users").child(self.authenID).child("phone").setValue(self.phone)
        myRootRef.child("users").child(self.authenID).child("current_availability").setValue(self.isAvailibity ? "on" : "off")
        myRootRef.child("users").child(self.authenID).child("profile_picture").setValue(self.photoURL)
        self.saveProfile()
    }
    
    func syncFromFirebase(completionBlock: (profile: Profile?) -> Void) {
        myRootRef.child("users").child(self.authenID).observeEventType(.Value, withBlock: {
            snapshot in
            if let data = snapshot.value as? NSDictionary {
                if let phone = data.objectForKey("phone") as? String {
                    self.phone = phone
                }
                if let isAdmin = data.objectForKey("admin") as? Bool {
                    self.isAdmin = isAdmin
                }
                if let userName = data.objectForKey("userName") as? String {
                    self.userName = userName
                }
                if let avai = data.objectForKey("current_availability") as? String {
                    if avai == "on" {
                        self.isAvailibity = true
                    }
                    else {
                        self.isAvailibity = false
                    }
                }
                if let photoURL = data.objectForKey("profile_picture") as? String {
                    self.photoURL = photoURL
                }
                if let companies = data.objectForKey("companies") as? NSDictionary {
                    print(companies)
                    self.companies = ""
                    for (_, dict) in companies {
                        if let dict = dict as? NSDictionary {
                            self.companies = self.companies + " " + (dict.objectForKey("name") as! String)
                        }
                    }
                    print(self.companies)
                }
                if let specialties = data.objectForKey("specialties") as? NSDictionary {
                    for (_, value) in specialties {
                        if let value = value as? Int {
                            if value == 1 {
                                self.specialties += "telecommunication, "
                            }
                            if value == 2 {
                                self.specialties += "Computer/Network cutvoer, "
                            }
                            if value == 3 {
                                self.specialties += "Point of Sale, "
                            }
                            if value == 4 {
                                self.specialties += "Security, "
                            }
                        }
                    }
                }
                completionBlock(profile: self)
            }
            else {
                completionBlock(profile: self)
            }
        })
    }
    
    func jobsFromFirebase(completionBlock: (arrayIDs: [String]?) -> Void) {
        myRootRef.child("users").child(self.authenID).child("jobs").observeEventType(.Value, withBlock: {
            snapshot in
            if let jobsArr = snapshot.value as? NSDictionary {
                var arrayIDs = [String]()
                for (id, _) in jobsArr {
                    arrayIDs.append("\(id)")
                }
                completionBlock(arrayIDs: arrayIDs)
            }
            else {
                completionBlock(arrayIDs: nil)
            }
        })
    }
    
    func registerForJobsAdded() {
        myRootRef.child("users").child(self.authenID).child("jobs").observeEventType(.ChildAdded, withBlock: {
            snapshot in
            if !appDelegate.isRegisterNotiFirstTime {
                Utility.showInAppNotification()
            }
        })
    }
    
    func saveProfile() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(self)
        kUserDefault.setObject(data, forKey: kUserProfile)
        kUserDefault.synchronize()
    }
    
    class func get() -> Profile? {
        if let profileData = kUserDefault.objectForKey(kUserProfile) as? NSData {
            let profile = NSKeyedUnarchiver.unarchiveObjectWithData(profileData) as? Profile
            return profile
        }
        return nil
    }
}