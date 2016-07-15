///
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import UIKit
import MapKit
import JPSThumbnailAnnotation
import DKImagePickerController
import EPSignature

class JobViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, EPSignatureDelegate {
    
    //MARK: private property
    var jobSelected: Job?
    var locationManager = CLLocationManager()
    var pinLocation: CLLocation?
    var imagesList = [UIImage]()
    var fLatLong = "saddr=%f,%f"
    var toLatLong = "daddr=%f,%f"
    var personalTimeSlots = [TimeSlot]()

    //MARK: UI Element
    @IBOutlet weak var businessName: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var widthOfMapConstraint: NSLayoutConstraint!
    @IBOutlet weak var acceptButton: RectangleButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var createTimeLabel: UILabel!
    @IBOutlet weak var mainScroll: UIScrollView!
    @IBOutlet weak var uploadPicturesButton: RectangleButton!
    @IBOutlet weak var imageScroll: UIScrollView!
    @IBOutlet weak var jobEndLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var signatureButton: RectangleButton!
    @IBOutlet weak var signatureImage: UIImageView!
    @IBOutlet weak var jobHeaderLabel: UILabel!
    @IBOutlet weak var workscopeView: UITextView!
    
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
    
    @IBAction func rejectAction(sender: AnyObject) {
        self.jobSelected!.setJobStatus(.New)
        self.jobSelected!.rejectJob(Profile.get()!.authenID)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func acceptAction(sender: AnyObject) {
        let title = acceptButton.titleLabel?.text
        if title == JobStatus.EnRoute.rawValue {
            jobSelected!.setJobStatus(JobStatus.EnRoute)
            acceptButton.setTitle("Start", forState: .Normal)
            return
        }
        else if title == "Start" {
            let slot = TimeSlot(to: self.jobSelected!.jobSchedultedEndTime, from: self.jobSelected!.jobStartTime, note: "")
            if slot.slotWasOccupied(personalTimeSlots) {
                Utility.showAlertWithMessage(kOccupiedTimesloteWithPersonal)
                return
            }
            jobSelected!.setJobStatus(JobStatus.Started)
            self.jobSelected!.setJobStartTime()
            acceptButton.setTitle(JobStatus.Finished.rawValue, forState: .Normal)
            return
        }
        else if title == JobStatus.Finished.rawValue {
            imageScroll.hidden = false
            uploadPicturesButton.hidden = false
            acceptButton.setTitle("Submit", forState: .Normal)
            signatureButton.hidden = false
            signatureImage.hidden = false
            return
        }
        else if title == "Submit" {
            var imageURLList = [String]()
            for (index, image) in imagesList.enumerate() {
                let data = UIImagePNGRepresentation(image)
                let profilePicRef = storage.reference().child("job_finished").child("\(self.jobSelected!.id)").child("\(index).png")
                _ = profilePicRef.putData(data!, metadata: nil) { metadata, error in
                    if (error != nil) {
                        // Uh-oh, an error occurred!
                    } else {
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        let downloadURL = metadata!.downloadURL
                        if let url = downloadURL()?.absoluteString {
                            imageURLList.append(url)
                            self.jobSelected!.setJobPictures(imageURLList)
                        }
                    }
                }
            }
            if let image = signatureImage.image {
                let data = UIImagePNGRepresentation(image)
                let signaturePicRef = storage.reference().child("Signatures").child("\(self.jobSelected!.id).png")
                _ = signaturePicRef.putData(data!, metadata: nil) { metadata, error in
                    if (error != nil) {
                        // Uh-oh, an error occurred!
                    } else {
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        let downloadURL = metadata!.downloadURL
                        if let url = downloadURL()?.absoluteString {
                            self.jobSelected!.setJobSignature(url)
                        }
                    }
                }
            }
            jobSelected!.setJobStatus(JobStatus.Finished)
            self.jobSelected!.setJobSubmitTime()
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func uploadPicturesAction(sender: AnyObject) {
        let pickerController = DKImagePickerController()
        pickerController.maxSelectableCount = 10
        pickerController.assetType = .AllPhotos
        pickerController.navigationBar.backgroundColor = Utility.greenL3Color()
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            //print("didSelectAssets")
            if assets.count > 0 {
                for view in self.imageScroll.subviews {
                    view.removeFromSuperview()
                }
                self.imagesList.removeAll()
                for (index, asset) in assets.enumerate() {
                    asset.fetchOriginalImage(true, completeBlock: {
                        image, info in
                            if let image = image {
                                let imageV = UIImageView(frame: CGRectMake(CGFloat(index) * 105.0, 0, 100, 100))
                                imageV.image = image
                                imageV.contentMode = .ScaleAspectFit
                                self.imagesList.append(image)
                                self.imageScroll.addSubview(imageV)
                            }
                        }
                    )
                }
                var contentSize = self.imageScroll.contentSize
                contentSize.width = CGFloat(assets.count) * 105
                contentSize.height = self.imageScroll.frame.size.height
                self.imageScroll.contentSize = contentSize
            }
        }
        
        self.presentViewController(pickerController, animated: true) {}
    }
    
    @IBAction func signatureAction(sender: AnyObject) {
        let signatureVC = EPSignatureViewController(signatureDelegate: self, showsDate: true, showsSaveSignatureOption: false)
//        signatureVC.subtitleText = "I agree to the terms and conditions"
        signatureVC.title = "My Signature"
        signatureVC.tintColor = Utility.greenL1Color()
        let nav = UINavigationController(rootViewController: signatureVC)
        presentViewController(nav, animated: true, completion: nil)
    }
    
    @IBAction func showDirctionsAction(sender: AnyObject) {
        let url = "http://maps.google.com/maps?\(fLatLong)&\(toLatLong)"
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
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
        if let pin = self.pinLocation {
            updateDistanceToAnotation(pin, userLocation: locValue)
        }
        var data = Dictionary<String, Double>()
        data["latitude"] = locValue.latitude
        data["longitude"] = locValue.longitude
        data["updated_at"] = round(NSDate().timeIntervalSince1970)
        fLatLong = "saddr=\(locValue.latitude),\(locValue.longitude)"
        if let profile = Profile.get() {
            myRootRef.child("users").child(profile.authenID).child("location").setValue(data)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.description)
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print(error.description)
    }
    
    // MARK: Signature
    func epSignature(_: EPSignature.EPSignatureViewController, didCancel error: NSError) {
    
    }
    
    func epSignature(_: EPSignatureViewController, didSign signatureImage: UIImage, boundingRect: CGRect) {
        self.signatureImage.image = signatureImage
        self.signatureImage.contentMode = .ScaleAspectFit
        self.signatureImage.backgroundColor = UIColor.whiteColor()
    }
    
    
    //MARK: Other functions
    func initialize() {
        signatureButton.layer.borderColor = UIColor.whiteColor().CGColor
        signatureButton.layer.borderWidth = 1
        
        acceptButton.layer.borderColor = UIColor.whiteColor().CGColor
        acceptButton.layer.borderWidth = 1
        
        rejectButton.layer.borderColor = UIColor.redColor().CGColor
        rejectButton.layer.borderWidth = 1
        
        uploadPicturesButton.layer.borderColor = UIColor.whiteColor().CGColor
        uploadPicturesButton.layer.borderWidth = 1
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        appDelegate.mainVC = self
//        if jobSelected?.status == JobStatus.New || jobSelected?.status == JobStatus.Assigned {
//            rejectButton.hidden = false
//        }
        if jobSelected?.status == JobStatus.Assigned {
            acceptButton.setTitle(JobStatus.EnRoute.rawValue, forState: .Normal)
        }
        else if jobSelected?.status == JobStatus.EnRoute {
            acceptButton.setTitle("Start", forState: .Normal)
        }
        else if jobSelected?.status == JobStatus.Started {
            acceptButton.setTitle(JobStatus.Finished.rawValue, forState: .Normal)
        }
        else if jobSelected?.status == JobStatus.Finished {
            acceptButton.hidden = true
            endTimeLabel.hidden = false
            jobEndLabel.hidden = false
            loadImagesFromJob()
            loadSignatureFromJob()
        }
        loadJobInfo()
        TimeSlot.allPersonalTimeslots { (timeslots) in
            if timeslots.count > 0 {
                self.personalTimeSlots = timeslots
            }
        }
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
        typeLabel.text = jobSelected?.status.rawValue
        if let jobStartTime = jobSelected?.jobStartTime {
            createTimeLabel.text = kDateJobTime.stringFromDate(jobStartTime)
        }
        if let jobEndTime = jobSelected?.jobEndTime {
            endTimeLabel.text = kDateJobTime.stringFromDate(jobEndTime)
        }
        workscopeView.text = jobSelected?.workScope
        self.jobHeaderLabel.text = "SR Number \(jobSelected!.srNumber)"
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
            toLatLong = "daddr=\(lat),\(long)"
        }
    }
    
    private func updateDistanceToAnotation(anotationLocation: CLLocation, userLocation: CLLocationCoordinate2D) {
        let userLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let distance = anotationLocation.distanceFromLocation(userLocation)
        let stringMiles  = NSString(format: "%.1f miles", distance/1609.344)
        distanceLabel.text = "\(stringMiles)"
        mainScroll.contentSize = CGSizeMake(widthOfMapConstraint.constant, 950)
    }
    
    private func loadImagesFromJob() {
        imageScroll.hidden = false
        uploadPicturesButton.hidden = false
        uploadPicturesButton.enabled = false
        for index in 0...(jobSelected!.pictureCount - 1) {
            let jobPicturesRef = storage.reference().child("job_finished").child("\(self.jobSelected!.id)").child("\(index).png")
            jobPicturesRef.dataWithMaxSize(20 * 1024 * 1024, completion: { (data, error) in
                if let error = error {
                    print(error.description)
                }
                else {
                    if let data = data, let image = UIImage(data: data) {
                        let imageV = UIImageView(frame: CGRectMake(CGFloat(index) * 105.0, 0, 100, 100))
                        imageV.image = image
                        imageV.contentMode = .ScaleAspectFit
                        self.imageScroll.addSubview(imageV)
                    }
                }
            })
        }
        
        var contentSize = self.imageScroll.contentSize
        contentSize.width = CGFloat(jobSelected!.pictureCount) * 105
        contentSize.height = self.imageScroll.frame.size.height
        self.imageScroll.contentSize = contentSize
    }
    
    private func loadSignatureFromJob() {
        signatureButton.hidden = false
        signatureButton.enabled = false
        signatureImage.hidden = false
        let jobSignatureRef = storage.reference().child("Signatures").child("\(self.jobSelected!.id).png")
        jobSignatureRef.dataWithMaxSize(1 * 1024 * 1024, completion: { (data, error) in
            if let error = error {
                print(error.description)
            }
            else {
                if let data = data, let imageV = UIImage(data: data) {
                    self.signatureImage.image = imageV
                    self.signatureImage.contentMode = .ScaleAspectFit
                    self.signatureImage.backgroundColor = UIColor.whiteColor()
                }
            }
        })
    }
    
}
