//
//  AppDelegate.swift
//  MOJO-E
//
//  Created by Long Phan on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import UIKit
import JLToast
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainVC: UIViewController?
    var isRegisterNotiFirstTime = true
    var jobsFirstLoad = [Job]()
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        JLToastView.setDefaultValue(
            UIColor.blackColor(),
            forAttributeName: JLToastViewBackgroundColorAttributeName,
            userInterfaceIdiom: .Phone
        )
        FIRApp.configure()
        // Override point for customization after application launch.
        if let profile = Profile.get() {
            if profile.isLogged {
                profile.registerForJobsAdded()
//                if let profile = Profile.get() where profile.isAdmin == true {
//                    self.getAdminJobs()
//                }
//                else {
//                    self.syncJobsWithType(.Assigned)
//                }
                Utility.openAuthenticatedFlow()
            }
//            if let email = kUserDefault.objectForKey(kUsernameRemember) as? String, let password = kUserDefault.objectForKey(kPasswordRemember) as? String {
//                myRootRef.authUser(email, password: password) { (error, authData) -> Void in
//                    if let _ = error {
//                        // dont care
//                    } else {
//                        print("Successfully created user account with uid: \(authData.uid)")
//                        kUserDefault.setObject(authData.uid, forKey: kUserId)
//                    }
//                }
//            }
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    private func getAdminJobs() {
        Profile.get()!.getJobsAsAdmin({ (arrIDs) in
            print(arrIDs)
            if arrIDs.count > 0 {
                let max = arrIDs.count
                var run = 0
                for id in arrIDs {
                    myRootRef.child("jobs").child(id).observeEventType(.Value, withBlock: {
                        snapshot in
                        run = run + 1
                        if let value = snapshot.value as? NSDictionary {
                            let job = Job.createJobFromDict(value)
                            job.isRegional = true
                            job.jobID = id
                            self.jobsFirstLoad.append(job)
                        }
                        if run == max {
                            if self.jobsFirstLoad.count > 0 {
                                Utility.openAuthenticatedFlow()
                            }
                            else {
                                Utility.openAuthenticatedFlow()
                            }
                        }
                    })
                }
            }
            else {
                Utility.openAuthenticatedFlow()
            }
        })
    }
    
    func syncJobsWithType(type: JobStatus)
    {
        let profile = Profile.get()
        profile?.jobsFromFirebase({ (arrayIDs) in
            if let arrayIDs = arrayIDs where arrayIDs.count > 0 {
                let max = arrayIDs.count
                var run = 0
                for id in arrayIDs {
                    myRootRef.child("jobs").child(id).observeEventType(.Value, withBlock: {
                        snapshot in
                        run = run + 1
                        if let value = snapshot.value as? NSDictionary {
                            let job = Job.createJobFromDict(value)
                            if job.status == type {
                                self.jobsFirstLoad.append(Job.createJobFromDict(value))
                            }
                            else if type == .Accepted && (job.status == .EnRoute || job.status == .Started) {
                                self.jobsFirstLoad.append(Job.createJobFromDict(value))
                            }
                            else if type == .New && job.status == .Assigned {
                                self.jobsFirstLoad.append(Job.createJobFromDict(value))
                            }
                        }
                        if run == max {
                            if self.jobsFirstLoad.count > 0 {
                                Utility.openAuthenticatedFlow()
                            }
                            else {
                                Utility.openAuthenticatedFlow()
                            }
                        }
                    })
                }
            }
            else {
                Utility.openAuthenticatedFlow()
            }
            self.isRegisterNotiFirstTime = false
        })
    }
    

}

