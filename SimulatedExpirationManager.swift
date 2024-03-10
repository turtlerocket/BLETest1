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

class SimulatedExpirationManager {
//    static let shared = DemoExpirationManager()
//    static let shared = DemoExpirationManager(isSubscribed: true)
//    static let shared = SimulatedExpirationManager()


    private let installationDateKey = "InstallationDate"
    private let demoStartDateKey = "demoStartDateKey"


    
    var isSubscribed: Bool = true
    


func isDemoPeriodExpired() -> Bool {
return false
}
    
    func hasValidSubscription() -> Bool {
        // Your subscription validation logic
        return isSubscribed
    }
    
    func getMessageAndExpirationDate() -> (String, String, Bool) {        
        return ("Your SIMULATED subscription is currently active. Enjoy SimpleSpin!", "No Expiration", false)

    }
    
    
    
}
