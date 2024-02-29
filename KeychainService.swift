import Foundation
import Security

class KeychainService {
    static let shared = KeychainService() // Shared instance
    
    private init() {} // Private initializer to prevent creating multiple instances
    
    func setIsSubscribed(_ isSubscribed: Bool) {
        if isSubscribed {
            saveDate(value: Date(), forKey: "SubscriptionDate")
        } else {
            deleteValue(forKey: "SubscriptionDate")
        }
    }
    
    func getSubscriptionDate() -> Date? {
        let subscriptionDate = loadDate(forKey: "SubscriptionDate")
               if let date = subscriptionDate {
                   print("Subscription Date: \(date)")
               } else {
                   print("Subscription Date: Not set")
               }
               return subscriptionDate
    }
    
    func isSubscribed() -> Bool {
           return getSubscriptionDate() != nil
       }
    
    public func saveDate(value: Date, forKey key: String) {
        guard let data = value.toString().data(using: .utf8) else {
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("Failed to save date to Keychain")
            return
        }
    }
    
    public func deleteValue(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    public func loadDate(forKey key: String) -> Date? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        
        return Date(fromString: String(data: data, encoding: .utf8) ?? "")
    }
}

extension Date {
    init?(fromString dateString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        if let date = dateFormatter.date(from: dateString) {
            self = date
        } else {
            return nil
        }
    }
    
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return dateFormatter.string(from: self)
    }
}
