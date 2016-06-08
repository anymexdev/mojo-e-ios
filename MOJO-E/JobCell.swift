//
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import Font_Awesome_Swift

@objc protocol JobCellDelegate {
    func acceptJob(job: Job?)
    func goToDetails(job: Job?)
}

class JobCell: MGSwipeTableCell {

    // MARK: UI's elements
    @IBOutlet weak var businessNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    
    
    // MARK: Class's properties
    weak var delegateCell: JobCellDelegate?
    var job: Job?
    
    //MARK: Contructor
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialize()
    }
    
    // MARK: Class's public methods
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialize()
        self.visualize()
        self.localize()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Class's private methods
    func initialize() {
        //        let user = UserInfo.getUSerInfo()
    }
    
    func visualize() {
        
    }
    
    func localize() {
        
    }
    
    func renderUI() {
        if let job = self.job {
            self.businessNameLabel.text = job.businessName
            self.addressLabel.text = job.address1
            if job.type.lowercaseString == "new" || job.type.lowercaseString == "assigned" {
                acceptButton.hidden = false
            }
            else {
                acceptButton.hidden = true
            }
        }
    }
    
    func cleanCell() {
        self.businessNameLabel.text = ""
        self.addressLabel.text = ""
        acceptButton.hidden = true
    }
    
    
    @IBAction func acceptAction(sender: AnyObject) {
        delegateCell?.acceptJob(job)
    }
    
    @IBAction func goDetailsAction(sender: AnyObject) {
        delegateCell?.goToDetails(job)
    }
}
