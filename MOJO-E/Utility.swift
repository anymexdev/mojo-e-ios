//
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration
import JLToast
import SideMenu
import GoogleMaps

class Utility {
    
    class func borderRadiusView(radius : CGFloat, view : UIView) {
        view.layer.cornerRadius = radius
        view.layer.masksToBounds = true
    }
    
    class func showAlertWithMessage(message: String) {
        dispatch_async(dispatch_get_main_queue(),{
           let alert = UIAlertView(title: "Info", message: message, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
        })
    }
        
    class func showAlertWithMessageOKCancel(message: String,title: String,sender: UIViewController, doneAction: ( () -> Void )?, cancelAction: ( () -> Void )? ) {
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
                if let action = doneAction {
                    action()
                }
            }
            alert.addAction(okAction)
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) {
                action -> Void in
                if let action = cancelAction {
                    action()
                }
            }
            alert.addAction(cancelAction)
            sender.presentViewController(alert, animated: true, completion: { () in  })
        })
    }
    
    class func showToastWithMessage(mesage: String, duration: NSTimeInterval = JLToastDelay.ShortDelay) {
        JLToast.makeText(mesage, duration: duration).show()
    }
    
    class func lightBlueColor() -> UIColor {
        return UIColor(red: 169.0/255.0, green: 219.0/255.0, blue: 239.0/255.0, alpha: 1.0)
    }
    
    class func navigateToVC(from : UIViewController, vc : UIViewController, direction : String = kCATransitionFromRight) {
        
        vc.view.frame = from.view.frame
        from.addChildViewController(vc)
        from.view.addSubview(vc.view)
        // Move the view move in from the right
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        let transition = CATransition()
        transition.type = kCATransitionPush
        transition.subtype = direction
        vc.view.layer .addAnimation(transition, forKey: kCATransition)
        vc.didMoveToParentViewController(from)
        CATransaction.commit()
    }
    
    class func openAuthenticatedFlow() {
        let authenticationSB = UIStoryboard(name: "Authenticated", bundle: NSBundle.mainBundle())
        let initVC = authenticationSB.instantiateInitialViewController()
        appDelegate.window?.rootViewController = initVC
    }
    
    class func openAuthenticationFlow() {
        let authenticationSB = UIStoryboard(name: "Authentication", bundle: NSBundle.mainBundle())
        let initVC = authenticationSB.instantiateInitialViewController()
        appDelegate.window?.rootViewController = initVC
    }
    
    class func getSideMenuNavigationC() -> UISideMenuNavigationController {
        let authenticationSB = UIStoryboard(name: "Authenticated", bundle: NSBundle.mainBundle())
        let sideMenuNavigationC = authenticationSB.instantiateViewControllerWithIdentifier("SideMenuNavigationControllerID") as! UISideMenuNavigationController
        return sideMenuNavigationC
    }
    
    class func greenL1Color() -> UIColor {
        return UIColor(red: 139.0/255.0, green: 195.0/255.0, blue: 74.0/255.0, alpha: 1.0)
    }
    
    class func greenL2Color() -> UIColor {
        return UIColor(red: 156.0/255.0, green: 204.0/255.0, blue: 101.0/255.0, alpha: 1.0)
    }
    
    class func greenL3Color() -> UIColor {
        return UIColor(red: 174.0/255.0, green: 213.0/255.0, blue: 129.0/255.0, alpha: 1.0)
    }
    
    class func greenL0Color() -> UIColor {
        return UIColor(red: 85.0/255.0, green: 139.0/255.0, blue: 47.0/255.0, alpha: 1.0)
    }
    
    class func scaleImage(image: UIImage, toSize newSize: CGSize) -> (UIImage) {
        let newRect = CGRectIntegral(CGRectMake(0,0, newSize.width, newSize.height))
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, .High)
        let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
        CGContextConcatCTM(context, flipVertical)
        CGContextDrawImage(context, newRect, image.CGImage)
        let newImage = UIImage(CGImage: CGBitmapContextCreateImage(context)!)
        UIGraphicsEndImageContext()
        return newImage
    }
    
    class func nsData2UIImage(data: NSData) -> UIImage? {
        return UIImage(data: data)
    }
    
    
    class func backgroundThread(delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
            if(background != nil){ background!(); }
            
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                if(completion != nil){ completion!(); }
            }
        }
    }
    
    class func downloadImage(imageUrl: String, viewToDisplay: UIImageView) {
        print("\(imageUrl) to download")
        let imgURL: NSURL = NSURL(string: imageUrl)!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
            Utility.backgroundThread(0.0, background: { 
                if error == nil {
                    if let imageV = UIImage(data: data!) {
                        dispatch_async(dispatch_get_main_queue(), {
                            viewToDisplay.image = imageV
                        })
                    }
                }
                else {
                    print("Error: \(error!.localizedDescription)")
                }
                
                }, completion: { 
                    // do nothing
            })
            
        })
    }
    
    class func getPlaceWithoutCurrentLocation(buttonAction: UIButton, completionBlock: (place: GMSPlace?) -> Void) {
        buttonAction.enabled = false
        var center = CLLocationCoordinate2DMake(37.788204, -122.411937)
        if let place = appDelegate.currentPlace {
            center = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
        }
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        GMSPlacePicker(config: config).pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
            buttonAction.enabled = true
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                completionBlock(place: nil)
                return
            }
            completionBlock(place: place)
        })
    }
    
    class func getCurrentLocation(completionBlock: (place: GMSPlace?) -> Void) {
        let placesClient = GMSPlacesClient()
        placesClient.currentPlaceWithCallback({ (placeLikelihoods, error) -> Void in
            if error != nil
            {
                print("Current Place error: \(error!.localizedDescription)")
            } else {
                if let placeLikelihoods = placeLikelihoods {
                    if let place = placeLikelihoods.likelihoods.first?.place {
                        completionBlock(place: place)
                    }
                    else {
                        completionBlock(place: nil)
                    }
                }
                else {
                    completionBlock(place: nil)
                }
            }
        })
    }
    
    class func getCurrentLocationCordinate(completionBlock: (location: CLLocation?) -> Void) {
        let placesClient = GMSPlacesClient()
        placesClient.currentPlaceWithCallback({ (placeLikelihoods, error) -> Void in
            if error != nil
            {
                print("Current Place error: \(error!.localizedDescription)")
            } else {
                if let placeLikelihoods = placeLikelihoods {
                    if let place = placeLikelihoods.likelihoods.first?.place {
                        let location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
                        completionBlock(location: location)
                    }
                    else {
                        completionBlock(location: nil)
                    }
                }
                else {
                    completionBlock(location: nil)
                }
            }
        })
    }
    
    //MARK: Check internet connection
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    class func showIndicatorForView(view: UIView) {
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        indicatorView.tag = 2601
        indicatorView.color = Utility.greenL0Color()
        indicatorView.center = view.center
        indicatorView.startAnimating()
        //view.userInteractionEnabled = false
        view.addSubview(indicatorView)
    }
    
    class func removeIndicatorForView(view: UIView) {
        dispatch_async(dispatch_get_main_queue(),{
            let view1 = view.viewWithTag(2601) as? UIActivityIndicatorView
            if let indicator = view1 {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
            view.userInteractionEnabled = true
        })
    }
    
    class func showInAppNotification() {
        let notification = CWStatusBarNotification()
        notification.notificationStyle = .NavigationBarNotification
        notification.notificationLabelBackgroundColor = UIColor.blueColor()
        notification.notificationLabelTextColor = UIColor.whiteColor()
        notification.displayNotificationWithMessage("New job was assigned", forDuration: 2.0)
        notification.notificationTappedClosure = {
            if !notification.notificationIsDismissing {
                notification.dismissNotification()
            }
            
        }
    }

}