//
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import SideMenu

class JobsListViewController: UIViewController, MGSwipeTableCellDelegate, JobCellDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: UI Element
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTimeslotView: UIView!
    @IBOutlet weak var addTimeslotButton: UIButton!
    
    //MARK: private property
    var jobs = [Job]()
    var jobSelected: Job?
    
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
    
    //MARK: UI Action
    
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
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
    
    // MARK: Functions
    
    func initialize() {
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        jobSelected = self.jobs[indexPath.row]
        self.performSegueWithIdentifier("JobDetailsSegue", sender: nil)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0;
    }
    
    //MARK: -Swipe cell delegate
    func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        let path: NSIndexPath = self.tableView.indexPathForCell(cell)!
        if direction == MGSwipeDirection.LeftToRight && index == 0 {
            acceptJob(jobs[path.row])
        }
        return true
    }
    
    //MARK: Friend request protocol
    func acceptJob(job: Job?) {
        
    }
    
}
