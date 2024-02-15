import SwiftUI


// View model for handling data updates and calculations
class SimulatedExerciseBike: ObservableObject {
    @Published var exerciseData: ExerciseBikeData
    private var timer: Timer?
    private var startTime: Date?
    
    @Published var isTimerRunning = false // Track whether the timer is running
    @Published var isLoading = true // True when finding and connecting bike to bluetooth; After successful connection, True
    @Published var bikeMessage: String? = nil
    
    init() {
        debugPrint("INITIALIZING - SimulatedExerciseBike")
        // Initialize with default values
        self.exerciseData = ExerciseBikeData()
        
        // Start updating cadence and resistance every 2 seconds
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateCadenceAndResistance()
        }
        
        isLoading = false
    }
    
    // Update cadence and resistance with realistic bike numbers
    private func updateCadenceAndResistance() {
        let cadence = Double.random(in: 60...120) // Realistic cadence range
        let resistance = Double.random(in: 1...10) // Realistic resistance range
        
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

    // Start the timer
    func startTimer() {
        guard !isTimerRunning else { return } // Check if timer is already running

        // Start updating data
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            
            // Calculate the time interval since the start time
            let currentTime = Date()
            let elapsedTime = currentTime.timeIntervalSince(startTime)

            // Update data with realistic values
            let currentSpeed = self.exerciseData.speed
            let currentPower = currentSpeed * self.exerciseData.resistance
            self.exerciseData.currentPower = currentPower

            // Update total power and total distance only every second
            if Int(elapsedTime) % 1 == 0 {
                self.exerciseData.totalPower += currentPower / 3600 // Power is in Watt-Hours
                self.exerciseData.totalDistance += currentSpeed / 3600 // Distance is in units per second (e.g., meters/second)
            }

            // Update elapsed time
            self.exerciseData.elapsedTime = elapsedTime
        }
        
        isTimerRunning = true
    }

    // Stop the timer
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }

    // Reset the timer, total distance, total power, and maximum values
    func resetTimer() {
        stopTimer()
        exerciseData.elapsedTime = 0
        exerciseData.totalDistance = 0
        exerciseData.totalPower = 0
        exerciseData.maximumCadence = 0
        exerciseData.maximumSpeed = 0
        exerciseData.maximumPower = 0
    }

    // Calculate power from cadence and resistance
    private func calculatePower(cadence: Double, resistance: Double) -> Double {
        // Typical power calculation: power = cadence * resistance
        // Typicalthis bike has resistance level to N.m so the formula is Power (kW) = Torque (N.m) x Speed (RPM) / 9.5488

        return (cadence * resistance) / 9.5488
    }
    
    // Calculate speed from cadence and resistance
    private func calculateSpeed(cadence: Double, resistance: Double) -> Double {
        // Implement your speed calculation logic here
        // Example calculation: speed = (cadence * resistance) / 10
        //   return (cadence * resistance)/10
        return ((cadence - 35) * 0.4) * ((resistance/100) * 9) + 0.4
    }
    
    
}
