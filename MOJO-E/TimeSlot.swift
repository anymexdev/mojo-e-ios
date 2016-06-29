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
    var note: String = ""
    
    //MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        //
        aCoder.encodeObject(self.toTime,forKey: "toTime")
        aCoder.encodeObject(self.note,forKey: "note")
        aCoder.encodeObject(self.fromTime, forKey: "fromTime")
        aCoder.encodeInteger(self.selected, forKey: "selected")
        
    }
    required convenience init?(coder decoder: NSCoder) {
        guard
            let toTime = decoder.decodeObjectForKey("toTime") as? NSDate ,
            let note = decoder.decodeObjectForKey("note") as? String ,
            let fromTime = decoder.decodeObjectForKey("fromTime") as? NSDate
            else { return nil }
        
        self.init(
            to: toTime,
            from: fromTime,
            note: note,
            select: decoder.decodeIntegerForKey("selected")
        )
    }
    
    //MARK: Contructor
    init(to: NSDate , from: NSDate, note: String, select: Int = 0) {
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
                return TimeSlot(to: toTime,from: fromTime, note: "", select: select)
            }
        }
        return TimeSlot(to: toTime,from: fromTime, note: "")
    }
    
    func slotWasOccupied(occupiedList: [TimeSlot]) -> Bool {
        for oSlot in occupiedList {
//            print("-------------")
//            print(oSlot.fromTime!)
//            print(oSlot.toTime!)
//            print(self.fromTime!)
//            print(self.toTime!)
            if self.fromTime!.compare(oSlot.toTime!) == .OrderedAscending && self.toTime!.compare(oSlot.fromTime!) == .OrderedDescending {
                return true
            }
            else if oSlot.fromTime!.compare(self.toTime!) == .OrderedAscending && oSlot.toTime!.compare(self.fromTime!) == .OrderedDescending {
                return true
            }
        }
        return false
    }
    
    class func allPersonalTimeslots(completionBlock: (timeslots: [TimeSlot]) -> Void) {
        if let profile = Profile.get() {
            myRootRef.child("users").child(profile.authenID).child("personal_time").observeEventType(.Value, withBlock: {
                snapshot in
                var arraySlot = [TimeSlot]()
                if let slotArr = snapshot.value as? NSArray {
                    for slot in slotArr {
                        if let dict = slot as? NSDictionary {
                            arraySlot.append(TimeSlot.createTimeSlotFromDict(dict))
                        }
                    }
                }
                completionBlock(timeslots: arraySlot)
            })
        }
    }
    
    class func createTimeSlotFromDict(dict: NSDictionary) -> TimeSlot {
        let slot = TimeSlot(to: NSDate(), from: NSDate(), note: "")
        if let note = dict.objectForKey("note") as? String {
            slot.note = note
        }
        if let startTime = dict.objectForKey("startTime") as? NSTimeInterval {
            slot.fromTime = NSDate(timeIntervalSince1970: startTime)
        }
        if let endTime = dict.objectForKey("endTime") as? NSTimeInterval {
            slot.toTime = NSDate(timeIntervalSince1970: endTime)
        }
        return slot
    }
}
