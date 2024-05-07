//
//  ExpirationManager.swift
//  Simple Spin
//
//  Created by Benjamin  Dai on 5/7/24.
//

import Foundation

class ExpirationManager {
    //    static let shared = DemoExpirationManager()
//    static let shared = DemoExpirationManager(isSubscribed: true)
    
    // Change to SimulatedExpirationManager for no demo expire and active subscription
    #if DEBUG
    static let shared = SimulatedExpirationManager()
    #else
    static let shared = DemoExpirationManager(isSubscribed: false)
    #endif
    
    init(isSubscribed: Bool = false) {
    }
    
    func setInstallationDateIfNeeded() {
    }
    
    func isDemoPeriodExpired() -> Bool {
            return false
    }
   
    func setSubscription(isSubscribed: Bool = false) {
    }
    
    func hasValidSubscription() -> Bool {
            return true
    }
    
    
    func getMessageAndExpirationDate() -> (String, String, Bool) {
        return ("ExpirationManager message and expiration date", "Today", false)
    }
    
    func demoExpirationDate() -> String {
      return "ExpirationManager: N/A"
    }
}
