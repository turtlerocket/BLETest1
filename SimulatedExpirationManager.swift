//
//  SimulatedExpirationManager.swift
//  Simple Spin
//
//  Created by Benjamin  Dai on 2/29/24.
//

import Foundation


class SimulatedExpirationModel: ObservableObject {
    @Published var message: String = ""
    @Published var isSubscribed: Bool = true
    @Published var demoExpirationDate: String = ""
    @Published var isDemoExpired: Bool = false
    
   
    init() {
    }
    
    deinit {
   
    }
    
    func updateMessage() {
       
    }
    
    func checkSubscriptionStatus() {

        self.isSubscribed = true
    }
    
    func startOrStopTimer() {
   
    }
}

import Foundation

class SimulatedExpirationManager: ExpirationManager {
//    static let shared = DemoExpirationManager()
//    static let shared = DemoExpirationManager(isSubscribed: true)
//   static let shared = SimulatedExpirationManager()


    private let installationDateKey = "InstallationDate"
    private let demoStartDateKey = "demoStartDateKey"


    
    var isSubscribed: Bool = true
    

    init() {
        super.init()
        
        // If DEMO build, delete all the installation and demo start keys so that the next real build starts with clean-slate
        #if DEMO
        KeychainService.shared.deleteValue(forKey: installationDateKey)
        KeychainService.shared.deleteValue(forKey: demoStartDateKey)
        #endif
    }
    

override func isDemoPeriodExpired() -> Bool {
return false
}
    
 override   func hasValidSubscription() -> Bool {
        // Your subscription validation logic
        return isSubscribed
    }
    
override    func getMessageAndExpirationDate() -> (String, String, Bool) {
        return ("Your SIMULATED subscription is currently active. Enjoy SimpleSpin!", "No Expiration", false)

    }
    
    
    
}
