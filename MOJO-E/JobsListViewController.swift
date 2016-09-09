//
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import SideMenu
import CVCalendar
import EventKit
import EventKitUI

class JobsListViewController: UIViewController, MGSwipeTableCellDelegate, JobCellDelegate, UITableViewDelegate, UITableViewDataSource, CVCalendarViewDelegate, CVCalendarMenuViewDelegate, CVCalendarViewAppearanceDelegate, DDCalendarViewDelegate, DDCalendarViewDataSource, CLLocationManagerDelegate {
    
    //MARK: UI Element
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTimeslotView: UIView!
    @IBOutlet weak var addTimeslotButton: UIButton!
    @IBOutlet weak var jobViewStyleButton: UIButton!
    
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var cvMonthCalendarView: CVCalendarView!
    
    @IBOutlet weak var calendarContainerView: UIView!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var mainSegment: UISegmentedControl!
    @IBOutlet var ddCalendarView: DDCalendarView!
    
    var dict = Dictionary<Int, [DDCalendarEvent]>()
    
    //MARK: private property
    var jobs = [Job]()
    var jobSelected: Job?
    var calendarViewType = CalendarMode.MonthView
    var dateSelectedOfMonth = NSDate()
    var personalTimeSlots = [TimeSlot]()
    var locationManager = CLLocationManager()
    
    //MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        ddCalendarView.scrollDateToVisible(NSDate(), animated: animated)
        ddCalendarView.showsTimeMarker = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? JobViewController {
            vc.jobSelected = jobSelected
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.menuView.commitMenuViewUpdate()
        cvMonthCalendarView.commitCalendarViewUpdate()
    }
    
    //MARK: UI Action
    
    @IBAction func weekAction(sender: AnyObject) {
        if weekButton.currentTitle == "week" {
            calendarViewType = CalendarMode.WeekView
            weekButton.setTitle("month", forState: .Normal)
        }
        else {
            calendarViewType = CalendarMode.MonthView
            weekButton.setTitle("week", forState: .Normal)
        }
        cvMonthCalendarView.changeMode(calendarViewType)
    }
    
    @IBAction func todayAction(sender: AnyObject) {
        self.cvMonthCalendarView.toggleCurrentDayView()
    }
    
    
    @IBAction func typeChangedAction(sender: AnyObject) {
        if let segment = sender as? UISegmentedControl {
            self.getJobTypeAction(segment.selectedSegmentIndex)
        }
    }
    
    @IBAction func addTimeslotAction(sender: AnyObject) {
        self.performSegueWithIdentifier("TimeslotSegue", sender: nil)
    }
    
    @IBAction func changeViewAction(sender: AnyObject) {
        if jobViewStyleButton.currentTitle == "Calendar" {
            jobViewStyleButton.setTitle("List", forState: .Normal)
            calendarContainerView.hidden = false
            tableView.hidden = true
        }
        else {
            jobViewStyleButton.setTitle("Calendar", forState: .Normal)
            calendarContainerView.hidden = true
            tableView.hidden = false
        }
    }
    // MARK: Functions
    func getJobTypeAction(actionType: Int) {
        if let profile = Profile.get() where profile.isAdmin == true {
            if actionType == 0 {
                self.getAdminJobs()
            }
            else if actionType == 1 {
                self.syncJobsWithType(.Accepted)
            }
            else if actionType == 2 {
                self.syncJobsWithType(.Finished)
            }
        }
        else {
            if actionType == 0 {
                self.syncJobsWithType(.Assigned)
            }
            else if actionType == 1 {
                self.syncJobsWithType(.Finished)
            }
        }
    }
    func initialize() {
        calendarContainerView.hidden = true
        tableView.hidden = false
        appDelegate.mainVC = self
        Utility.borderRadiusView(addTimeslotView.frame.size.width / 2, view: addTimeslotView)
        Utility.borderRadiusView(addTimeslotButton.frame.size.width / 2, view: addTimeslotButton)
        
        let menuRightNavigationController = Utility.getSideMenuNavigationC()
        SideMenuManager.menuRightNavigationController = menuRightNavigationController
        SideMenuManager.menuAddPanGestureToPresent(toView: self.view)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.view)
        changeViewAction(weekButton)
        todayLabel.text = kDateMMMYYYY.stringFromDate(dateSelectedOfMonth)
        TimeSlot.allPersonalTimeslots { (timeslots) in
            if timeslots.count > 0 {
                self.personalTimeSlots = timeslots
            }
        }
        if let profile = Profile.get() where profile.isAdmin == true {
            self.getAdminJobs()
        }
        else {
            mainSegment.removeSegmentAtIndex(0, animated: false)
            mainSegment.selectedSegmentIndex = 0
            self.syncJobsWithType(.Assigned)
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        var data = Dictionary<String, Double>()
        data["latitude"] = locValue.latitude
        data["longitude"] = locValue.longitude
        data["updated_at"] = round(NSDate().timeIntervalSince1970)
        if let profile = Profile.get() {
            myRootRef.child("users").child(profile.authenID).child("location").setValue(data)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.description)
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print(error.description)
    }
    
