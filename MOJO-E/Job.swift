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
    var status = JobStatus.New
    var latitude: Double?
    var longtitude: Double?
    var ticketNumber: Int?
    var dispatchTime = NSDate()
    var jobStartTime = NSDate()
    var jobSchedultedEndTime = NSDate()
    var jobEndTime = NSDate()
    var pictureCount: Int = 0
    
    
    // MARK: NSCoding
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.businessName, forKey: "businessName")
        coder.encodeObject(self.dispatchTime, forKey: "dispatchTime")
        coder.encodeObject(self.jobStartTime, forKey: "jobStartTime")
        coder.encodeObject(self.jobSchedultedEndTime, forKey: "jobSchedultedEndTime")
        coder.encodeObject(self.jobEndTime, forKey: "jobEndTime")
        coder.encodeObject(self.address1, forKey: "address1")
        coder.encodeObject(self.city, forKey: "city")
        coder.encodeObject(self.status.rawValue, forKey: "status")
        coder.encodeObject(self.zip, forKey: "zip")
        coder.encodeObject(self.state, forKey: "state")
        coder.encodeInteger(self.pictureCount, forKey: "pictureCount")
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
            let dispatchTime = decoder.decodeObjectForKey("dispatchTime") as? NSDate,
            let jobStartTime = decoder.decodeObjectForKey("jobStartTime") as? NSDate,
            let jobSchedultedEndTime = decoder.decodeObjectForKey("jobSchedultedEndTime") as? NSDate,
            let jobEndTime = decoder.decodeObjectForKey("jobEndTime") as? NSDate,
            let zip = decoder.decodeObjectForKey("zip") as? String,
            let status = decoder.decodeObjectForKey("status") as? String,
            let state = decoder.decodeObjectForKey("state") as? String
            else {
                return nil
        }
        self.init()
        self.businessID = decoder.decodeIntegerForKey("businessID")
        self.businessName = businessName
        self.zip = zip
        self.state = state
        self.address1 = address1
        self.dispatchTime = dispatchTime
        self.jobStartTime = jobStartTime
        self.jobSchedultedEndTime = jobSchedultedEndTime
        self.jobEndTime = jobEndTime
        self.city = city
        if let status = JobStatus(rawValue: status) {
            self.status = status
        }
        else {
            self.status = JobStatus.New
        }
        self.companyID = decoder.decodeIntegerForKey("companyID")
        self.latitude = decoder.decodeDoubleForKey("latitude")
        self.longtitude = decoder.decodeDoubleForKey("longtitude")
        self.ticketNumber = decoder.decodeIntegerForKey("ticketNumber")
        self.pictureCount = decoder.decodeIntegerForKey("pictureCount")
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
        if let status = dict.objectForKey("status") as? String {
            if let status = JobStatus(rawValue: status) {
                job.status = status
            }
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
        if let pictures = dict.objectForKey("pictures") as? NSArray {
            job.pictureCount = pictures.count
        }
        if let dispatchTime = dict.objectForKey("dispatch_time") as? NSTimeInterval {
            job.dispatchTime = NSDate(timeIntervalSince1970: dispatchTime)
        }
        if let jobEndTime = dict.objectForKey("submit_time") as? NSTimeInterval {
            job.jobEndTime = NSDate(timeIntervalSince1970: jobEndTime)
        }
        if let createTime = dict.objectForKey("job_scheduled_start_time") as? NSTimeInterval {
            job.jobStartTime = NSDate(timeIntervalSince1970: createTime)
        }
        if let scheduleEndTime = dict.objectForKey("job_scheduled_end_time") as? NSTimeInterval {
            job.jobSchedultedEndTime = NSDate(timeIntervalSince1970: scheduleEndTime)
        }
        job.latitude = dict.objectForKey("latitude") as? Double
        job.longtitude = dict.objectForKey("longitude") as? Double
        return job
    }
    
    func setJobStatus(status: JobStatus) {
        if let id = self.id {
            let jobRef = myRootRef.child("jobs").child("\(id)")
            jobRef.child("status").setValue(status.rawValue)
            if let profile = Profile.get() {
                self.status = status
                jobRef.child("user_id").setValue(profile.authenID)
            }
        }
    }
    
    func setJobSubmitTime() {
        if let id = self.id {
            let jobRef = myRootRef.child("jobs").child("\(id)")
            jobRef.child("submit_time").setValue(round(NSDate().timeIntervalSince1970))
        }
    }
    
    func setJobStartTime() {
        if let id = self.id {
            let jobRef = myRootRef.child("jobs").child("\(id)")
            jobRef.child("job_scheduled_start_time").setValue(round(NSDate().timeIntervalSince1970))
        }
    }
    
    func setJobPictures(arrayImageURL: [String]) {
        if let id = self.id {
            let jobRef = myRootRef.child("jobs").child("\(id)")
            jobRef.child("pictures").setValue(arrayImageURL)
        }
    }
    
    func setJobSignature(url: String) {
        if let id = self.id {
            let jobRef = myRootRef.child("jobs").child("\(id)")
            jobRef.child("signature").setValue(url)
        }
    }
    
    func rejectJob(userID: String) {
        if let id = self.id {
            myRootRef.child("jobs").child("\(id)").child("user_id").setValue("")
            myRootRef.child("users").child(userID).child("jobs").child("\(id)").removeValue()
        }
    }
    
    class func hasJobsInDate(jobList: [Job], date: NSDate) -> Bool {
        for job in jobList {
            if kDateddMMMMYY.stringFromDate(date) == kDateddMMMMYY.stringFromDate(job.jobStartTime) {
                return true
            }
        }
        return false
    }
}

