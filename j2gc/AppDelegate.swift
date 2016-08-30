import Cocoa
import Foundation
import Just

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    let wc = ConfigWindowController(windowNibName: "ConfigWindow")

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItem.button!.image = NSImage(named: "StatusBarButtonImage")
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Capture", action: #selector(capture), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Config", action: #selector(config), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem.menu = menu
        
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func capture(sender: AnyObject) {
        let fileManager = NSFileManager.defaultManager()
        
        let destDir = Config.manager.destination.characters.count != 0 ? Config.manager.destination : NSTemporaryDirectory()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let basename = formatter.stringFromDate(NSDate())
        
        var destPath = (destDir as NSString).stringByAppendingPathComponent(String(format: "%@.png", basename))
        var counter: Int = 0
        while fileManager.fileExistsAtPath(destPath) {
            destPath = (destDir as NSString).stringByAppendingPathComponent(String(format: "%@_%d.png", basename, counter))
            counter += 1
        }
        
        do {
            try fileManager.createDirectoryAtPath(destDir, withIntermediateDirectories: true, attributes: nil)
        } catch let e as NSError {
            let alert = NSAlert(error: e)
            alert.runModal()
            return
        }
        
        NSTask.launchedTaskWithLaunchPath("/usr/sbin/screencapture", arguments: ["-i", destPath]).waitUntilExit()
        
        if fileManager.fileExistsAtPath(destPath) {
            notify(destPath)
        }
    }
    
    func notify(path: String) {
        let notification = NSUserNotification()
        notification.title = "j2gc"
        notification.informativeText = "Click to upload the image to gyazo.com"
        notification.userInfo = ["path": path]
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }
    
    func upload(path: String) {        
        let r = Just.post("https://upload.gyazo.com/upload.cgi",
                  data: ["filename": (path as NSString).lastPathComponent],
                  files: ["imagedata": .URL(NSURL.init(fileURLWithPath: path), nil)])
        
        if let e = r.error {
            NSAlert(error: e).runModal()
            return
        }
        
        NSPasteboard.generalPasteboard().clearContents()
        NSPasteboard.generalPasteboard().setString(r.text!, forType: NSPasteboardTypeString)
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        let userInfo = notification.userInfo as! [String: String]
        upload(userInfo["path"]!)
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
    func config(sender: AnyObject) {
        wc.showWindow(nil)
        NSApp.activateIgnoringOtherApps(true)
    }
    
    func quit(sender: AnyObject) {
        NSApp.terminate(self)
    }
}

