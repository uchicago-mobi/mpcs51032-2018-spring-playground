# Watch Connectivity Sample
Demonstrates how to implement the two-way communication between an Apple Watch and its paired iPhone using the Watch Connectivity framework.

## Overview
Exchanging data between an Apple Watch and its paired iPhone is required for most of watch apps. This sample demonstrates how to use Watch Connectivity APIs to:

- Update application contexts
- Send messages
- Transfer user info
- Transfer files
- Update current complications from iOS apps
- Handle Watch Connectivity background tasks

Most of these tasks are straightforward and are implemented in the [`SessionCoordinator`](Shared/SessionCoordinator.swift) class, which is used in both the iOS app and the WatchKit extension. The payload transferred across the devices is a dictionary containing a timestamp and a random color, which are displayed on the UI of both sender and receiver.

In your real apps, be sure to choose the right API based on how your data should be delivered. An application context is stateless, meaning that a new context, once being set, will overwrite the previous one; user info is different in that they will be queued up and delivered in the order they were sent in, and that the transfer can be monitored or cancelled using [`WCSessionUserInfoTransfer`](https://developer.apple.com/reference/watchconnectivity/wcsessionuserinfotransfer); a message, once being sent, will be delivered immediately if the peer is [`reachable`](https://developer.apple.com/reference/watchconnectivity/wcsession/1615683-isreachable), otherwise an error will be returned via the error handler.

## Update current complications from iOS apps

To update current complications, we use WCSession's
[`transferCurrentComplicationUserInfo`](https://developer.apple.com/reference/watchconnectivity/wcsession/1615639-transfercurrentcomplicationuseri) method on the iOS side to transfer data to the watch, then call CLKComplicationServer's [`reloadTimeline`](https://developer.apple.com/reference/clockkit/clkcomplicationserver/1627891-reloadtimeline) method on the watchOS side to trigger the update. The complication, if being current and still having execution time, will then show a new random number.

## Handle Watch Connectivity background tasks
Watch Connectivity background tasks have to be completed after the data is received, as mentioned in the Note section of [`WKWatchConnectivityRefreshBackgroundTask`](https://developer.apple.com/reference/watchkit/wkwatchconnectivityrefreshbackgroundtask) API Reference. This sample follows the suggestion by retaining the tasks in an array and completing them when the session is activated and the [`hasContentPending`](https://developer.apple.com/reference/watchconnectivity/wcsession/1648961-hascontentpending) property is false.

Debugging background tasks is a bit tricky because they are mostly triggered when the watch app is suspended, which won't happen if the watch app is launched by the Xcode debugger. For debugging purpose,  we created the [`FileLogger`](Shared/FileLogger.swift) class to write debug information into a log file, which can be transferred to the iOS app by tapping the transferFile button on the watch app. To clear the logs (or not), this sample also provides a watch setting bundle, which can be seen on the SimpleWatchConnectivity setting page in the iOS watch app.

## Get Started

**Run the sample on your devices**
Running this sample on your devices is really important because the simulators behave quite differently from real devices when receiving complication updates and handling background tasks. To do that, you need to change the bundle IDs so that the apps can be correctly provisioned in your environment. Here are the steps:

1. Open this sample with the latest version of Xcode, select the “SimpleWatchConnectivity” target, change the bundle ID to &lt;Your iOS app bundle ID&gt;, and select the right team to let Xcode automatically manage your provisioning profile. See   [`QA1814`](https://developer.apple.com/library/content/qa/qa1814/_index.html#//apple_ref/doc/uid/DTS40014030) for details.
2. Do the same thing for the WatchKit app and WatchKit Extension target. The bundle IDs should be &lt;Your iOS app bundle ID&gt;.watchkitapp and &lt;Your iOS app bundle ID&gt;.watchkitapp.watchkitextension respectively.
3. Open the Info.plist of the WatchKit app target, change the value of WKCompanionAppBundleIdentifier key to &lt;Your iOS app bundle ID&gt;.
4. Open the Info.plist of the WatchKit Extension target, change the value of NSExtension > NSExtensionAttributes > WKAppBundleIdentifier key to &lt;Your iOS app bundle ID&gt;.watchkitapp.
5. Open Root.plist of Settings-Watch.bundle and set the value of ApplicationGroupContainerIdentifier key to your group container. Follow the steps described in the   [`Settings`](https://developer.apple.com/library/content/documentation/General/Conceptual/WatchKitProgrammingGuide/Settings.html#//apple_ref/doc/uid/TP40014969-CH22-SW1) section to set up the group container.
6. Open the [`SessionCoordinator`](Shared/SessionCoordinator.swift) class and change the value of AppGroupContainerKey.identifier to your group container ID.

Now you should be able to make a clean build and run the apps on your devices. Restart the devices to make sure everything is clean if you see anything unexpected.

**Make the complication current on your Apple Watch**
The complication implemented in this sample only supports the Modular Large (tall body) family and shows a random number for the current timeline entry. Use these steps to make the complication current:
1. Choose a Modular watch face on your watch.
2. Deep press to get to the customization screen, tap the Customize button, then swipe right to get to the complications configuration screen and tap the tall body area.
3. Rotate the digital crown to choose the SimpleWatchConnectivity complication.
4. Press the digital crown and tap the screen to go back to the watch face.

Once the complication is current, you can tap the transferCurrentComplicationUserInfo button on the iOS app and see the update on the watch face if the execution time is still under budget.
