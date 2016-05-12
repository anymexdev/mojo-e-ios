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
    var id: Int32?
    var businessName = ""
    var businessID: Int32?
    var address1 = ""
    var city = ""
    var companyID: Int32?
    var type = "Incoming"
    var latitude: Double?
    var longtitude: Double?
    var ticketNumber: Int32?
    
    
    // MARK: NSCoding
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.businessName, forKey: "businessName")
        coder.encodeObject(self.address1, forKey: "address1")
        coder.encodeObject(self.city, forKey: "city")
        coder.encodeObject(self.type, forKey: "type")
        if let latitude = self.latitude {
            coder.encodeDouble(latitude, forKey: "latitude")
        }
        if let longtitude = self.longtitude {
            coder.encodeDouble(longtitude, forKey: "longtitude")
        }
        if let ticketNumber = self.ticketNumber {
            coder.encodeInt(ticketNumber, forKey: "ticketNumber")
        }
        if let id = self.id {
            coder.encodeInt(id, forKey: "id")
        }
        if let businessID = self.businessID {
            coder.encodeInt(businessID, forKey: "businessID")
        }
        if let companyID = self.companyID {
            coder.encodeInt(companyID, forKey: "companyID")
        }
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let businessName = decoder.decodeObjectForKey("businessName") as? String,
            let address1 = decoder.decodeObjectForKey("address1") as? String,
            let city = decoder.decodeObjectForKey("city") as? String,
            let type = decoder.decodeObjectForKey("type") as? String
            else {
                return nil
        }
        self.init()
        self.businessID = decoder.decodeIntForKey("businessID")
        self.businessName = businessName
        self.address1 = address1
        self.city = city
        self.type = type
        self.companyID = decoder.decodeIntForKey("companyID")
        self.latitude = decoder.decodeDoubleForKey("latitude")
        self.longtitude = decoder.decodeDoubleForKey("longtitude")
        self.ticketNumber = decoder.decodeIntForKey("ticketNumber")
        self.id = decoder.decodeIntForKey("id")
    }
    
    class func createJobFromDict(dict: NSDictionary) -> Job {
        let job = Job()
        job.businessID = dict.objectForKey("business_id") as? Int32
        job.type = (dict.objectForKey("type") as? String)!
        job.businessName = (dict.objectForKey("business_name") as? String)!
        job.address1 = (dict.objectForKey("address1") as? String)!
        job.city = (dict.objectForKey("city") as? String)!
        job.companyID = dict.objectForKey("companyID") as? Int32
        job.id = dict.objectForKey("id") as? Int32
        job.latitude = dict.objectForKey("latitude") as? Double
        job.longtitude = dict.objectForKey("longtitude") as? Double
        return job
    }
}

