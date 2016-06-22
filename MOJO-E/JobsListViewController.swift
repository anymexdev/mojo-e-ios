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

class JobsListViewController: UIViewController, MGSwipeTableCellDelegate, JobCellDelegate, UITableViewDelegate, UITableViewDataSource, CVCalendarViewDelegate, CVCalendarMenuViewDelegate, CVCalendarViewAppearanceDelegate, DDCalendarViewDelegate, DDCalendarViewDataSource {
    
    //MARK: UI Element
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTimeslotView: UIView!
    @IBOutlet weak var addTimeslotButton: UIButton!
    @IBOutlet weak var jobViewStyleButton: UIButton!
    
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    
    @IBOutlet weak var calendarContainerView: UIView!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var todayButton: UIButton!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet var ddCalendarView: DDCalendarView!
    var dict = Dictionary<Int, [DDCalendarEvent]>()
    
    //MARK: private property
    var jobs = [Job]()
    var jobSelected: Job?
    var calendarViewType = CalendarMode.MonthView
    
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
        self.calendarView.commitCalendarViewUpdate()
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
        calendarView.changeMode(calendarViewType)
    }
    
    @IBAction func todayAction(sender: AnyObject) {
        self.calendarView.toggleCurrentDayView()
    }
    
    
    @IBAction func typeChangedAction(sender: AnyObject) {
        if let segment = sender as? UISegmentedControl {
            if segment.selectedSegmentIndex == 0 {
                self.syncJobsWithType(.New)
            }
            else if segment.selectedSegmentIndex == 1 {
                self.syncJobsWithType(.Accepted)
            }
            else if segment.selectedSegmentIndex == 2 {
                self.syncJobsWithType(.Finished)
            }
        }
    }
    
    @IBAction func addTimeslotAction(sender: AnyObject) {
        self.performSegueWithIdentifier("TimeslotSegue", sender: nil)
    }
    
    @IBAction func changeViewAction(sender: AnyObject) {
        if jobViewStyleButton.currentTitle == "Calendar" {
//            topConstraint.constant = calendarView.frame.size.height + calendarView.frame.origin.y + 50
            jobViewStyleButton.setTitle("List", forState: .Normal)
            calendarContainerView.hidden = false
            tableView.hidden = true
        }
        else {
//            topConstraint.constant = 15
            jobViewStyleButton.setTitle("Calendar", forState: .Normal)
            calendarContainerView.hidden = true
            tableView.hidden = false
        }
    }
    // MARK: Functions
    
    func initialize() {
        calendarContainerView.hidden = true
//        topConstraint.constant = 15
        tableView.hidden = false
        appDelegate.mainVC = self
        Utility.borderRadiusView(addTimeslotView.frame.size.width / 2, view: addTimeslotView)
        Utility.borderRadiusView(addTimeslotButton.frame.size.width / 2, view: addTimeslotButton)
        
        let menuRightNavigationController = Utility.getSideMenuNavigationC()

        SideMenuManager.menuRightNavigationController = menuRightNavigationController
        SideMenuManager.menuAddPanGestureToPresent(toView: self.view)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.view)
        self.syncJobsWithType(.New)
        changeViewAction(weekButton)
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
                            if job.status == type {
                                self.jobs.append(Job.createJobFromDict(value))
                            }
                            else if type == .Accepted && (job.status == .EnRoute || job.status == .Assigned) {
                                self.jobs.append(Job.createJobFromDict(value))
                            }
                        }
                        if run == max {
                            self.tableView.reloadData()
                            self.renderJobInDate(NSDate())
                        }
                    })
                    
                }
            }
        })
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
        return 60.0;
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        jobSelected = self.jobs[indexPath.row]
//        self.performSegueWithIdentifier("JobDetailsSegue", sender: nil)
//    }
    
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
            job.setJobStatus(.Accepted)
            self.syncJobsWithType(.New)
        }
    }
    
    func goToDetails(job: Job?) {
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
        todayLabel.text = kDateMMMYYYY.stringFromDate(date.convertedDate()!)
    }
    
    // MARK: DDCalendar's delegate
    
    func calendarView(view: DDCalendarView, focussedOnDay date: NSDate) {
        renderJobInDate(date)
    }
    
    func renderJobInDate(date: NSDate) {
        if self.jobs.count > 0 {
            var ddEvents = [DDCalendarEvent]()
            for job in self.jobs {
                let stringTo = kDateddMMYY.stringFromDate(job.jobStartTime)
                let stringFrom = kDateddMMYY.stringFromDate(date)
//                print("**** \(stringTo) \(stringFrom)")
                if stringTo == stringFrom {
                    let ekEvent = EKEvent(eventStore: EKEventStore())
                    ekEvent.title = job.businessName
                    let dStr = kDateddMMMMYY.stringFromDate(NSDate())
                    let hStr = kDatehhMM.stringFromDate(job.jobStartTime)
//                    print("\(dStr) \(hStr)")
                    let dateF = kDateJobTime.dateFromString("\(dStr) \(hStr)")!
//                    print("^^^^^^ \(dateF)")
                    ekEvent.startDate = dateF
                    ekEvent.endDate = ekEvent.startDate.dateByAddingTimeInterval(3600)
                    let ddEvent = DDCalendarEvent()
                    ddEvent.title = ekEvent.title
                    ddEvent.dateBegin = ekEvent.startDate
                    ddEvent.dateEnd = ekEvent.endDate
                    ddEvent.userInfo = ["event" : ekEvent]
                    ddEvents.append(ddEvent)
                }
            }
            print(ddEvents.count)
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
        return EventView(event: event)
    }
    
    // MARK: CVCalendarViewDelegate's methods
    func didSelectDayView(dayView: DayView, animationDidFinish: Bool) {
        if let date = dayView.date.convertedDate() {
            renderJobInDate(date)
        }
    }
    
}
