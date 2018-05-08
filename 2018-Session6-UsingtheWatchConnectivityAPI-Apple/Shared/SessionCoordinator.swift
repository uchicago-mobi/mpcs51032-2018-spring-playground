/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The session coordinator calss, containing most of the Watch Connectivity related code,
  including the implemtention of the WCSessionDelegate methods, used on both iOS and watchOS.
 */

import UIKit
import WatchConnectivity

// Custom notifications.
// Posted when Watch Connectivity activation or reachibility status is changed,
// or when data is received or sent. Clients observe these notifications to update the UI.
//
extension Notification.Name {
    static let dataDidFlow = Notification.Name("DataDidFlow")
    static let activationDidComplete = Notification.Name("ActivationDidComplete")
    static let reachabilityDidChange = Notification.Name("ReachabilityDidChange")
}

// Constants to organize and access the information in the notication userInfo dictionary.
//
struct UserInfoKey {
    static let channel = "Channel"
    static let phrase = "Phrase"
    static let timedColor = "timedColor"
    static let error = "Error"
    static let activationStatus = "ActivationStatus"
    static let reachable = "Reachable"
    static let fileURL = "fileURL"
}

// Constants to identify the Watch Connectivity methods, also used as user-visible strings in UI.
//
enum Channel: String {
    case updateAppContext = "UpdateAppContext"
    case sendMessage = "SendMessage"
    case sendMessageData = "SendMessageData"
    case transferUserInfo = "TransferUserInfo"
    case transferFile = "TransferFile"
    case transferCurrentComplicationUserInfo = "TransferCurrentComplicationUserInfo"
}

// Constants to identify the phrases of a Watch Connectivity communication,
// also shown in the logs on the iOS side.
//
enum Phrase: String {
    case updated = "Updated"
    case sent = "Sent"
    case received = "Received"
    case replied = "Replied"
    case transferring = "Transferring"
    case finished = "Finished"
    case failed = "Failed"
}

// Constants to identify the app group container used for Settings-Watch.bundle and access
// the information in Settings-Watch.bundle.
//
struct AppGroupContainerKey {
    static let identifier = "" // Specify your group container ID here to make watch settings work.
    static let clearLogsAfterTransferred = "clearLogsAfterTransferred"
}

// A singleton class that wraps Watch Connectivity APIs and briges Watch Connectivity and UI.
// It accepts data from SessionDataProvider, handles the communication, and notifies clients
// when WCSession status changes or data flows. Shared by the iOS app and watchOS app.
//
class SessionCoordinator: NSObject {
    
    static let shared = SessionCoordinator()
    
