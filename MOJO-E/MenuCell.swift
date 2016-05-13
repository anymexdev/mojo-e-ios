//
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift

class MenuCell: UITableViewCell {
    
    // MARK: Class's properties
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var starFontLabel: UILabel!
    
    
    // MARK: UI's elements
    
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
    
    @IBAction func deleteButtonAction(sender: AnyObject) {
        
    }
    
    func renderUI(icon: FAType, text: String) {
        starFontLabel.setFAIcon(icon, iconSize: 20)
        menuLabel.text = text
    }
    
    func highLight() {
    }
    
    func cleanCell() {
        starFontLabel.text = ""
        menuLabel.text = ""
    }
}