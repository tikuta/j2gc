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
        
        let attr = [NSForegroundColorAttributeName: NSColor.blue,
                    NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
                    NSLinkAttributeName: "https://github.com/tikuta/j2gc/blob/master/components.md"] as [String : Any]
        infoLabel.attributedStringValue = NSAttributedString.init(string: "Info", attributes: attr)
    }
    
    @IBAction func selectPath(_ sender: AnyObject) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        
        panel.begin { (result) in
            if result == NSFileHandlingPanelOKButton {
                guard let url = panel.url else {
                    return
                }
                self.pathTextField.stringValue = url.path
            }
        }
    }
    
    @IBAction func apply(_ sender: AnyObject) {
        Config.manager.destination = pathTextField.stringValue
        Config.manager.rawSuffix = rawSuffixCheckBox.state == NSOnState ? true : false
        window!.close()
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        window!.close()
    }
}
