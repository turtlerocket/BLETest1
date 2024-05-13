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
       
        
        #if DEBUG || SANDBOX || DEMOSUBSCRIBE
        debugPrint("KeychainService:  DEBUG or SANDBOX or DEMOSUBSCRIBE" )
        // Debug is 15 minutes for subscription expiration in Keychain; used to check subscription expiration date without going to server
        let newExpirationDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        #else
        // Default subscription duration is 30 days; used to check subscription expiration date without going to server
        let newExpirationDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        #endif
        
        // For debugging, set expiration of subscription to 5 minutes
//        let newExpirationDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date()

        print("Subscription renewed for another round with new expiration date: \(newExpirationDate)")
        
        // Set the global variable of subscription to TRUE
        ExpirationManager.shared.setSubscription(isSubscribed: true)
        
        saveDate(value: newExpirationDate, forKey: "SubscriptionExpiration")

    }
    
    func checkAndUpdateSubscription() {
// TODO: There may be scenarios when the subscription expiration date may be missing, but also subscribed.  Thus, if expirationDate is not set, still check for valid subscription...
        // Retrieve the subscription expiration date; if found, NO NEED to check check server for subscription
        
        guard let expirationDate = getSubscriptionExpiration() else {
            print("Subscription expiration date NOT found. Checking server for valid subscription...")
            
            checkServerSubscription()
            
            return
        }

        
        // Check if the subscription expiration is after the current date
        if expirationDate < Date() {
            print("Subscription expiration date has EXPIRED. Checking server for valid subscription...")

            checkServerSubscription()
            
            
        } else {
            print("Still subscribed based on expiration date: \(expirationDate)")
            
            // TODO: Hack - need to extract all subscription activity to a SubscriptionManager...  this flag controls message of demo expiration
            ExpirationManager.shared.setSubscription(isSubscribed: true)
        }
    }

    // Check Apple Storekit server for active subscription
    public func checkServerSubscription() {

        // Check for a valid subscription using IAPManager
        IAPManager.shared.isSubscriptionValid(for: "standardsubscription1") { isValid in
            if isValid {
                // Update subscription expiration for another 30 days
                self.updateSubscriptionExpiration()
            } else {
                // Subscription is not valid, mark as not subscribed
                self.setIsSubscribed(false)
                print("Subscription is not valid. Marked as not subscribed.")
            }
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
