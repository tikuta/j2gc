import Foundation
import Cocoa

class ConfigWindowController: NSWindowController {
    @IBOutlet weak var pathTextField: NSTextField!
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var rawSuffixCheckBox: NSButton!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        pathTextField.stringValue = Config.manager.destination
        rawSuffixCheckBox.state = Config.manager.rawSuffix ? NSOnState : NSOffState
        
        let attr = [NSForegroundColorAttributeName: NSColor.blueColor(),
                    NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
                    NSLinkAttributeName: "https://github.com/tikuta/j2gc/blob/master/components.md"]
        infoLabel.attributedStringValue = NSAttributedString.init(string: "Info", attributes: attr)
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
        Config.manager.rawSuffix = rawSuffixCheckBox.state == NSOnState ? true : false
        window!.close()
    }
    
    @IBAction func cancel(sender: AnyObject) {
        window!.close()
    }
}