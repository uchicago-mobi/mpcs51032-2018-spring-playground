/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The session coordinator calss extension, containing the implemtention of the WCSessionDelegate methods,
  used on both iOS and watchOS.
 */

import Foundation
import WatchConnectivity

#if os(watchOS)
    import ClockKit
#endif

// Implement WCSessionDelegate methods to receive Watch Connectivity data and notify clients.
// WCsession status changes are also handled here.
//
extension SessionCoordinator: WCSessionDelegate {
    
    // Called when WCSession activation state is changed.
    //
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        let userInfo: [String : Any] = [UserInfoKey.activationStatus: activationState]
        postNotificationOnMainQueue(name: .activationDidComplete, userInfo: userInfo)
    }
    
    // Called when WCSession reachability is changed.
    //
    func sessionReachabilityDidChange(_ session: WCSession) {
        let userInfo: [String : Any] = [UserInfoKey.reachable: session.isReachable]
        postNotificationOnMainQueue(name: .reachabilityDidChange, userInfo: userInfo)
    }
    
    // Called when an app context is received.
    //
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        let userInfo: [String : Any] = [UserInfoKey.channel: Channel.updateAppContext,
                                        UserInfoKey.phrase: Phrase.received,
                                        UserInfoKey.timedColor: applicationContext]
        postNotificationOnMainQueue(name: .dataDidFlow, userInfo: userInfo)
    }
    
    // Called when a message is received and the peer doesn't need a response.
    //
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        let userInfo: [String : Any] = [UserInfoKey.channel: Channel.sendMessage,
                                        UserInfoKey.phrase: Phrase.received,
                                        UserInfoKey.timedColor: message]
        postNotificationOnMainQueue(name: .dataDidFlow, userInfo: userInfo)
    }
    
    // Called when a message is received and the peer needs a response.
    //
    func session(_ session: WCSession, didReceiveMessage message: [String : Any],
                 replyHandler: @escaping ([String : Any]) -> Void) {
        self.session(session, didReceiveMessage: message)
        replyHandler(message) // Echo back the time stamp.
    }
    
    // Called when a piece of message data is received and the peer doesn't need a response.
    //
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        var userInfo: [String : Any] = [UserInfoKey.channel: Channel.sendMessageData,
                                        UserInfoKey.phrase: Phrase.received]
        
        let data = NSKeyedUnarchiver.unarchiveObject(with: messageData)
        if let timedColor = data as? [String: Any] {
            userInfo[UserInfoKey.timedColor] = timedColor
        }
        else {
            userInfo[UserInfoKey.error] = "Invalid timed color!"
        }
        postNotificationOnMainQueue(name: .dataDidFlow, userInfo: userInfo)
    }
    
    // Called when a piece of message data is received and the peer needs a response.
    //
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        self.session(session, didReceiveMessageData: messageData)
        replyHandler(messageData) // Echo back the time stamp.
    }
    
    // Called when a userInfo is received.
    //
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        var channel: Channel = .transferUserInfo
        
        if let isComplicationInfo = userInfo[PayloadKey.isCurrentComplicationInfo] as? Bool, isComplicationInfo {
            channel = .transferCurrentComplicationUserInfo
            
            #if os(watchOS)
                let server = CLKComplicationServer.sharedInstance()
                if let complications = server.activeComplications {
                    for complication in complications {
                        //Call this method sparingly. If your existing complication data is still valid,
                        //consider calling the extendTimeline(for:) method instead.
                        server.reloadTimeline(for: complication)
                    }
                }
            #endif
        }
        
        let myUserInfo: [String : Any] = [UserInfoKey.channel: channel,
                                          UserInfoKey.phrase: Phrase.received,
                                          UserInfoKey.timedColor: userInfo]
        postNotificationOnMainQueue(name: .dataDidFlow, userInfo: myUserInfo)
    }
    
    // Called when sending a userInfo is done.
    //
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        var channel: Channel = .transferUserInfo
        
        #if os(iOS)
            if userInfoTransfer.isCurrentComplicationInfo {
                channel = .transferCurrentComplicationUserInfo
            }
        #endif
        
        var userInfo: [String : Any] = [UserInfoKey.channel: channel,
                                        UserInfoKey.phrase: Phrase.finished,
                                        UserInfoKey.timedColor: userInfoTransfer.userInfo]
        if let error = error {
            userInfo[UserInfoKey.error] = error.localizedDescription
        }
        postNotificationOnMainQueue(name: .dataDidFlow, userInfo: userInfo)
    }
    
    // Called when a file is received.
    //
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        var userInfo: [String : Any] = [UserInfoKey.channel: Channel.transferFile,
                                        UserInfoKey.phrase: Phrase.received,
                                        UserInfoKey.fileURL: file.fileURL]
        
        if let fileMetadata = file.metadata {
            userInfo[UserInfoKey.timedColor] = fileMetadata
        }
        
        // Note that WCSessionFile.fileURL will be removed once this method returns,
        // so instead of calling postNotificationOnMainQueue(name: .dataDidFlow, userInfo: userInfo),
        // we dispatch to main queue SYNCHRONOUSLY.
        //
        DispatchQueue.main.sync {
            NotificationCenter.default.post(name: .dataDidFlow, object: nil, userInfo: userInfo)
        }
    }
    
    // Called when a file transfer is done.
    //
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        var userInfo: [String : Any] = [UserInfoKey.channel: Channel.transferFile,
                                        UserInfoKey.phrase: Phrase.finished]
        
        if let fileMetadata = fileTransfer.file.metadata {
            userInfo[UserInfoKey.timedColor] = fileMetadata
        }
        
        if let error = error {
            userInfo[UserInfoKey.error] = error.localizedDescription
        }
        else {

            if AppGroupContainerKey.identifier.isEmpty {
                print("To use watch settings, specify a group container in AppGroupContainerKey (SessionCoordinator.swift)!")
            }
            else {
                let defaults = UserDefaults(suiteName: AppGroupContainerKey.identifier)
                if let enabled = defaults?.bool(forKey: AppGroupContainerKey.clearLogsAfterTransferred), enabled {
                    FileLogger.shared.clearLogs()
                }
            }
        }
        postNotificationOnMainQueue(name: .dataDidFlow, userInfo: userInfo)
    }
    
    // WCSessionDelegate methods for iOS only.
    //
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Activate the new session after having switched to a new watch.
        session.activate()
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
#endif
}
