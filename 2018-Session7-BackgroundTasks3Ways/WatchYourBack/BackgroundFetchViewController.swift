//
//  ViewController.swift
//  WatchYourBack
//
//  Created by T. Andrew Binkowski on 5/7/17.
//  Copyright © 2017 T. Andrew Binkowski. All rights reserved.
//

import UIKit

class BackgroundFetchViewController: UIViewController {
  
  /// Datestamp label
  @IBOutlet weak var timeLabel: UILabel!
  
  /// Formatted date
  var currentTime: Date? {
    didSet {
      if let currentTime = self.currentTime {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .long
        self.timeLabel.text = formatter.string(from: currentTime)
      }
    }
  }
  
  //
  // MARK: - Lifecycle
  //
  override func viewDidLoad() {
    super.viewDidLoad()
    self.updateInterface()
  }
  
  // 
  // MARK: - Fetching and Updating
  //
  func fetchData(_ completion: () -> Void) {
    // Some long running task
    for i in 0...100 {
      print(i)
    }
    completion()
  }
  
  /// Update the UI
  func updateInterface() {
    print("🐶 BackgroundFetchViewController: Update the UI")
    self.currentTime = Date()
  }
}


