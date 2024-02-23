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
    
    func updateMessage() {
        let (message, expirationDate, isExpired) = DemoExpirationManager.shared.getMessageAndExpirationDate()
        self.message = message
        self.demoExpirationDate = expirationDate
        self.isDemoExpired = isExpired
    }
    
    func checkSubscriptionStatus() {
        let isSubscribed = DemoExpirationManager.shared.hasValidSubscription()
        self.isSubscribed = isSubscribed
    }
    
    func startOrStopTimer() {
        if isSubscribed {
            timer?.invalidate()
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.updateMessage()
            }
        }
    }
}

import Foundation

class DemoExpirationManager {
//    static let shared = DemoExpirationManager()
    static let shared = DemoExpirationManager(isSubscribed: true)
    

    private let installationDateKey = "InstallationDate"
    
    var installationDate: Date? {
        get {
            if let loadedDate = KeychainService.loadDate(forKey: installationDateKey) {
                return loadedDate
            } else {
                let currentDate = Date()
                KeychainService.saveDate(value: currentDate, forKey: installationDateKey)
                return currentDate
            }
        }
        set {
            if let newValue = newValue {
                KeychainService.saveDate(value: newValue, forKey: installationDateKey)
            } else {
                KeychainService.deleteValue(forKey: installationDateKey)
            }
        }
    }
    
    var isSubscribed: Bool
    
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
            return ("Your subscription is active. Enjoy the full version!", expirationDate, isExpired)
        } else {
            if isExpired {
                return ("Your demo period has expired on \(expirationDate). Please subscribe to unlock full features.", expirationDate, isExpired)
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
