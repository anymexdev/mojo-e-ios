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
    var isAvailibity = true
    var companies = ""
    var specialties = ""
    
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
        self.password = password
        self.authenID = authenID
        self.isRemember = decoder.decodeBoolForKey("isRemember")
        self.isAvailibity = decoder.decodeBoolForKey("isAvailibity")
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
        coder.encodeObject(self.specialties, forKey: "specialties")
        coder.encodeObject(self.userName, forKey: "name")
        coder.encodeBool(self.isAvailibity, forKey: "isAvailibity")
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
        var data = Dictionary<String, String>()
        data["userName"] = self.userName
        data["email"] = self.email
        myRootRef.child("users").child(self.authenID).setValue(data)
        self.saveProfile()
    }
    
    func syncFromFirebase(completionBlock: (profile: Profile?) -> Void) {
        myRootRef.child("users").child("fa03b804-9784-4f02-ad54-80a240213613").observeEventType(.Value, withBlock: {
            snapshot in
            if let data = snapshot.value as? NSDictionary {
                print(data)
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
                if let companies = data.objectForKey("companies") as? NSArray {
                    print(companies)
                }
                if let specialties = data.objectForKey("specialties") as? NSArray {
                    for value in specialties {
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
    
    func saveProfile() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(self)
        kUserDefault.setObject(data, forKey: kUserProfile)
        kUserDefault.synchronize()
    }
    
    class func get() -> Profile? {
        if let profileData = kUserDefault.objectForKey(kUserProfile) as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(profileData) as? Profile
        }
        return nil
    }
}