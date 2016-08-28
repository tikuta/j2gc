import Foundation

class Config {
    private init() {}
    static let manager = Config()
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var destination: String {
        get {
            return defaults.stringForKey("destination") ?? ""
        }
        set {
            defaults.setObject(newValue, forKey: "destination")
        }
    }
}