    func syncJobsWithType(type: JobStatus)
    {
        self.jobs.removeAll()
        let profile = Profile.get()
        profile?.jobsFromFirebase({ (arrayIDs) in
            if let arrayIDs = arrayIDs where arrayIDs.count > 0 {
                let max = arrayIDs.count
                var run = 0
                for id in arrayIDs {
                    myRootRef.child("jobs").child(id).observeEventType(.Value, withBlock: {
                                snapshot in
                        run = run + 1
                        if let value = snapshot.value as? NSDictionary {
                            let job = Job.createJobFromDict(value)
                            if !self.jobs.contains({$0.jobID == id}) {
                                print("**** syncJobsWithType job.id \(job.id) and status \(job.status)")
                                if job.status == type {
                                    self.jobs.append(Job.createJobFromDict(value))
                                }
                                else if type == .Accepted && (job.status == .EnRoute || job.status == .Started) {
                                    self.jobs.append(Job.createJobFromDict(value))
                                }
                                else if type == .New && job.status == .Assigned {
                                    self.jobs.append(Job.createJobFromDict(value))
                                }
                            }
                        }
                        if run == max {
                            if self.jobs.count > 0 {
                                self.tableView.reloadData()
                                self.renderJobInDate(NSDate())
                            }
                            self.tableView.reloadData()
                            self.addNewCVCalendar()
                        }
                    })
                }
            }
            else {
                self.tableView.reloadData()
                self.addNewCVCalendar()
            }
            appDelegate.isRegisterNotiFirstTime = false
        })
    }
    
    private func addNewCVCalendar() {
        for view in self.calendarContainerView.subviews {
            if view.tag == 105 {
                view.removeFromSuperview()
            }
        }
        let calendar = CVCalendarView(frame: cvMonthCalendarView.frame)
        calendar.tag = 105
        calendar.calendarAppearanceDelegate = self
        calendar.backgroundColor = cvMonthCalendarView.backgroundColor
        calendar.calendarDelegate = self
        self.calendarContainerView.addSubview(calendar)
        calendar.commitCalendarViewUpdate()
        cvMonthCalendarView.hidden = true
    }
    
    private func getAdminJobs() {
        self.jobs.removeAll()
        self.tableView.reloadData()
        if let profile = Profile.get() where profile.isAdmin == true {
            profile.getJobsAsAdmin({ (arrIDs) in
                print(arrIDs)
                if arrIDs.count > 0 {
                    let max = arrIDs.count
                    var run = 0
                    for id in arrIDs {
                        myRootRef.child("jobs").child(id).observeEventType(.Value, withBlock: {
                            snapshot in
                            run = run + 1
                            if let value = snapshot.value as? NSDictionary {
                                let job = Job.createJobFromDict(value)
                                if job.status == .Assigned && !self.jobs.contains({$0.jobID == id}) {
                                    job.isRegional = true
                                    job.jobID = id
                                    print("**** getAdminJobs job.id \(job.id) and status \(job.status)")
                                    self.jobs.append(job)
                                }
                            }
                            if run == max {
                                if self.jobs.count > 0 {
                                    self.renderJobInDate(NSDate())
                                }
                                self.tableView.reloadData()
                                self.addNewCVCalendar()
                            }
                        })
                    }
                }
                else {
                    self.tableView.reloadData()
                    self.addNewCVCalendar()
                }
            })
        }
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.jobs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("JobCell") as! JobCell
        cell.cleanCell()
        cell.job = self.jobs[indexPath.row]
        cell.renderUI()
        cell.delegate = self
        cell.delegateCell = self
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // MARK: UITableViewDelegate.
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85.0;
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0;
    }
    
