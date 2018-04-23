//
//  AppDelegate.swift
//  2017-ExtendThisApp
//
//  Created by T. Andrew Binkowski on 4/17/16.
//  Copyright © 2016 The University of Chicago, Department of Computer Science. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last as Any);
    
    // Print out the app group (for fun)
    let sharedAppGroup: String = "group.2017-extend-this-app"
    let directory: NSURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: sharedAppGroup)! as NSURL
    print("App Group URL: \(directory)")
    

    return true
  }
  
  
  
  
  
  // Handle the application shortcuts from the home screen
  func application(_ application: UIApplication,
                   performActionFor shortcutItem: UIApplicationShortcutItem,
                   completionHandler: @escaping (Bool) -> Void) {
    print(shortcutItem)
    completionHandler(true)
  }
  
}

