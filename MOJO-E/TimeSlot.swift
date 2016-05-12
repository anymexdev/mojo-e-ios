//
//  TimeSlot.swift
//  MOJO-E
//
//  Created by Sonivy Development on 5/12/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import Foundation
class TimeSlot : NSObject, NSCoding {
    
    //MARK: Properties
    var toTime: NSDate?
    var fromTime: NSDate?
    var selected: Int = 0
    
    //MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        //
        aCoder.encodeObject(self.toTime,forKey: "toTime")
        aCoder.encodeObject(self.fromTime, forKey: "fromTime")
        aCoder.encodeInteger(self.selected, forKey: "selected")
        
    }
    required convenience init?(coder decoder: NSCoder) {
        guard
            let toTime = decoder.decodeObjectForKey("toTime") as? NSDate ,
            let fromTime = decoder.decodeObjectForKey("fromTime") as? NSDate
            else { return nil }
        
        self.init(
            to: toTime,
            from: fromTime,
            select: decoder.decodeIntegerForKey("selected")
        )
    }
    
    //MARK: Contructor
    init(to: NSDate , from: NSDate, select: Int = 0) {
        self.toTime = to
        self.fromTime = from
        self.selected = select
    }
    
    //MARK: Method
    func getStringTimeSlot() -> [String: AnyObject] {
        let to: String = (toTime?.description)!
        let from: String = (fromTime?.description)!
        return ["to": to, "from":from, "selected": selected]
    }
    
    
    //MARK: Class function
    class func getKey(id:String, date:String, to:String, from:String) -> String {
        return "\(id)-\(date)-\(to)-\(from)"
    }
    
    class func fromDictionary(dic: NSDictionary) -> TimeSlot {
        var toTime = NSDate()
        var fromTime = NSDate()
        var select = 0
        let format = NSDateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        if  let to = dic["to"] as? String,
            let from = dic["from"] as? String
        {
            if let selected = dic["selected"] as? Int {
                select = selected
            }
            if let tTime = format.dateFromString(to),
                let fTime = format.dateFromString(from)
            {
                toTime = tTime
                fromTime = fTime
                return TimeSlot(to: toTime,from: fromTime,select: select)
            }
        }
        return TimeSlot(to: toTime,from: fromTime)
    }
}
