import Foundation
import Cocoa

class ConfigWindowController: NSWindowController {
    @IBOutlet weak var pathTextField: NSTextField!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        pathTextField.stringValue = Config.manager.destination
    }
    
    @IBAction func selectPath(sender: AnyObject) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        
        panel.beginWithCompletionHandler { (result) in
            if result == NSFileHandlingPanelOKButton {
                guard let url = panel.URL else {
                    return
                }
                self.pathTextField.stringValue = url.path!
            }
        }
    }
    
    @IBAction func apply(sender: AnyObject) {
        Config.manager.destination = pathTextField.stringValue
        window!.close()
    }
    
    @IBAction func cancel(sender: AnyObject) {
        window!.close()
    }
}