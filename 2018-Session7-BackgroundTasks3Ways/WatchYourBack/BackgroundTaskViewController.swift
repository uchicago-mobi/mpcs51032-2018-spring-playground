//
//  BackgroundTaskViewController.swift
//  WatchYourBack
//
//  Created by T. Andrew Binkowski on 5/8/17.
//  Copyright © 2017 T. Andrew Binkowski. All rights reserved.
//

import UIKit

class BackgroundTaskViewController: UIViewController {
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    longRunningTask()
  }
  
  /// A artificially long running task
  func longRunningTask() {
    
    // Register a long running task with the system
    var bti : UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    bti = UIApplication.shared.beginBackgroundTask(expirationHandler: {
      // Clean up after run (or denial)
      print("🗑 Cleanup before task is over.  We are here if the system cancelled our task before we did.")
      
      // Call the completion handler
      UIApplication.shared.endBackgroundTask(bti)
    })
    
    // Do the work
    for i in 0...1000000 {
      print(i)
    }
    
    // Tell the OS we are done
    DispatchQueue.main.async {
      UIApplication.shared.endBackgroundTask(bti)
    }
  }
}