    // MARK: -Swipe cell delegate
    func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        let path: NSIndexPath = self.tableView.indexPathForCell(cell)!
        if direction == MGSwipeDirection.LeftToRight && index == 0 {
            acceptJob(jobs[path.row])
        }
        return true
    }
    
    // MARK: Friend request protocol
    func acceptJob(job: Job?) {
        if let job = job {
            let slot = TimeSlot(to: job.jobSchedultedEndTime, from: job.jobStartTime, note: "")
            if slot.slotWasOccupied(personalTimeSlots) {
                Utility.showAlertWithMessage(kOccupiedTimesloteWithPersonal)
                return
            }
            if job.isRegional {
                job.isRegional = false
                job.getTheRegionalJob(Profile.get()!.authenID, jobID: job.jobID)
                job.setRegionalJobStatus(.Accepted, companyID: Profile.get()!.companyID)
            }
            job.setJobStatus(.Accepted)
            self.getAdminJobs()
        }
    }
    
    func rejectJob(job: Job?) {
        if let job = job {
            if job.isRegional {
                for (index, jobE) in self.jobs.enumerate() {
                    if job.businessName == jobE.businessName {
                        self.jobs.removeAtIndex(index)
                        break
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func goToDetails(job: Job?) {
//        if let job = job where job.isRegional {
//            Utility.showAlertWithMessage(kJobFromRegional)
//            return
//        }
        jobSelected = job
        self.performSegueWithIdentifier("JobDetailsSegue", sender: nil)
    }
    
    // MARK: CalendarView's Delegate 
    func presentationMode() -> CalendarMode {
        return calendarViewType
    }
    
    func firstWeekday() -> Weekday {
        return Weekday.Sunday
    }
    
    func dayOfWeekTextColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    func presentedDateUpdated(date: Date) {
        dateSelectedOfMonth = date.convertedDate()!
        todayLabel.text = kDateMMMYYYY.stringFromDate(dateSelectedOfMonth)
    }
    
    // MARK: DDCalendar's delegate
    
    func calendarView(view: DDCalendarView, focussedOnDay date: NSDate) {
        renderJobInDate(date)
    }
    
    func renderJobInDate(date: NSDate) {
        if jobs.count > 0 || personalTimeSlots.count > 0 {
            var ddEvents = [DDCalendarEvent]()
            for job in self.jobs {
                let stringTo = kDateddMMYY.stringFromDate(job.jobStartTime)
                let stringFrom = kDateddMMYY.stringFromDate(date)
                if stringTo == stringFrom {
                    let ekEvent = EKEvent(eventStore: EKEventStore())
                    ekEvent.title = job.businessName
                    let dStr = kDateddMMMMYY.stringFromDate(NSDate())
                    let hStr = kDatehhMM.stringFromDate(job.jobStartTime)
                    let dateF = kDateJobTime.dateFromString("\(dStr) \(hStr)")!
                    ekEvent.startDate = dateF
                    ekEvent.endDate = job.jobSchedultedEndTime
//                    ekEvent.endDate = ekEvent.startDate.dateByAddingTimeInterval(3600)
                    let ddEvent = DDCalendarEvent()
                    ddEvent.title = ekEvent.title
                    ddEvent.dateBegin = ekEvent.startDate
                    ddEvent.dateEnd = ekEvent.endDate
                    ddEvent.userInfo = ["event" : ekEvent]
                    ddEvents.append(ddEvent)
                }
            }
            if personalTimeSlots.count > 0 {
                for slot in personalTimeSlots {
                    let stringTo = kDateddMMYY.stringFromDate(slot.fromTime!)
                    let stringFrom = kDateddMMYY.stringFromDate(date)
                    if stringTo == stringFrom {
                        let ekEvent = EKEvent(eventStore: EKEventStore())
                        ekEvent.title = slot.note
                        let dStr = kDateddMMMMYY.stringFromDate(NSDate())
                        let hStr = kDatehhMM.stringFromDate(slot.fromTime!)
                        let dateF = kDateJobTime.dateFromString("\(dStr) \(hStr)")!
                        ekEvent.startDate = dateF
                        ekEvent.endDate = ekEvent.startDate.dateByAddingTimeInterval(3600)
                        let ddEvent = DDCalendarEvent()
                        ddEvent.title = "- Personal Time - " + ekEvent.title
                        ddEvent.dateBegin = ekEvent.startDate
                        ddEvent.dateEnd = ekEvent.endDate
                        ddEvent.userInfo = ["event" : ekEvent]
                        ddEvents.append(ddEvent)
                    }
                }
            }
            dict[0] = ddEvents
            self.ddCalendarView.reloadData()
        }
    }
    
    func calendarView(view: DDCalendarView, didSelectEvent event: DDCalendarEvent) {
//        let ekEvent = event.userInfo["event"] as! EKEvent
//        
//        let vc = EKEventViewController()
//        vc.event = ekEvent
//        self.presentViewController(vc, animated: true, completion: nil)
        for job in self.jobs {
            if job.businessName == event.title {
                jobSelected = job
                goToDetails(jobSelected)
                return
            }
        }
    }
    
    func calendarView(view: DDCalendarView, allowEditingEvent event: DDCalendarEvent) -> Bool {
        //NOTE some check could be here, we just say true :D
        let ekEvent = event.userInfo["event"] as! EKEvent
        let ekCal = ekEvent.calendarItemIdentifier
        print(ekCal)
        
        return true
    }
    
    func calendarView(view: DDCalendarView, commitEditEvent event: DDCalendarEvent) {
        //NOTE we dont actually save anything because this demo doesnt wanna mess with your calendar :)
    }
    
    // MARK: DDCalendar'sdataSource
    
    func calendarView(view: DDCalendarView, eventsForDay date: NSDate) -> [AnyObject]? {
//        print("====== eventsForDay \(date.daysFromDate(NSDate()))")
        return dict[date.daysFromDate(NSDate())]
    }
    
    func calendarView(view: DDCalendarView, viewForEvent event: DDCalendarEvent) -> DDCalendarEventView? {
        let eventV = EventView(event: event)
        if event.title.containsString("- Personal Time -") {
            eventV.backgroundColor = UIColor.orangeColor()
        }
        return eventV
    }
    
    // MARK: CVCalendarViewDelegate's methods
    func didSelectDayView(dayView: DayView, animationDidFinish: Bool) {
        if let date = dayView.date.convertedDate() {
            renderJobInDate(date)
        }
    }
    
    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if let cDate = dayView.date, let date = cDate.convertedDate() {
            return Job.hasJobsInDate(self.jobs, date: date)
        }
        return false
    }
    
    func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if let cDate = dayView.date, let date = cDate.convertedDate() {
            return TimeSlot.hasPersonTimeInDate(personalTimeSlots, date: date)
        }
        return false
    }
    
    func preliminaryView(viewOnDayView dayView: DayView) -> UIView {
        let dot = UIView(frame: CGRectMake(5, 10, 8, 8))
        if self.view.frame.size.width > 500 {
            dot.frame = CGRectMake(25, 10, 8, 8)
        }
        dot.backgroundColor = UIColor.whiteColor()
        dot.layer.cornerRadius = 4
        return dot
    }
    
    func supplementaryView(viewOnDayView dayView: DayView) -> UIView {
        var yCoor: CGFloat = 20.0
        if let cDate = dayView.date, let date = cDate.convertedDate() where Job.hasJobsInDate(self.jobs, date: date) == false {
            yCoor = 10.0
        }
        let dot = UIView(frame: CGRectMake(5, yCoor, 8, 8))
        if self.view.frame.size.width > 500 {
            dot.frame = CGRectMake(25, yCoor, 8, 8)
        }
        dot.backgroundColor = UIColor.orangeColor()
        dot.layer.cornerRadius = 4
        return dot
    }
}


