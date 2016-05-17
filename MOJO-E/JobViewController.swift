///
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import UIKit
import MapKit
import JPSThumbnailAnnotation

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
    @IBOutlet weak var acceptButton: UIButton!
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.widthOfMapConstraint.constant = self.view.bounds.size.width - 60.0
        self.drawPinsOfRequest()
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
    
    @IBAction func acceptAction(sender: AnyObject) {
        if let job = jobSelected {
            job.accepted()
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: MapKit's methods
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? JPSThumbnailAnnotation {
            return annotation.annotationViewInMap(mapView)
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let view = view as? JPSThumbnailAnnotationView {
            view.didSelectAnnotationViewInMap(mapView)
        }
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        if let view = view as? JPSThumbnailAnnotationView {
            view.didDeselectAnnotationViewInMap(mapView)
        }
    }
    
    //MARK: Other functions
    func initialize() {
        appDelegate.mainVC = self
        if jobSelected?.type == "Incoming" {
            acceptButton.hidden = false
        }
        else {
            acceptButton.hidden = true
        }
        loadJobInfo()
    }
    
    func loadJobInfo() {
        businessName.text = jobSelected?.businessName
        addressLabel.text = jobSelected?.address1
        cityLabel.text = jobSelected?.city
        typeLabel.text = jobSelected?.type
    }
    
    private func drawPinsOfRequest() {
        let latDelta: CLLocationDegrees = 0.01
        let longDelta: CLLocationDegrees = 0.01
        if let lat = self.jobSelected?.latitude, let long = self.jobSelected?.longtitude {
            let lat: CLLocationDegrees = lat
            let long: CLLocationDegrees = long
            
            let theSpan: MKCoordinateSpan = MKCoordinateSpanMake(latDelta,longDelta)
            
            let mypos: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat,long)
            
            let myreg: MKCoordinateRegion = MKCoordinateRegionMake(mypos, theSpan)
            self.mapView.setRegion(myreg, animated: false)
            
            let pin = JPSThumbnail()
            pin.image = UIImage(named: "PinIcon")
            pin.title = jobSelected?.businessName
            pin.subtitle = jobSelected?.address1
            pin.coordinate = CLLocationCoordinate2DMake(lat, long)
            pin.disclosureBlock = {() -> Void in
                print("tap on job")
            }
            mapView.addAnnotation(JPSThumbnailAnnotation(thumbnail: pin))
        }
    }
}
