//
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class JobsListViewController: UIViewController, MGSwipeTableCellDelegate, JobCellDelegate {
    
    //MARK: UI Element
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: private property
    var jobs = [Job]()
    
    //MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    // MARK: UITableViewDataSource.
    func syncJobsWithType(type: String)
    {
        jobsRef.observeEventType(.Value, withBlock: {
            snapshot in
            self.jobs.removeAll()
            if let arrayData = snapshot.value.allObjects {
                for value in arrayData {
                    if let value = value as? NSDictionary {
                        let job = Job()
                        if let jobType = value.objectForKey("jobType") as? String, let jobName = value.objectForKey("jobName") as? String, jobDate = value.objectForKey("jobDate") as? String where jobName.count() > 0 && jobType == type  {
                            job.jobName = jobName
                            job.jobDate = jobDate
                            self.jobs.append(job)
                        }
                    }
                }
                self.tableView.reloadData()
            }
        })
    }
    
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
    
    // MARK: UITableViewDelegate.
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
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
