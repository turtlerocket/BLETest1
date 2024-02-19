//
//  ConfigurationManager.swift
//  BLETest1
//
//  Created by Benjamin  Dai on 2/17/24.
//

import Foundation

class ConfigurationManager {
    static let shared = ConfigurationManager()
    
    private let isWattUnitKey = "isWattUnit"
    private let isKMUnitKey = "isKMUnit"
    private let sleepTimeKey = "sleepTime" // New key for sleep time
    
    var isWattUnit: Bool {
        get {
            return UserDefaults.standard.bool(forKey: isWattUnitKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: isWattUnitKey)
        }
    }
    
    var isKMUnit: Bool {
        get {
            return UserDefaults.standard.bool(forKey: isKMUnitKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: isKMUnitKey)
        }
    }
    
    var sleepTime: Int {
           get {
               return UserDefaults.standard.integer(forKey: sleepTimeKey)
           }
           set {
               UserDefaults.standard.set(newValue, forKey: sleepTimeKey)
           }
       }
        
    private init() {
          // Initialize default values if configuration is not set
          let defaultValues: [String: Any] = [isWattUnitKey: true, isKMUnitKey: true, sleepTimeKey: 5]
          UserDefaults.standard.register(defaults: defaultValues)
      }
    
    // Function to save changes to UserDefaults
    func saveChanges() {
        UserDefaults.standard.set(isWattUnit, forKey: isWattUnitKey)
        UserDefaults.standard.set(isKMUnit, forKey: isKMUnitKey)
        UserDefaults.standard.set(sleepTime, forKey: sleepTimeKey)
    }
}

class Configuration {
    var isWattUnit: Bool
    var isKMUnit: Bool
    
    init(isWattUnit: Bool, isKMUnit: Bool) {
        self.isWattUnit = isWattUnit
        self.isKMUnit = isKMUnit
    }
    
    // Convenience initializer with default values
    convenience init() {
        let configManager = ConfigurationManager.shared
        self.init(isWattUnit: configManager.isWattUnit, isKMUnit: configManager.isKMUnit)
    }
    
    // Function to print configuration information
    func printConfiguration() {
        print("Watt Unit: \(isWattUnit ? "Enabled" : "Disabled")")
        print("KM Unit: \(isKMUnit ? "Enabled" : "Disabled")")
    }
    

}

// Example usage:
//var config = Configuration(isWattUnit: true, isKMUnit: false)
//config.printConfiguration()
