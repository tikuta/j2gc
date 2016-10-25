import Foundation

class Config {
    fileprivate init() {}
    static let manager = Config()
    
    fileprivate let defaults = UserDefaults.standard
    
    var destination: String {
        get {
            return defaults.string(forKey: "destination") ?? ""
        }
        set {
            defaults.set(newValue, forKey: "destination")
        }
    }
    
    var rawSuffix: Bool {
        get {
            return defaults.bool(forKey: "rawSuffix")
        }
        set {
            defaults.set(newValue, forKey: "rawSuffix")
        }
    }
}