    // private: prevent clients from creating another instance.
    //
    private override init() {
        super.init()
        assert(WCSession.isSupported(), "This sample requires a platform supporting Watch Connectivity!")
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // Update app context
    //
    private func updateAppContext(dataProvider: SessionDataProvider) -> [String: Any] {
        let payload = dataProvider.appContext

        var userInfo: [String: Any] = [UserInfoKey.channel: Channel.updateAppContext,
                                       UserInfoKey.timedColor: payload,
                                       UserInfoKey.phrase: Phrase.updated]
        do {
            try WCSession.default.updateApplicationContext(payload)
        }
        catch {
            userInfo[UserInfoKey.error] = error.localizedDescription
        }
        
        return userInfo
    }
    
    // Send a message immdediately.
    //
    private func sendMessage(dataProvider: SessionDataProvider) -> [String: Any] {
        let payload = dataProvider.message

        var userInfo: [String: Any] = [UserInfoKey.channel: Channel.sendMessage,
                                       UserInfoKey.timedColor: payload,
                                       UserInfoKey.phrase: Phrase.sent]
        
        WCSession.default.sendMessage(payload, replyHandler: { replyMessage in
            
            userInfo[UserInfoKey.timedColor] = replyMessage
            userInfo[UserInfoKey.phrase] = Phrase.replied
            self.postNotificationOnMainQueue(name: .dataDidFlow, userInfo: userInfo)
            
        }, errorHandler: { error in
            userInfo[UserInfoKey.error] = error.localizedDescription
            self.postNotificationOnMainQueue(name: .dataDidFlow, userInfo: userInfo)
        })
        
        return userInfo
    }

    // Send a piece of message data immediately
    //
    private func sendMessageData(dataProvider: SessionDataProvider) -> [String: Any] {
        var userInfo: [String: Any] = [UserInfoKey.channel: Channel.sendMessageData,
                                       UserInfoKey.phrase: Phrase.sent]
        
        let payload = dataProvider.messageData

        let data = NSKeyedUnarchiver.unarchiveObject(with: payload)
        if let timedColor = data as? [String: Any] {
            userInfo[UserInfoKey.timedColor] = timedColor
        }
        
        WCSession.default.sendMessageData(payload, replyHandler: { replyData in
            
            let data = NSKeyedUnarchiver.unarchiveObject(with: replyData)
            if let timedColor = data as? [String: Any] {
                userInfo[UserInfoKey.timedColor] = timedColor
            }
            userInfo[UserInfoKey.phrase] = Phrase.replied
            self.postNotificationOnMainQueue(name: .dataDidFlow, userInfo: userInfo)
            
        }, errorHandler: { error in
            
            userInfo[UserInfoKey.error] = error.localizedDescription
            self.postNotificationOnMainQueue(name: .dataDidFlow, userInfo: userInfo)
        })
        
        return userInfo
    }
    
    // Transfer a piece of user info
    // a WCSessionUserInfoTransfer object is returned to monitor the progress or cancel the operation.
    //
    private func transferUserInfo(dataProvider: SessionDataProvider) -> [String: Any] {
        let payload = dataProvider.userInfo
        WCSession.default.transferUserInfo(payload)
        
        return [UserInfoKey.channel: Channel.transferUserInfo,
                UserInfoKey.timedColor: payload,
                UserInfoKey.phrase: Phrase.transferring]
    }
    
    // Transfer a file.
    // A WCSessionFileTransfer object is returned to monitor the progress or cancel the operation.
    //
    private func transferFile(dataProvider: SessionDataProvider) -> [String: Any] {
        let metadata = dataProvider.fileMetaData
        WCSession.default.transferFile(dataProvider.file, metadata: metadata)
        
        return [UserInfoKey.channel: Channel.transferFile,
                UserInfoKey.timedColor: metadata,
                UserInfoKey.phrase: Phrase.transferring]
    }
    
    // Transfer a piece fo user info for current complications
    // a WCSessionUserInfoTransfer object is returned to monitor the progress or cancel the operation.
    //
    private func transferCurrentComplicationUserInfo(dataProvider: SessionDataProvider) -> [String: Any] {
        let payload = dataProvider.currentComplicationInfo
        
        var userInfo: [String: Any] = [UserInfoKey.channel: Channel.transferCurrentComplicationUserInfo,
                                       UserInfoKey.timedColor: payload,
                                       UserInfoKey.phrase: Phrase.failed,
                                       UserInfoKey.error: "Not supported on watchOS!"]
        #if os(iOS)
            userInfo[UserInfoKey.error] = "\nComplication is not enabled!"
            
            if WCSession.default.isComplicationEnabled {
                WCSession.default.transferCurrentComplicationUserInfo(payload)
                
                userInfo[UserInfoKey.phrase] = Phrase.transferring
                userInfo[UserInfoKey.error] = nil // Clear the default value.
            }
        #endif
        return userInfo
    }
    
    // Post a notification on the main thread asynchronously.
    //
    func postNotificationOnMainQueue(name: NSNotification.Name, object: Any? = nil,
                                                 userInfo: [AnyHashable : Any]? = nil) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
        }
    }
    
    // Send data provided by the passed-in data provider to the paired peer, and post a notfication
    // for client to update the UI
    // For sendMessage and sendMessageData, post a notification when the data is sent, then another
    // one when the data is replied or an error occurs.
    //
    func send(dataProvider: SessionDataProvider, channel: Channel) {
        
        guard WCSession.default.activationState == .activated else {
            let userInfo: [String: Any] = [UserInfoKey.channel: channel,
                                           UserInfoKey.error: "WCSession is not activeted yet!",
                                           UserInfoKey.phrase: Phrase.failed]
            postNotificationOnMainQueue(name: .dataDidFlow, userInfo: userInfo)
            return
        }
        
        // Use the specified channel to send the data. Fill the notification user info at the same time.
        //
        let userInfo: [String: Any]

        switch channel {
        case .updateAppContext:
            userInfo = updateAppContext(dataProvider: dataProvider)
            
        case .sendMessage:
            userInfo = sendMessage(dataProvider: dataProvider)
            
        case .sendMessageData:
            userInfo = sendMessageData(dataProvider: dataProvider)
            
        case .transferUserInfo:
            userInfo = transferUserInfo(dataProvider: dataProvider)
            
        case .transferFile:
            userInfo = transferFile(dataProvider: dataProvider)
            
        case .transferCurrentComplicationUserInfo:
            userInfo = transferCurrentComplicationUserInfo(dataProvider: dataProvider)
        }
        
        postNotificationOnMainQueue(name: .dataDidFlow, userInfo: userInfo)
    }
}
