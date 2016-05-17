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

class JobsListViewController: UIViewController, MGSwipeTableCellDelegate, JobCellDelegate, UITableViewDelegate, UITableViewDataSource, CVCalendarViewDelegate, CVCalendarMenuViewDelegate, CVCalendarViewAppearanceDelegate {
    
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
        self.syncJobsWithType("Incoming")
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
                self.syncJobsWithType("Incoming")
            }
            else if segment.selectedSegmentIndex == 1 {
                self.syncJobsWithType("Accepted")
            }
            else if segment.selectedSegmentIndex == 2 {
                self.syncJobsWithType("Completed")
            }
        }
    }
    
    @IBAction func addTimeslotAction(sender: AnyObject) {
        self.performSegueWithIdentifier("TimeslotSegue", sender: nil)
    }
    
    @IBAction func changeViewAction(sender: AnyObject) {
        if jobViewStyleButton.currentTitle == "Calendar" {
            topConstraint.constant = calendarView.frame.size.height + calendarView.frame.origin.y + 50
            jobViewStyleButton.setTitle("List", forState: .Normal)
            calendarContainerView.hidden = false
        }
        else {
            topConstraint.constant = 15
            jobViewStyleButton.setTitle("Calendar", forState: .Normal)
            calendarContainerView.hidden = true
        }
    }
    // MARK: Functions
    
    func initialize() {
        calendarContainerView.hidden = true
        topConstraint.constant = 15
        appDelegate.mainVC = self
        Utility.borderRadiusView(addTimeslotView.frame.size.width / 2, view: addTimeslotView)
        Utility.borderRadiusView(addTimeslotButton.frame.size.width / 2, view: addTimeslotButton)
        
        let menuRightNavigationController = Utility.getSideMenuNavigationC()

        SideMenuManager.menuRightNavigationController = menuRightNavigationController
        SideMenuManager.menuAddPanGestureToPresent(toView: self.view)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.view)
    }
    
    func syncJobsWithType(type: String)
    {
        jobsRef.observeEventType(.Value, withBlock: {
            snapshot in
            self.jobs.removeAll()
            if let arrayData = snapshot.value.allObjects {
                for value in arrayData {
                    if let value = value as? NSDictionary {
                        let job = Job.createJobFromDict(value)
                        if job.type == type {
                            self.jobs.append(Job.createJobFromDict(value))
                        }
                    }
                }
                self.tableView.reloadData()
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
            job.accepted()
            self.syncJobsWithType("Incoming")
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
    
}
