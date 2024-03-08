import Foundation


class DemoExpirationViewModel: ObservableObject {
    @Published var message: String = ""
    @Published var isSubscribed: Bool = false
    @Published var demoExpirationDate: String = ""
    @Published var isDemoExpired: Bool = false
    
    private var timer: Timer?
    
    init() {
        updateMessage()
        checkSubscriptionStatus()
        startOrStopTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // This method is called every 5 seconds to check expiration date of demo
    func updateMessage() {
        let (message, expirationDate, isExpired) = DemoExpirationManager.shared.getMessageAndExpirationDate()
        self.message = message
        self.demoExpirationDate = expirationDate
        self.isDemoExpired = isExpired
        
        print("Message updated: \(message)")
         print("Demo expiration date updated: \(expirationDate)")
         print("Demo expired flag updated: \(isExpired)")
        
        // HACK: check if DemoExpirationManager is subscribed, if yes, stop the demo expiration check
        if (DemoExpirationManager.shared.isSubscribed) {
            print("Noticed user is subribed.  Stop further demo expiration checks")
            self.isSubscribed = true
            startOrStopTimer()
        }
    }
    
    func checkSubscriptionStatus() {
  //      let isSubscribed = DemoExpirationManager.shared.hasValidSubscription()
        let isSubscribed = KeychainService.shared.isSubscribed()
        self.isSubscribed = isSubscribed
    }
    
    func startOrStopTimer() {
        if isSubscribed {
            print("Stop periodic demo expired check because SUBSCRIBED.")
            timer?.invalidate()
        } else {
            // Update message and status every 5 seconds
            timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
                self?.updateMessage()
            }
        }
    }
}

import Foundation

class DemoExpirationManager {
//    static let shared = DemoExpirationManager()
//    static let shared = DemoExpirationManager(isSubscribed: true)
    static let shared = DemoExpirationManager(isSubscribed: false)


    private let installationDateKey = "InstallationDate"
    
    var installationDate: Date? {
        get {
            if let loadedDate = KeychainService.shared.loadDate(forKey: installationDateKey) {
                return loadedDate
            } else {
                let currentDate = Date()
                KeychainService.shared.saveDate(value: currentDate, forKey: installationDateKey)
                return currentDate
            }
        }
        set {
            if let newValue = newValue {
                KeychainService.shared.saveDate(value: newValue, forKey: installationDateKey)
            } else {
                KeychainService.shared.deleteValue(forKey: installationDateKey)
            }
        }
    }
    
    public var isSubscribed: Bool
    
    init(isSubscribed: Bool = false) {
        self.isSubscribed = isSubscribed
    }
    
    func setInstallationDateIfNeeded() {
        _ = installationDate
    }
    
    func isDemoPeriodExpired() -> Bool {
        guard let installationDate = installationDate else {
            return true
        }
        
        let currentDate = Date()
        let calendar = Calendar.current
        let expirationDate = calendar.date(byAdding: .day, value: 3, to: installationDate) // Adjusted to 3 days for demo
        
        if let expirationDate = expirationDate {
            return currentDate >= expirationDate
        } else {
            return true
        }
    }
    
    func hasValidSubscription() -> Bool {
        // Your subscription validation logic
        return isSubscribed
    }
    
    
    func getMessageAndExpirationDate() -> (String, String, Bool) {
        let expirationDate = demoExpirationDate()
        let isExpired = isDemoPeriodExpired()
        
        if hasValidSubscription() {
            return ("Your subscription is currently active. Enjoy SimpleSpin! If you wish to manage your subscription settings or cancel auto-renewal, you can do so at any time.", expirationDate, isExpired)
        } else {
            if isExpired {
                return ("Your demo period expired on \(expirationDate). Please subscribe to unlock full features.", expirationDate, isExpired)
            } else {
                return ("You are currently in the demo period until \(expirationDate). Enjoy using the app!", expirationDate, isExpired)
            }
        }
    }
    
    func demoExpirationDate() -> String {
        guard let installationDate = installationDate else {
            return "N/A"
        }
        
        let expirationDate = Calendar.current.date(byAdding: .day, value: 3, to: installationDate) ?? installationDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm"
        
        return dateFormatter.string(from: expirationDate)
    }
}
