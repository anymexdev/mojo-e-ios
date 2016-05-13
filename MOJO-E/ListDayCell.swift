//
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import UIKit

class ListDayCell: UICollectionViewCell {

    //MARK: Properties
    @IBOutlet weak var thuLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    var date: DateInfo?
    var colorUnSelected: UIColor?
    var colorSelected = Utility.greenL1Color()
    
    // MARK: Class's public methods
    override func awakeFromNib() {
        super.awakeFromNib()
        colorUnSelected = thuLabel.textColor
    }
    
    //MARK: private method
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func renderUI() {
        let dateD = date!.mDate
        thuLabel.text =  dateD!.thu()
        dayLabel.text = String( dateD!.day() )
        if date!.mselect {
            renderItemSelect()
        }
        else {
            renderUnItemSelect()
        }
    }
    
    func renderItemSelect() {
        thuLabel.textColor = colorSelected
        dayLabel.textColor = colorSelected
    }
    
    func renderUnItemSelect() {
        thuLabel.textColor = colorUnSelected
        dayLabel.textColor = colorUnSelected
    }
    
    func cleanCell() {
        thuLabel.text = ""
        dayLabel.text = ""
        renderUnItemSelect()
    }
    
}
