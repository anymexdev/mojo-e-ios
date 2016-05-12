///
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import Foundation

class DateInfo : NSObject, NSCoding {
    
    var mDate: NSDate?
    var mTimeSlot: [TimeSlot] = [TimeSlot]()
    var mselect = false
    
    //MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        //
        aCoder.encodeObject(self.mDate,forKey: "mDate")
        aCoder.encodeObject(self.mTimeSlot,forKey: "mTimeSlot")
        aCoder.encodeBool(self.mselect, forKey: "mselect")
        
    }
    required convenience init?(coder decoder: NSCoder) {
        guard let date = decoder.decodeObjectForKey("mDate") as? NSDate,
            let timeSlot = decoder.decodeObjectForKey("mTimeSlot") as? [TimeSlot]
            else { return nil }
        
        self.init(
            date: date,
            timeSlot: timeSlot,
            select: decoder.decodeBoolForKey("mselect")
        )
    }
    
    init(date: NSDate?, timeSlot: [TimeSlot], select: Bool) {
        self.mDate = date
        self.mTimeSlot = timeSlot
        self.mselect = select
    }
    
    //MARK: contructor
    required init(day: NSDate) {
        mDate = day
    }
    
    // MARK: Method
    func getString() -> NSDictionary {
        var tempTimeSlot = [NSDictionary]()
        for ts in mTimeSlot {
            tempTimeSlot.append(ts.getStringTimeSlot())
        }
        let date: String = mDate!.description
        let newDay = [
            "day" : date,
            "timeslot": tempTimeSlot
        ]
        return newDay
    }
    
    //MARK: Class func
    class func create30Day() -> [DateInfo] {
        var arr = [DateInfo]()
        var toDay = NSDate()
        for _ in 0...90 {
            arr.append( DateInfo(day: toDay) )
            toDay = toDay.nextDay()
        }
        return arr
    }
    
    class func fromDictionary(dic: NSDictionary) -> DateInfo {
        let dateInfo:DateInfo = DateInfo(day: NSDate())
        if let day = dic["day"] as? String {
            let format = NSDateFormatter()
            format.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
            dateInfo.mDate = format.dateFromString(day)
        }
        if let timeslot = dic["timeslot"] as? NSArray {
            for ele in timeslot {
                if let value = ele as? NSDictionary {
                    let timeslot = TimeSlot.fromDictionary(value)
                    dateInfo.mTimeSlot.append(timeslot)
                }
            }
        }
        return dateInfo
    }
}