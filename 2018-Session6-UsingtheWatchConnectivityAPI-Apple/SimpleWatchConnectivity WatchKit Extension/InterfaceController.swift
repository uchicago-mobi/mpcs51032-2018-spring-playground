/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The main interface controller of the WatchKit extension.
 */

import Foundation
import WatchKit
import WatchConnectivity

// identifier: page Interface Controller identifier
// Context: page context, a string used as the action button title
//
fileprivate struct Constants {
    static let controllerIdentifier = "Page"
}

fileprivate struct Context {
    var channel: Channel
    var phrase: Phrase?
    var timedColor: [String: Any]?
}

class InterfaceController: WKInterfaceController, SessionDataProvider {
    
    @IBOutlet var statusGroup: WKInterfaceGroup!
    @IBOutlet var statusLabel: WKInterfaceLabel!
    @IBOutlet var actionGroup: WKInterfaceGroup!
    @IBOutlet var actionButton: WKInterfaceButton!

    // Retain the controllers so that we don't have to reload root controllers for every switch
    //
    static var instances = [InterfaceController]()
    private var channel: Channel!
    
    // Context == nil: the fist-time loading, load pages with reloadRootController then
    // Context != nil: Loading the pages, so save the controller instances so that we can
    // swtich pages more smoothly.
    //
    // Activate the session during the fist-time loading.
    // Note that doing this in applicationDidFinishLaunching blocks sessionReachabilityDidChange,
    // which seems to be a bug.
    //
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let context = context as? Context {
            channel = context.channel
            updateUI(with: context)
            type(of:self).instances.append(self)
        }
        else {
            statusLabel.setText("Activating...")
            reloadRootController()
        }
    }
    
    override func willActivate() {
        super.willActivate()
        guard channel != nil else { return } // For first-time loading do nothing.
        
        // For app context page, retrieve the receieved app context if any and update the UI.
        //
        if channel == .updateAppContext {
            let timedColor = WCSession.default.receivedApplicationContext
            if !timedColor.isEmpty {
                updateUI(with: Context(channel: channel, phrase: .received, timedColor: timedColor))
            }
        }
        
        // Install notification observer.
        //
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of:self).dataDidFlow(_:)),
            name: .dataDidFlow, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of:self).activationDidComplete(_:)),
            name: .activationDidComplete, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of:self).reachabilityDidChange(_:)),
            name: .reachabilityDidChange, object: nil
        )
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        guard channel != nil else { return } // Do nothing for the first-time loading.

        NotificationCenter.default.removeObserver(self, name: .dataDidFlow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .activationDidComplete, object: nil)
        NotificationCenter.default.removeObserver(self, name: .reachabilityDidChange, object: nil)
    }
    
    // Load paged-based UI.
    // If a current context is specified, use the timed color it provided.
    //
    private func reloadRootController(with currentContext: Context? = nil) {
        
        let channels: [Channel] = [.updateAppContext, .sendMessage, .sendMessageData,
                                    .transferUserInfo, .transferFile,
                                    .transferCurrentComplicationUserInfo]
        var contexts = [Context]()
        for aChannel in channels {
            
            var timedColor: [String: Any]? = nil
            
            if let currentContext = currentContext {
                timedColor = (aChannel == currentContext.channel) ? currentContext.timedColor : nil
            }
            contexts.append(Context(channel: aChannel, phrase: nil, timedColor: timedColor))
        }
        
        let names = Array(repeating: Constants.controllerIdentifier, count: contexts.count)
        WKInterfaceController.reloadRootControllers(withNames: names, contexts: contexts)
    }
    
    // Update the user interface with the specified timedColor dictionary.
    //
    private func updateUI(with context: Context, errorMessage: String? = nil) {
        // When the interface controller is initially loaded, Content doesn't have any timed color.
        //
        guard let timedColor = context.timedColor else {
            statusLabel.setText("")
            actionButton.setTitle(context.channel.rawValue)
            return
        }
        
        if let colorData = timedColor[PayloadKey.colorData] as? Data,
            let color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor {
            
            statusLabel.setTextColor(color)
            let title = NSAttributedString(string: context.channel.rawValue,
                                           attributes: [.foregroundColor: color])
            actionButton.setAttributedTitle(title)
        }
        
        // If there is an error, show the message and return.
        //
        if let errorMessage = errorMessage {
            statusLabel.setText("! \(errorMessage)")
            return
        }

        if let timeStamp = timedColor[PayloadKey.timeStamp] as? String {
            statusLabel.setText( context.phrase!.rawValue + " at\n" + timeStamp)
        }
    }
    
    // .dataDidFlow notification handler.
    // Update the UI based on the userInfo dictionary of the notification.
    //
    @objc func dataDidFlow(_ notification: Notification) {
        // Notification should have userInfo, which contains channel, phrase, and timedColor.
        //
        guard let aUserInfo = notification.userInfo as? [String: Any],
            let notificationChannel = aUserInfo[UserInfoKey.channel] as? Channel,
            let phrase = aUserInfo[UserInfoKey.phrase] as? Phrase,
            let timedColor = aUserInfo[UserInfoKey.timedColor] as? [String: Any] else { return }
        
        let context = Context(channel: notificationChannel, phrase: phrase, timedColor: timedColor)
        
        // If the data is from current channel, simple update color and time stamp, then return.
        //
        if notificationChannel == channel {
            updateUI(with: context, errorMessage: aUserInfo[UserInfoKey.error] as? String)
            return
        }
        
        // Move the screen to the page matching the data channel, then update the color and time stamp.
        //
        if let index = type(of:self).instances.index(where: { $0.channel == notificationChannel }) {
            let controller = InterfaceController.instances[index]
            controller.becomeCurrentPage()
            controller.updateUI(with: context, errorMessage: aUserInfo[UserInfoKey.error] as? String)
        }
    }

    // .activationDidComplete notification handler.
    //
   @objc func activationDidComplete(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any],
            let activationStatus = userInfo[UserInfoKey.activationStatus] as? WCSessionActivationState
            else { return }

        print("\(#function): activationState:\(activationStatus.rawValue)")
    }
    
    // .reachabilityDidChange notification handler.
    //
    @objc func reachabilityDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any],
            let isReachable = userInfo[UserInfoKey.reachable] as? Bool else { return }
        
        print("\(#function): isReachable:\(isReachable)")
    }
    
    @IBAction func buttonAction() {
        SessionCoordinator.shared.send(dataProvider: self, channel: channel)
    }
}
