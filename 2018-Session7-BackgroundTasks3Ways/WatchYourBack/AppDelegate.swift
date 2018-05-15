//
//  AppDelegate.swift
//  WatchYourBack
//
//  Created by T. Andrew Binkowski on 5/7/17.
//  Copyright © 2017 T. Andrew Binkowski. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var backgroundSessionCompletionHandler: (() -> Void)?
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    // Minimum size defined by the system
    //UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
    
    // At least 10 seconds
    UIApplication.shared.setMinimumBackgroundFetchInterval(10)
    
    return true
  }
  
  // Support for background fetch
  func application(_ application: UIApplication,
                   performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    
    // A. Find the view controller we want in the hierachy
    if let tabBarController = window?.rootViewController as? UITabBarController {
     
      // Background Fetch
      if let fetchViewController = tabBarController.viewControllers?[0] as? BackgroundFetchViewController    {
        // B. Execute function in fetch view controller
        fetchViewController.fetchData {
          // C. In completion block, update the UI
          fetchViewController.updateInterface()
  
          // D. Tell OS we're done so that it can update the multitasking snapshot
          completionHandler(.newData)
        }
      }
     
      // BackgroundURL Fetch
      if let fetchViewController = tabBarController.viewControllers?[0] as? BackgroundDownloadViewController    {
        fetchViewController.updateInterface()
        completionHandler(.newData)
      }
    }
  }
  
  // Support for URLSession background download
  func application(_ application: UIApplication,
                   handleEventsForBackgroundURLSession identifier: String,
                   completionHandler: @escaping () -> Void) {
    print("🐶👌: handleEventsForBackgroundURLSession: \(identifier)")
    
    
    self.backgroundSessionCompletionHandler = completionHandler
  }
  
  
}

