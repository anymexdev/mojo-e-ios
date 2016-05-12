///
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import UIKit
import MapKit
class JobViewController: UIViewController, MKMapViewDelegate {
    
    //MARK: private property
    var jobSelected: Job?

    //MARK: UI Element
    @IBOutlet weak var businessName: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var widthOfMapConstraint: NSLayoutConstraint!
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.widthOfMapConstraint.constant = self.view.bounds.size.width - 60.0
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Button's action
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: Other functions
    func initialize() {
        loadJobInfo()
    }
    
    func loadJobInfo() {
        businessName.text = jobSelected?.businessName
        addressLabel.text = jobSelected?.address1
        cityLabel.text = jobSelected?.city
        typeLabel.text = jobSelected?.type
    }
}
