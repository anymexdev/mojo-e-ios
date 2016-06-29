///
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import UIKit
import Firebase

class TimeSlotViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,
    UITableViewDataSource, UITableViewDelegate , TimeCellProtocol, UITextViewDelegate
{
    //MARK: UI Element
    @IBOutlet weak var listDayCollection: UICollectionView!
    @IBOutlet weak var listTimeTableView: UITableView!
    @IBOutlet weak var currentDateSelectedLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var toButton: UIButton!
    @IBOutlet weak var fromButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var bottomTextConstraint: NSLayoutConstraint!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var closeKeyboardButton: UIButton!
    
    //MARK: properties
    var dateList: [DateInfo]?
    var currentSelect: NSIndexPath?
    var currentTimeSlot = [TimeSlot]()
    var globalTimeSlot = [TimeSlot]()
    var occupiedTimeSlot = [TimeSlot]()
    var globalNoteSlot = [String]()
    var timeSelectedLabel: UILabel?
    var timeSelectedButton: UIButton?
    var timeslotSelected = TimeSlot(to: NSDate(), from: NSDate())
    let defaultSentence = "Note for your personal time"
    
    //MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    // MARK: CollectionView
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (dateList?.count)!
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ListDayCell", forIndexPath: indexPath) as! ListDayCell
        cell.cleanCell()
        cell.date = dateList![indexPath.row]
        cell.renderUI()
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let _ = currentSelect {
            dateList![(currentSelect?.row)!].mselect = false
        }
        // isSlect ?
        dateList![indexPath.row].mselect = true
        //Update change in lastSelect
        dateList![currentSelect!.row].mTimeSlot = currentTimeSlot
        // update currentSlect index
        currentSelect = indexPath
        // update currentTimeSlot
        currentTimeSlot = dateList![indexPath.row].mTimeSlot
        //ReloadData
        collectionView.reloadData()
        listTimeTableView.reloadData()
        currentDateSelectedLabel.text = dateList![indexPath.row].mDate!.toShortDayString()
    }

    // MARK: UITableView datasource vs delegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ListTimeCell") as! ListTimeCell
        cell.dateToDate = currentTimeSlot[indexPath.row]
        cell.renderUI()
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTimeSlot.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let index = indexPath.row
            currentTimeSlot.removeAtIndex(index)
            listTimeTableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    //MARK: TimeCellProtocol
    func deleteTimeItem(time: TimeSlot) {
    }

    // MARK: Action
    @IBAction func addTimeAction(sender: AnyObject) {
        if toLabel.text != "To" && fromLabel.text != "From" {
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = NSTimeZone(name: "GMT")
            dateFormatter.dateFormat = "h:mm a"
            let toTime = dateFormatter.dateFromString(toLabel.text!)
            let fromTime = dateFormatter.dateFromString(fromLabel.text!)
            if let toTime = toTime, let fromTime = fromTime {
                for time in currentTimeSlot {
                    if time.toTime?.minutesFrom(toTime) == 0 && time.fromTime?.minutesFrom(fromTime) == 0 {
                        Utility.showToastWithMessage(kErrorTimeSlotDateExist)
                        return
                    }
                }
                if currentTimeSlot.count > 0 {
                    let compareResult : NSComparisonResult = toTime.compare(currentTimeSlot[currentTimeSlot.count-1].fromTime!)
                    if compareResult == NSComparisonResult.OrderedAscending || compareResult == NSComparisonResult.OrderedSame {
                        Utility.showToastWithMessage(kErrorTimeSlotPreToTimeLaterThanFromTime)
                        return
                    }
                }
                if toTime.minutesFrom(fromTime) > 14 {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.timeZone = NSTimeZone.systemTimeZone()
                    dateFormatter.dateFormat = "h:mm a"
                    if let currentSelect = currentSelect {
                        dateFormatter.defaultDate = dateList![currentSelect.row].mDate
                        print(dateFormatter.defaultDate)
                    }
                    let toTimeAdd = dateFormatter.dateFromString(toLabel.text!)
                    let fromTimeAdd = dateFormatter.dateFromString(fromLabel.text!)
                    let slot = TimeSlot(to: toTimeAdd!, from: fromTimeAdd!)
                    if !slot.slotWasOccupied(occupiedTimeSlot) {
                        currentTimeSlot.append(slot)
                        globalTimeSlot.append(slot)
                        globalNoteSlot.append((noteTextView.text == defaultSentence) ? "" : noteTextView.text)
                        noteTextView.text = defaultSentence
                        listTimeTableView.reloadData()
                    }
                    else {
                        Utility.showToastWithMessage(kOccupiedTimesloteWithJob)
                    }
                } else {
                    Utility.showToastWithMessage(kErrorTimeSlotShortDistance)
                }
            }
        }
    }
    
    @IBAction func tofromAction(sender: AnyObject) {
        var temp : NSDate
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        setUnSelectedBackgoundLabel()
        timeSelectedButton = sender as? UIButton
        if timeSelectedButton == toButton {
            timeSelectedLabel = toLabel
        } else {
            timeSelectedLabel = fromLabel
        }
        if timeSelectedLabel?.text == "From" {
            timeSelectedLabel?.text = dateFormatter.stringFromDate(dateTimePicker.date)
        } else if timeSelectedLabel?.text == "To" {
            temp = dateTimePicker.date.dateByAddingTimeInterval(900)
            timeSelectedLabel?.text = dateFormatter.stringFromDate(temp)
            dateTimePicker.setDate(temp, animated: true)
        }
        if timeSelectedButton == toButton {
            if let date = dateFormatter.dateFromString(toLabel.text!) {
                dateTimePicker.setDate(date, animated: true)
            }
        } else {
            if let date = dateFormatter.dateFromString(fromLabel.text!) {
                dateTimePicker.setDate(date, animated: true)
            }
        }
        timeSelectedLabel!.backgroundColor = Utility.greenL0Color()
    }
    
    @IBAction func timeChangedAction(sender: AnyObject) {
        var temp : NSDate
        let strDateChanged = dateTimePicker.date.toShortTimeString()
        timeSelectedLabel?.text = strDateChanged
        if timeSelectedLabel == fromLabel {
            temp = dateTimePicker.date.dateByAddingTimeInterval(900)
            toLabel.text = temp.toShortTimeString()
        }
    }
    
    @IBAction func temp(sender: AnyObject) {
        print("did action")
    }
    
    @IBAction func addButtonAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        if let profile = Profile.get() where globalTimeSlot.count > 0 {
            var index = 1
            for timeslot in globalTimeSlot {
                if let from = timeslot.fromTime, let to = timeslot.toTime {
                    var data = Dictionary<String, AnyObject>()
                    data["startTime"] = round(from.timeIntervalSince1970)
                    data["endTime"] = round(to.timeIntervalSince1970)
                    data["note"] = globalNoteSlot[index - 1]
                    myRootRef.child("users").child(profile.authenID).child("personal_time").child("\(index)").setValue(data)
                    index = index + 1
                }
            }
        }
    }
    
    @IBAction func closeKeyboardAction(sender: AnyObject) {
        view.endEditing(true)
    }
    
    
    // MARK: functions
    func initialize() {
        appDelegate.mainVC = self
        setUnSelectedBackgoundLabel()
        dateTimePicker.setValue(UIColor.whiteColor(), forKey: "textColor")
        if let _ = dateList {
            // do something
        } else {
            dateList = DateInfo.create30Day()
        }
        //set current select
        tofromAction(fromButton)
        currentTimeSlot = (dateList?.first?.mTimeSlot)!
        currentSelect = NSIndexPath(forRow: 0, inSection: 0)
        collectionView(listDayCollection, didSelectItemAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TimeSlotViewController.keyboardWillChangeFrameNotification(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
//        Profile.get()!.registerForJobsAdded()
        // get occupied Timeslots
        let profile = Profile.get()
        profile?.jobsFromFirebase({ (arrayIDs) in
            if let arrayIDs = arrayIDs where arrayIDs.count > 0 {
                for id in arrayIDs {
                    myRootRef.child("jobs").child(id).observeEventType(.Value, withBlock: {
                        snapshot in
                        if let value = snapshot.value as? NSDictionary {
                            let job = Job.createJobFromDict(value)
                            if job.status == .Accepted || job.status == .EnRoute || job.status == .Started || job.status == .Assigned {
                                let timeS = TimeSlot(to: job.jobStartTime, from: job.jobSchedultedEndTime)
                                self.occupiedTimeSlot.append(timeS)
                            }
                        }
                    })
                    
                }
            }
        })
    }
    
    func setUnSelectedBackgoundLabel() {
        toLabel.backgroundColor = addButton.backgroundColor!
        fromLabel.backgroundColor = addButton.backgroundColor!
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
                                        self.bottomTextConstraint.constant = newBottomOffset
                                        self.closeKeyboardButton.hidden = false
                                    }
                                    else {
                                        // keyboard will hide
                                        self.bottomTextConstraint.constant = 0
                                        self.closeKeyboardButton.hidden = true
                                        
                                    }
                                    self.view.layoutIfNeeded()
            },
                                   completion: nil
        )
    }
    
    // MARK: TextView delegate's methods
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == defaultSentence {
            textView.text = ""
        }
    }
}


