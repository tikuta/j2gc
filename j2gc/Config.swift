import Foundation

enum BehaviorOnNotificationClick: Int {
    case Upload = 10
    case Copy = 20
}

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
    
    var behavior: BehaviorOnNotificationClick {
        get {
            return BehaviorOnNotificationClick(rawValue: defaults.integer(forKey: "behavior")) ?? BehaviorOnNotificationClick.Upload
        }
        set {
            defaults.set(newValue.rawValue, forKey: "behavior")
        }
    }
}
