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
    
        #if DEBUG
        print("Message updated: \(message)")
         print("Demo expiration date updated: \(expirationDate)")
         print("Demo expired flag updated: \(isExpired)")
        #else
        // do nothing if in production
        #endif
        
        // HACK: check if DemoExpirationManager is subscribed, if yes, stop the demo expiration check
        if (DemoExpirationManager.shared.hasValidSubscription()) {
            print("Noticed user is subscribed.  Stop further demo expiration checks")
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

class DemoExpirationManager: ExpirationManager {
    
   
    //    static let shared = DemoExpirationManager()
//    static let shared = DemoExpirationManager(isSubscribed: true)
    
    // Change to SimulatedExpirationManager for no demo expire and active subscription
//    static let shared = DemoExpirationManager(isSubscribed: false)
//    static let shared = SimulatedExpirationManager()

    private var isSubscribed: Bool
    
    private let installationDateKey = "InstallationDate"
    private let demoStartDateKey = "demoStartDateKey"

    
    private var demoStartDate: Date? {
        get {
            return retrieveDemoStartDate()
        }
        set {
            saveDemoStartDate(newValue) // newValue is automatically provided by Swift
        }
    }
    
    // Set the installation date once - note that the Keychain does not disappear unless the app removes it
    private var installDate: Date? {
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
 
    
    override init(isSubscribed: Bool = false) {
        self.isSubscribed = isSubscribed

    }
    
    override func setInstallationDateIfNeeded() {
        _ = demoStartDate
    }
    
    override func isDemoPeriodExpired() -> Bool {
        
        // If installation date is set,
        guard let demoStartDate = demoStartDate else {
            return true
        }
       
        // Set demo expiration to 7 days to allow time for use and testing with exercise bike
        let currentDate = Date()
        let calendar = Calendar.current

        // If debug, demo expires in 5 minutes.  Production, 7 days
        #if SANDBOX
        debugPrint("DemoExpirationManager:  SANDBOX")
        let expirationDate = calendar.date(byAdding: .minute, value: 5, to: demoStartDate) // 5 minutes to expire for demo
        #else
        let expirationDate = calendar.date(byAdding: .day, value: 7, to: demoStartDate) // 7 Day expire for demo
        #endif
        
        if let expirationDate = expirationDate {
            return currentDate >= expirationDate
        } else {
            return true
        }
    }
    override func setSubscription(isSubscribed: Bool = false) {
        self.isSubscribed = isSubscribed
    }
    
    override func hasValidSubscription() -> Bool {
        // Your subscription validation logic
        return isSubscribed
    }
    
    
    override func getMessageAndExpirationDate() -> (String, String, Bool) {
        let expirationDate = demoExpirationDate()
        let isExpired = isDemoPeriodExpired()
        
        if hasValidSubscription() {
            // If the subscription is active, delete the demo start date
            // TODO: This really should be only called once when subscription is started
           print("Demo start date REMOVED because SUBSCRIBED")
            KeychainService.shared.deleteValue(forKey: demoStartDateKey)
            
            return ("Your subscription is currently active. Enjoy SimpleSpin! If you wish to manage your subscription settings or cancel auto-renewal, you can do so at any time.", expirationDate, isExpired)
        } else {
            if isExpired {
                return ("Your demo period expired on \(expirationDate). Subscribe to ensure uninterrupted access with your subscription! Enjoy seamless usage of all features!", expirationDate, isExpired)
            } else {
                return ("You are currently in the demo period until \(expirationDate). Enjoy using the app!", expirationDate, isExpired)
            }
        }
    }
    
    override func demoExpirationDate() -> String {
        guard let demoStartDate = demoStartDate else {
            return "N/A"
        }
        
        // Check the demo expiration date to be 7 days after demo start date
        let expirationDate = Calendar.current.date(byAdding: .day, value: 7, to: demoStartDate) ?? demoStartDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm"
        
        return dateFormatter.string(from: expirationDate)
    }
    
    
    private func retrieveDemoStartDate() -> Date? {
        if let loadedDate = KeychainService.shared.loadDate(forKey: demoStartDateKey) {
            return loadedDate
        } else {
            let currentDate = Date()
            saveDemoStartDate(currentDate)
            return currentDate
        }
    }

    private func saveDemoStartDate(_ date: Date?) {
        if let newValue = date {
            KeychainService.shared.saveDate(value: newValue, forKey: demoStartDateKey)
        } else {
            KeychainService.shared.deleteValue(forKey: demoStartDateKey)
        }
    }
}
