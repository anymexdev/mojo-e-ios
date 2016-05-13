///
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import UIKit
import MapKit
class SampleViewController: UIViewController, MKMapViewDelegate {
    
    //MARK: private property

    //MARK: UI Element
    @IBOutlet weak var headerSampleLabel: UILabel!
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
        
    }
    
}
