import Foundation


import SwiftUI

import SwiftUI

class DemoExpirationViewModel: ObservableObject {
    @Published var message: String = ""
    @Published var isSubscribed: Bool = false
    @Published var timeUntilExpiration: TimeInterval = 0
    
    private var timer: Timer?
    
    init() {
        updateMessage()
        checkSubscriptionStatus()
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func updateMessage() {
        let message = DemoExpirationManager.shared.getMessage()
        self.message = message
    }
    
    func checkSubscriptionStatus() {
        let isSubscribed = DemoExpirationManager.shared.hasValidSubscription()
        self.isSubscribed = isSubscribed
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let installationDate = DemoExpirationManager.shared.installationDate else {
                return
            }
            
            let currentDate = Date()
            let expirationDate = Calendar.current.date(byAdding: .day, value: 3, to: installationDate) ?? currentDate
            
            let timeUntilExpiration = expirationDate.timeIntervalSince(currentDate)
            self?.timeUntilExpiration = max(timeUntilExpiration, 0)
            
            print("Time until demo expired: \(timeUntilExpiration)")
        }
    }
}

class DemoExpirationManager {
    static let shared = DemoExpirationManager()
    
    private let installationDateKey = "InstallationDate"
    
    var installationDate: Date? {
        get {
            if let loadedDate = KeychainService.loadDate(forKey: installationDateKey) {
                // Called every second until demo expired
         //       print("Installation date loaded: \(loadedDate)")
                return loadedDate
            } else {
                print("No installation date found. Setting installation date.")
                let currentDate = Date()
                KeychainService.saveDate(value: currentDate, forKey: installationDateKey)
                print("Installation date set to current date: \(currentDate)")
                return currentDate
            }
        }
        set {
            if let newValue = newValue {
                print("Installation date set: \(newValue)")
                KeychainService.saveDate(value: newValue, forKey: installationDateKey)
            } else {
                print("Installation date deleted.")
                KeychainService.deleteValue(forKey: installationDateKey)
            }
        }
    }
    
    // Set the installation date if needed
    func setInstallationDateIfNeeded() {
        _ = installationDate
    }
    
    // Check if the demo period is expired
    func isDemoPeriodExpired() -> Bool {
        guard let installationDate = installationDate else {
            print("Installation date is nil.")
            return true
        }
        
        let currentDate = Date()
        let calendar = Calendar.current
        let expirationDate = calendar.date(byAdding: .day, value: 30, to: installationDate) // Assuming a 30-day trial
        
        if let expirationDate = expirationDate {
            print("Expiration date calculated: \(expirationDate)")
            return currentDate >= expirationDate
        } else {
            print("Failed to calculate expiration date.")
            return true
        }
    }
    
    // Check if there is a valid subscription
    func hasValidSubscription() -> Bool {
        // Implement logic to check subscription validity from Apple service
        // You might need to use StoreKit framework or interact with your server to validate subscriptions
        // For the sake of this example, let's return false
        let isValidSubscription = false
        if isValidSubscription {
            print("User has a valid subscription.")
        } else {
            print("User does not have a valid subscription.")
        }
        return isValidSubscription
    }
    
    // Get the appropriate message based on subscription status
    func getMessage() -> String {
        if hasValidSubscription() {
            return "Your subscription is active. Enjoy the full version!"
        } else {
            if isDemoPeriodExpired() {
                return "Your demo period has expired. Please subscribe to unlock full features."
            } else {
                return "You are currently in the demo period. Enjoy using the app!"
            }
        }
    }
}
