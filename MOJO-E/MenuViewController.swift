//
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import UIKit
import Font_Awesome_Swift
import SideMenu

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Mark: UI's elements
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buildVersionLabel: UILabel!
    
    // Mark: Application's life cirlce
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    // Mark: Class's properties
    var dataSource = [String]()
    var dataIcons = [FAType]()
    
    // Mark: class's private methods
    private func initialize() {
        generateData()
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            self.buildVersionLabel.text = "Build version \(version)"
        }
    }
    
    private func generateData() {
        dataSource.append("Worker information")
        dataIcons.append(FAType.FAUser)
        dataSource.append("Verification status")
        dataIcons.append(FAType.FACheckSquare)
        dataSource.append("Asssociated Companies")
        dataIcons.append(FAType.FAUniversity)
        dataSource.append("Change Password")
        dataIcons.append(FAType.FAUserSecret)
        dataSource.append("Sign Out")
        dataIcons.append(FAType.FASignOut)
    }
    
    
    // MARK: UITableViewDataSource.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell") as! MenuCell
        cell.cleanCell()
        cell.renderUI(dataIcons[indexPath.row], text: dataSource[indexPath.row])
        if indexPath.row == 0 {
            cell.highLight()
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    // MARK: UITableViewDelegate.
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dataMenu = dataIcons[indexPath.row]
        if dataMenu == FAType.FASignOut {
            if let profile = Profile.get() {
                profile.isLogged = false
                profile.saveProfile()
            }
            Utility.openAuthenticationFlow()
        }
        else if dataMenu == FAType.FAUser {
            SideMenuManager.menuRightNavigationController?.dismissViewControllerAnimated(true, completion: {
                appDelegate.mainVC!.performSegueWithIdentifier("WorkerSegue", sender: self)
            })
        }
        else {
            SideMenuManager.menuRightNavigationController?.dismissViewControllerAnimated(true, completion: {
                appDelegate.mainVC!.performSegueWithIdentifier("SampleViewSegue", sender: self)
            })
            
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0;
    }
    
    deinit {
        print("******* Menu view deinit")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

