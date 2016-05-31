//
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import Foundation

class Job: NSObject, NSCoding {
    
    // MARK: Class's constructors
    override init() {
        super.init()
    }
    
    // MARK: Class's properties
    var id: Int?
    var businessName = ""
    var zip = ""
    var state = ""
    var businessID: Int?
    var address1 = ""
    var city = ""
    var companyID: Int?
    var type = "new"
    var latitude: Double?
    var longtitude: Double?
    var ticketNumber: Int?
    
    
    // MARK: NSCoding
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.businessName, forKey: "businessName")
        coder.encodeObject(self.address1, forKey: "address1")
        coder.encodeObject(self.city, forKey: "city")
        coder.encodeObject(self.type, forKey: "type")
        coder.encodeObject(self.zip, forKey: "zip")
        coder.encodeObject(self.state, forKey: "state")
        if let latitude = self.latitude {
            coder.encodeDouble(latitude, forKey: "latitude")
        }
        if let longtitude = self.longtitude {
            coder.encodeDouble(longtitude, forKey: "longtitude")
        }
        if let ticketNumber = self.ticketNumber {
            coder.encodeInteger(ticketNumber, forKey: "ticketNumber")
        }
        if let id = self.id {
            coder.encodeInteger(id, forKey: "id")
        }
        if let businessID = self.businessID {
            coder.encodeInteger(businessID, forKey: "businessID")
        }
        if let companyID = self.companyID {
            coder.encodeInteger(companyID, forKey: "companyID")
        }
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let businessName = decoder.decodeObjectForKey("businessName") as? String,
            let address1 = decoder.decodeObjectForKey("address1") as? String,
            let city = decoder.decodeObjectForKey("city") as? String,
            let zip = decoder.decodeObjectForKey("zip") as? String,
            let state = decoder.decodeObjectForKey("state") as? String,
            let type = decoder.decodeObjectForKey("type") as? String
            else {
                return nil
        }
        self.init()
        self.businessID = decoder.decodeIntegerForKey("businessID")
        self.businessName = businessName
        self.zip = zip
        self.state = state
        self.address1 = address1
        self.city = city
        self.type = type
        self.companyID = decoder.decodeIntegerForKey("companyID")
        self.latitude = decoder.decodeDoubleForKey("latitude")
        self.longtitude = decoder.decodeDoubleForKey("longtitude")
        self.ticketNumber = decoder.decodeIntegerForKey("ticketNumber")
        self.id = decoder.decodeIntegerForKey("id")
    }
    
    class func createJobFromDict(dict: NSDictionary) -> Job {
        let job = Job()
        if let zip = dict.objectForKey("zip") as? String {
            job.zip = zip
        }
        if let state = dict.objectForKey("state") as? String {
            job.state = state
        }
        if let type = dict.objectForKey("type") as? String {
            job.type = type
        }
        if let businessName = dict.objectForKey("business_name") as? String {
            job.businessName = businessName
        }
        if let address1 = dict.objectForKey("address1") as? String {
            job.address1 = address1
        }
        if let city = dict.objectForKey("city") as? String {
            job.city = city
        }
        if let id = dict.objectForKey("id") as? Int {
            job.id = id
        }
        if let businessID = dict.objectForKey("business_id") as? Int {
            job.businessID = businessID
        }
        if let companyID = dict.objectForKey("company_id") as? Int {
            job.companyID = companyID
        }
        if let ticketNumber = dict.objectForKey("ticket_number") as? Int {
            job.ticketNumber = ticketNumber
        }
        job.latitude = dict.objectForKey("latitude") as? Double
        job.longtitude = dict.objectForKey("longitude") as? Double
        return job
    }
    
    func accepted() {
        if let id = self.id {
            let jobRef = myRootRef.child("jobs").child("\(id)")
            jobRef.child("type").setValue("Accepted")
        }
    }
}

