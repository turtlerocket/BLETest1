import Foundation
import Security

//
// TODO: Add logic that sets Subscription date to 5 minutes (production will be 30 days0.  If 30 days is hit, check for valid subscription.  If not valid, default to demo expiration date.  If expired, indicate Demo expired.  Need to press Subscribe now.

class KeychainService {
    static let shared = KeychainService() // Shared instance
    
    private init() {} // Private initializer to prevent creating multiple instances
    
    func setIsSubscribed(_ isSubscribed: Bool) {
        
        if isSubscribed {
            print("Setting subscription")

            updateSubscriptionExpiration()
            
        } else {
            print("Removing subscription")

            deleteValue(forKey: "SubscriptionExpiration")
        }
    }
    
    func getSubscriptionExpiration() -> Date? {
        let expirationDate = loadDate(forKey: "SubscriptionExpiration")
        if let date = expirationDate {
            print("Subscription Expiration Date: \(date)")
        } else {
            print("Subscription Expiration Date: Not set")
        }
        return expirationDate
    }
    
    func isSubscribed() -> Bool {
        // Check if the subscription expiration date is set
        return getSubscriptionExpiration() != nil
    }
    
    private func updateSubscriptionExpiration() {
       
        
        let newExpirationDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date()

        print("Subscription renewed for another round with new expiration date: \(newExpirationDate)")
        
//        let newExpirationDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        saveDate(value: newExpirationDate, forKey: "SubscriptionExpiration")

    }
    
    func checkAndUpdateSubscription() {
        // Retrieve the subscription expiration date
            guard let expirationDate = getSubscriptionExpiration() else {
                print("Subscription expiration date not found.")
                return
            }

            // Check if the subscription expiration is after the current date
            if expirationDate < Date() {
                print("Subscription expiration date has expired. Checking for valid subscription...")

                // Check for a valid subscription using IAPManager
                let isSubscriptionValid = IAPManager.shared.isSubscriptionValid(for: "standardsubscription1")

                if isSubscriptionValid {
                    // Update subscription expiration for another 30 days
                    updateSubscriptionExpiration()

                } else {
                    // Subscription is not valid, mark as not subscribed
                    setIsSubscribed(false)
                    print("Subscription is not valid. Marked as not subscribed.")
                }
            } else {
                print("Still subscribed based on expiration date: \(expirationDate)")
                
                // TODO: Hack - need to extract all subscription activity to a SubscriptionManager...  this flag controls message of demo expiration
                DemoExpirationManager.shared.isSubscribed = true
            }
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
