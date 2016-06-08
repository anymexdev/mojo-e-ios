///
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import UIKit
import MapKit
import JPSThumbnailAnnotation

class JobViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    //MARK: private property
    var jobSelected: Job?
    var locationManager = CLLocationManager()
    var pinLocation: CLLocation?

    //MARK: UI Element
    @IBOutlet weak var businessName: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var widthOfMapConstraint: NSLayoutConstraint!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var createTimeLabel: UILabel!
    @IBOutlet weak var mainScroll: UIScrollView!
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        drawPinsOfRequest()
        widthOfMapConstraint.constant = self.view.bounds.size.width - 60.0
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
        var status = "Accepted"
        let title = acceptButton.titleLabel?.text
        if title == "Accepted" {
            status = "Accepted"
        }
        else if title == "Start" {
            status = "Started"
        }
        else if title == "Finished" {
            status = "Finished"
        }
        if let job = jobSelected {
            job.setJobStatus(status)
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
        if let pin = self.pinLocation {
            updateDistanceToAnotation(pin, userLocation: locValue)
        }
        var data = Dictionary<String, Double>()
        data["latitude"] = locValue.latitude
        data["longitude"] = locValue.longitude
        data["updated_at"] = round(NSDate().timeIntervalSince1970)
        if let profile = Profile.get() {
            myRootRef.child("users").child(profile.authenID).child("location").setValue(data)
        }
//            let key = "j\(userID)/location"
//            geoFire.setLocation(CLLocation(latitude: locValue.latitude, longitude: locValue.longitude), forKey: userID) { (error) in
//                if (error != nil) {
//                    print("An error occured: \(error)")
//                } else {
//                    print("Saved location successfully!")
//                }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.description)
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print(error.description)
    }
    
    //MARK: Other functions
    func initialize() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        appDelegate.mainVC = self
        acceptButton.hidden = false
        if jobSelected?.type.lowercaseString == "en route" || jobSelected?.type.lowercaseString == "started" {
            acceptButton.setTitle("Finished", forState: .Normal)
        }
        else if jobSelected?.type.lowercaseString == "assigned" || jobSelected?.type.lowercaseString == "accepted" {
            acceptButton.setTitle("Start", forState: .Normal)
        }
        else if jobSelected?.type.lowercaseString == "finished" {
            acceptButton.hidden = true
        }
        loadJobInfo()
    }
    
    func loadJobInfo() {
        businessName.text = jobSelected?.businessName
        var fullAddress = ""
        if let address = jobSelected?.address1 {
            fullAddress = address
        }
        if let city = jobSelected?.city {
            fullAddress += ", " + city
        }
        if let state = jobSelected?.state {
            fullAddress += ", " + state
        }
        if let zip = jobSelected?.zip {
            fullAddress += ", " + zip
        }
        addressLabel.text = fullAddress
        typeLabel.text = jobSelected?.type
        if let jobStartTime = jobSelected?.jobStartTime {
            createTimeLabel.text = kDateJobTime.stringFromDate(jobStartTime)
        }
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
            self.pinLocation = CLLocation(latitude: lat, longitude: long)
        }
    }
    
    private func updateDistanceToAnotation(anotationLocation: CLLocation, userLocation: CLLocationCoordinate2D) {
        let userLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let distance = anotationLocation.distanceFromLocation(userLocation)
        let stringMiles  = NSString(format: "%.1f miles", distance/1609.344)
        distanceLabel.text = "\(stringMiles)"
        mainScroll.contentSize = CGSizeMake(widthOfMapConstraint.constant, self.view.bounds.size.height - 55.0)
    }
    
}
