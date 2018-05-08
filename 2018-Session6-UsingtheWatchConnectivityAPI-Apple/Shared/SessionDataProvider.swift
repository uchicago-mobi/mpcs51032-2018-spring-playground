/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A protocol defining the interface to provide payload for Watch Connectivity APIs,
  and an extension implemented to provide data transferpayload in this sample.
 */

import UIKit

// Constants to access the payload dictionary.
// isCurrentComplicationInfo is used to tell if the userInfo is from transferCurrentComplicationUserInfo
// in session:didReceiveUserInfo: (see WCSessionDelegate).
//
struct PayloadKey {
    static let timeStamp = "timeStamp"
    static let colorData = "colorData"
    static let isCurrentComplicationInfo = "isCurrentComplicationInfo"
}

// Defines the interfaces to provide payload for Watch Connectivity APIs
// ViewController and InterfaceController adopt this protocol to work with SessionCoordinator
//
protocol SessionDataProvider {
    var appContext: [String: Any] { get }
    
    var message: [String: Any] { get }
    var messageData: Data { get }
    
    var userInfo: [String: Any] { get }
    
    var file: URL { get }
    var fileMetaData: [String: Any] { get }
}

// This protocol extension provides an implementation to generate a default payload, which contains
// a random color and a time stamp. ViewController and InterfaceController thus don't need to
// provide their own implementation.
//
extension SessionDataProvider {
    
    // Generate a dictionary containing a time stamp and a random color data
    //
    private func timedColor() -> [String: Any] {
        let red = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let green = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let blue = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        
        let randomColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        let colorData = NSKeyedArchiver.archivedData(withRootObject: randomColor)

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        let timeString = dateFormatter.string(from: Date())
        
        return [PayloadKey.timeStamp: timeString, PayloadKey.colorData: colorData]
    }
    
    // Generate an app context, used as the payload for updateApplicationContext
    //
    var appContext: [String: Any] {
        return timedColor()
    }
    
    // Generate a message, used as the payload for sendMessage.
    //
    var message: [String: Any] {
        return timedColor()
    }
    
    // Generate a message, used as the payload for sendMessageData.
    //
    var messageData: Data {
        return NSKeyedArchiver.archivedData(withRootObject: timedColor())
    }
    
    // Generate a userInfo dictionary, used as the payload for transferUserInfo.
    //
    var userInfo: [String: Any] {
        return timedColor()
    }
    
    // Generate a file URL, used as the payload for transferFile.
    //
    var file: URL {
        return FileLogger.shared.fileURL
    }

    // Generate a file metadata dictionary, used as the payload for transferFile.
    //
    var fileMetaData: [String: Any] {
        return timedColor()
    }
    
    // Generate a complication info dictionary, used as the payload for transferCurrentComplicationUserInfo,
    //
    var currentComplicationInfo: [String: Any] {
        var complicationInfo = timedColor()
        complicationInfo[PayloadKey.isCurrentComplicationInfo] = true
        return complicationInfo
    }
}
