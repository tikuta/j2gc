import Cocoa
import Foundation
import Just

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    let wc = ConfigWindowController(windowNibName: "ConfigWindow")

    let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button!.image = NSImage(named: "StatusBarButtonImage")
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Capture", action: #selector(capture), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Config", action: #selector(config), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem.menu = menu
        
        NSUserNotificationCenter.default.delegate = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func capture(_ sender: AnyObject) {
        let fileManager = FileManager.default
        
        let destDir = Config.manager.destination.characters.count != 0 ? Config.manager.destination : NSTemporaryDirectory()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let basename = formatter.string(from: Date())
        
        var destPath = (destDir as NSString).appendingPathComponent(String(format: "%@.png", basename))
        var counter: Int = 0
        while fileManager.fileExists(atPath: destPath) {
            destPath = (destDir as NSString).appendingPathComponent(String(format: "%@_%d.png", basename, counter))
            counter += 1
        }
        
        do {
            try fileManager.createDirectory(atPath: destDir, withIntermediateDirectories: true, attributes: nil)
        } catch let e as NSError {
            NSAlert(error: e).runModal()
            return
        }
        
        Process.launchedProcess(launchPath: "/usr/sbin/screencapture", arguments: ["-i", destPath]).waitUntilExit()
        
        if fileManager.fileExists(atPath: destPath) {
            notify(destPath)
        }
    }
    
    func notify(_ path: String) {
        let notification = NSUserNotification()
        notification.title = "j2gc"
        switch Config.manager.behavior {
        case .Upload:
            notification.informativeText = "Click to upload the image to gyazo.com"
        case .Copy:
            notification.informativeText = "Click to copy the image to clipboard"
        }
        notification.userInfo = ["path": path]
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func upload(_ path: String) {
        let r = Just.post("https://upload.gyazo.com/upload.cgi",
                  data: ["filename": (path as NSString).lastPathComponent],
                  files: ["imagedata": .url(URL.init(fileURLWithPath: path), nil)])
        
        if let e = r.error {
            NSAlert(error: e).runModal()
            return
        }
        
        let url = Config.manager.rawSuffix ? URL.init(string: r.text!)?.appendingPathComponent("raw") : URL.init(string: r.text!)
        NSPasteboard.general().clearContents()
        NSPasteboard.general().setString(url!.absoluteString, forType: NSPasteboardTypeString)
    }
    
    func copy(_ path: String) {
        let image = NSImage(contentsOfFile: path)!
        NSPasteboard.general().clearContents()
        NSPasteboard.general().writeObjects([image])
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        let userInfo = notification.userInfo as! [String: String]
        
        switch Config.manager.behavior {
        case .Upload:
            upload(userInfo["path"]!)
        case .Copy:
            copy(userInfo["path"]!)
        }
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    func config(_ sender: AnyObject) {
        wc.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func quit(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
}

