//
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import UIKit

@objc protocol TimeCellProtocol: NSObjectProtocol {
    func deleteTimeItem(time:TimeSlot )
}

class ListTimeCell: UITableViewCell {
    //MARK: Properties
    @IBOutlet weak var timeLabel: UILabel!
    
    var delegate: TimeCellProtocol?
    var dateToDate: TimeSlot?
    
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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialize()
    }
    
    // MARK: Class's private methods
    func initialize() {
        
    }
    
    func visualize() {
        
    }
    
    func localize() {
        
    }
    
    func renderUI() {
        let toTime = dateToDate?.toTime?.toShortTime()
        let fromTime = dateToDate?.fromTime?.toShortTime()
        timeLabel.text = String(fromTime! + " - " + toTime!)
    }
    
    //MARK: Action
    @IBAction func deleteCellAction(sender: AnyObject) {
        delegate?.deleteTimeItem(dateToDate!)
    }
    
}

