/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The main view controller of the iOS app.
 */

import UIKit
import WatchConnectivity

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SessionDataProvider {
    
    @IBOutlet weak var reachableLabel: UILabel!
    @IBOutlet weak var tableContainerView: UIView!
    @IBOutlet weak var logView: UITextView!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // List the supported methods, shown in the main table.
    //
    let channels: [Channel] = [.updateAppContext, .sendMessage, .sendMessageData,
                                .transferUserInfo, .transferFile, .transferCurrentComplicationUserInfo]
    
    var currentChannel: Channel = .updateAppContext // Use .updateAppContext as the default method.
    var currentColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the gray background color to be easier in design time. Now use white.
        //
        tableContainerView.backgroundColor = .white
        tableView.rowHeight = 42
        
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
    
    // Implement the round corners on the top.
    // Do this here because everything should have been laid out at this moment.
    //
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let layer = CALayer()
        layer.shadowOpacity = 1.0
        layer.shadowOffset = CGSize(width: 0, height: 1)
        
        let path = UIBezierPath(roundedRect: self.tableContainerView.bounds,
                                byRoundingCorners:[.topRight, .topLeft],
                                cornerRadii: CGSize(width: 20, height: 20))
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.white.cgColor
        
        layer.addSublayer(shapeLayer)
        
        tableContainerView.layer.addSublayer(layer)
        tableView.layer.zPosition = layer.zPosition + 1
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Append the message to the end of the text view and make sure it is visiable.
    //
    private func log(_ message: String) {
        logView.text = logView.text! + "\n\n" + message
        logView.scrollRangeToVisible(NSRange(location: logView.text.characters.count, length: 1))
    }
    
    private func updateReachabilityColor() {
        // WCSession.isReachable triggers a warning if the session is not activated.
        //
        var isReachable = false
        if WCSession.default.activationState == .activated {
            isReachable = WCSession.default.isReachable
        }
        reachableLabel.backgroundColor = isReachable ? .green : .red
    }
    
    // .dataDidFlow notification handler.
    // Update the UI based on the userInfo dictionary of the notification.
    //
    @objc func dataDidFlow(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo as? [String: Any],
            let channel = userInfo[UserInfoKey.channel] as? Channel else { return }
        
        // Make sure to hide the note label if the log isn't empty.
        //
        defer {
            noteLabel.isHidden = logView.text.characters.isEmpty ? false: true
        }
        
        currentChannel = channel
        
        // If an error occurs, show the error message and returns.
        //
        if let error = userInfo[UserInfoKey.error] as? String {
            log("! \(channel.rawValue)...\(error)")
            return
        }
        
        // If there is no error, the userInfo should contain a timed color.
        //
        guard let timedColor = userInfo[UserInfoKey.timedColor] as? [String: Any] else { return }
        
        // Format the message and append it on the log view.
        //
        if let timeStamp = timedColor[PayloadKey.timeStamp] as? String,
            let phrase = userInfo[UserInfoKey.phrase] as? Phrase {
            
            log("#\(channel.rawValue)...\n\(phrase.rawValue) at \(timeStamp)")

            if let fileURL = userInfo[UserInfoKey.fileURL] as? URL {

                if let content = try? String(contentsOf: fileURL, encoding: .utf8), !content.isEmpty {
                    log("\(fileURL.lastPathComponent)\n\(content)")
                }
                else {
                    log("\(fileURL.lastPathComponent)\n")
                }
            }
        }
        
        // Get the color data and change the button color by reloading the table.
        //
        if let colorData = timedColor[PayloadKey.colorData] as? Data {
            currentColor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
            tableView.reloadData()
        }
    }
    
    // .activationDidComplete notification handler.
    //
   @objc func activationDidComplete(_ notification: Notification) {
        updateReachabilityColor()
    }
    
    // .reachabilityDidChange notification handler.
    //
    @objc func reachabilityDidChange(_ notification: Notification) {
        updateReachabilityColor()
    }

    @IBAction func clear(_ sender: UIButton) {
        logView.text = ""
    }
    
    // UITableViewDelegate and UITableViewDataSource.
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Basic", for: indexPath)
        cell.textLabel?.text = channels[indexPath.row].rawValue
        cell.textLabel?.textColor = channels[indexPath.row] == currentChannel ? currentColor : nil
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentChannel = channels[indexPath.row]
        SessionCoordinator.shared.send(dataProvider: self, channel: channels[indexPath.row])
    }
}

