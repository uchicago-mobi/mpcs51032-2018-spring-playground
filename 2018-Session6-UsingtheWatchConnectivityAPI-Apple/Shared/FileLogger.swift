/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 FileLogger is a debug utility, used to write logs into a log file.
 */

import Foundation

// FileLogger is a debug utility, used to write logs into a log file.
// WKWatchConnectivityRefreshBackgroundTask is mostly triggered when the watch app is in the background
// and background task budget is limited, we hence can't use Xcode debugger to attach the process.
// Mostly for debug purpose, the class writes logs into a file. Clients thus can tranfer the log file
// and view it on iOS side.
// FileLogger is not thread safe. In this sample, we only write synchronously on watchOS side,
// and read synchronously on iOS side.
//
class FileLogger {
    
    static let shared = FileLogger()
    private var fileHandle: FileHandle!
    
    // Return folder URL, create it if not existing yet.
    // Return nil to trigger a crash if the folder creation fails.
    // Not using lazy because we need to recreate when clearLogs is called.
    //
    private var _folderURL: URL?
    private var folderURL: URL! {
        guard _folderURL == nil else { return _folderURL }
        
        var folderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        folderURL.appendPathComponent("Logs")
        print(folderURL)
      
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            do {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            }
            catch {
                print("Failed to create the log folder: \(folderURL)! \n\(error)")
                return nil // To trigger crash.
            }
        }
        _folderURL = folderURL
        return folderURL
    }
    
    // Return file URL, create it if not existing yet.
    // Return nil to trigger a crash if the file creation fails.
    // Not using lazy because we need to recreate when clearLogs is called.
    //
    private var _fileURL: URL?
    var fileURL: URL! {
        guard _fileURL == nil else { return _fileURL }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateString = dateFormatter.string(from: Date())
    
        var fileURL: URL = self.folderURL
        fileURL.appendPathComponent("\(dateString).log")
        
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            if !FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil) {
                print("Failed to create the log file: \(fileURL)!")
                return nil // To trigger crash.
            }
        }
        _fileURL = fileURL
        return fileURL
    }
    
    // Avoid creating DateFormatter for time stamp as FileLogger may count into execution budget.
    //
    private lazy var timeStampFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()
    
    private init() {
        fileHandle = try? FileHandle(forUpdating: fileURL)
        assert(fileHandle != nil, "Failed to create the file handle!")
    }
    
    // Append a line of text to the end of the file.
    // Use FileHandle so that we can see to the end directly.
    //
    func append(line: String) {
        let timeStamp = timeStampFormatter.string(from: Date())
        let timedLine = timeStamp + ": " + line + "\n"
        
        if let data = timedLine.data(using: .utf8) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
        }
    }
    
    // Read the file content and return it as a string.
    //
    func content() -> String {
        fileHandle.seek(toFileOffset: 0) // Read from the very beginning.
        return String(data: fileHandle.availableData, encoding: .utf8) ?? ""
    }
    
    // Clear logs. Reset the folder and file URL for later use.
    //
    func clearLogs() {
        fileHandle.closeFile()
        do {
            try FileManager.default.removeItem(at: folderURL)
        }
        catch {
            print("Failed to clear the log folder!\n\(error)")
        }
        
        // Create a new file handle.
        //
        _folderURL = nil
        _fileURL = nil
        fileHandle = try? FileHandle(forUpdating: fileURL)
        assert(fileHandle != nil, "Failed to create the file handle!")
    }
}
