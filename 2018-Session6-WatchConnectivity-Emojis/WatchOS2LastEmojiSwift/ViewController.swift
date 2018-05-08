//
//  ViewController.swift
//  WatchOS2LastEmojiSwift
//
//  Created by Thai, Kristina on 6/21/15.
//  Copyright © 2015 Kristina Thai. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController {
  
  /// WatchConnectivity session
  let session: WCSession? = WCSession.isSupported() ? WCSession.default() : nil

  @IBOutlet weak var emojiLabel: UILabel!
  
  @IBAction func tapSend(_ sender: UIButton) {
    print("Tap (application context")
    do {
      let applicationDict = ["emoji":"👍"]
      try session?.updateApplicationContext(applicationDict)
    } catch {
      // Handle errors here
      print(error)
    }
    
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    session?.delegate = self
    session?.activate()
  }
}

///
/// Watch
///
extension ViewController: WCSessionDelegate {
  
  @available(iOS 9.3, *)
  public func sessionDidDeactivate(_ session: WCSession) {
    //
  }
  

  @available(iOS 9.3, *)
  public func sessionDidBecomeInactive(_ session: WCSession) {
    //
  }
  
  @available(iOS 9.3, *)
  public func session(_ session: WCSession,
                      activationDidCompleteWith activationState: WCSessionActivationState,
                      error: Error?) {
    print("Actication: \(activationState)")
  }
  
  // Receive context
  func session(_ session: WCSession,
               didReceiveApplicationContext applicationContext: [String : Any]) {
    let emoji = applicationContext["emoji"] as? String
    
    //Use this to update the UI
    DispatchQueue.main.async {
      if let emoji = emoji {
        self.emojiLabel.text = "Last emoji: \(emoji)"
      }
    }
  }
  
  // Receive data
  func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
  //
  }
  
  func session(_ session: WCSession,
               didReceiveMessage message: [String : Any],
               replyHandler: @escaping ([String : Any]) -> Void) {
    print("Message Data:\(message)")
  }
}

