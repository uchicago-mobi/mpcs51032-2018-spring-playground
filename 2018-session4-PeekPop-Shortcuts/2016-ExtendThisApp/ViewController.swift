//
//  ViewController.swift
//  2016-ExtendThisApp
//
//  Created by T. Andrew Binkowski on 4/17/16.
//  Copyright © 2016 The University of Chicago, Department of Computer Science. All rights reserved.
//

import UIKit
import DataKit


class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let shortcut = UIApplicationShortcutItem(type: "mobi.uchicago.shortcuts.dynamic",
                                             localizedTitle: "😀Shortcut Title",
                                             localizedSubtitle: "Dynamic",
                                             icon: UIApplicationShortcutIcon(type: .add),
                                             userInfo: nil)
    UIApplication.shared.shortcutItems = [shortcut]
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}

