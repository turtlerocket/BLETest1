import SwiftUI


// View model for handling data updates and calculations
class SimulatedExerciseBike: ExerciseBike {
    
    override init() {
        super.init()
        
        debugPrint("INITIALIZING - SimulatedExerciseBike")
    
        // Simulate waiting 10 seconds for initialization
        self.bikeMessage = "Initializing bike..."
                
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
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
        debugPrint("SimulatedExerciseBike: connectDevice")
    }
    
    // Update cadence and resistance with realistic bike numbers
    override func updateCadenceAndResistance() {
        isLoading = false
        let cadence = Double.random(in: 60...120) // Realistic cadence range
        let resistance = Double.random(in: 1...32) // Realistic resistance range
        
        // Check if new maximum values are reached and update accordingly
        if cadence > exerciseData.maximumCadence {
            exerciseData.maximumCadence = cadence
        }
        
        self.exerciseData.cadence = cadence
        self.exerciseData.resistance = resistance
        self.exerciseData.currentPower = self.calculatePower(cadence: cadence, resistance: resistance)
        self.exerciseData.speed = self.calculateSpeed(cadence: cadence, resistance: resistance)
        
        if   self.exerciseData.currentPower > exerciseData.maximumPower {
            exerciseData.maximumPower = self.exerciseData.currentPower
        }
        if  self.exerciseData.speed > exerciseData.maximumSpeed {
            exerciseData.maximumSpeed =  self.exerciseData.speed
        }
    }
}
