//
//  SleepingBike.swift
//  Simple Spin
//
//  Created by Benjamin  Dai on 2/19/24.
//

import Foundation
import SwiftUI


// View model for handling data updates and calculations
class SleepingBike: ExerciseBike {
    
    override init() {
        super.init()
        
        debugPrint("INITIALIZING - SleepingBike")
    
        // Simulate waiting 10 seconds for initialization
        self.bikeMessage = "Initializing bike..."
                
        // Simulate loading with 10 seconds to load bike
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { timer in
            self.isLoading = false
            self.bikeMessage = ""
        }
        
        // Start updating cadence and resistance every 2 seconds
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateCadenceAndResistance()
        }
    }
    
    // Separated connectDevice from init because I cannot send self ExerciseBike to BluetoothManager until all self initialized; this is circular
    override func connectDevice() {
        debugPrint("SleepingBike: connectDevice")
    }
    
    // Update cadence and resistance with realistic bike numbers
    override func updateCadenceAndResistance() {
        isLoading = false
      
        
      //  debugPrint("Doing nothing")
    }
}

