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
    var jobName = ""
    var jobDate = ""
    
    
    // MARK: NSCoding
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.jobName, forKey: "jobName")
        coder.encodeObject(self.jobDate, forKey: "jobDate")
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let jobName = decoder.decodeObjectForKey("jobName") as? String,
            let jobDate = decoder.decodeObjectForKey("jobDate") as? String else {
                return nil
        }
        self.init()
        self.jobName = jobName
        self.jobDate = jobDate
    }
}

