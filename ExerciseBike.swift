// Works - captures cadence, resistance - calculates power.
import Foundation

// Model data for exercise bike
struct ExerciseBikeData {
    var speed: Double
    var cadence: Double
    var resistance: Double
    var currentPower: Double
    var avgPower: Double
 //   var totalPower: Double
    var totalDistance: Double
    var elapsedTime: TimeInterval // Elapsed time in seconds
    
    // Properties to track maximum values
    var maximumCadence: Double
    var maximumSpeed: Double
    var maximumPower: Double
    
    var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        
       
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    init() {
        self.speed = 0
        self.cadence = 0
        self.resistance = 0
        self.currentPower = 0
        self.avgPower = 0
        self.totalDistance = 0
        self.elapsedTime = 0
        self.maximumCadence = 0
        self.maximumSpeed = 0
        self.maximumPower = 0
    }
}


class ExerciseBike: ObservableObject {
    @Published var exerciseData: ExerciseBikeData
    
    @Published var bikeMessage: String = ""
    
    private var timer: Timer?
    private var startTime: Date?
    private var bluetoothMgr: EchelonBluetoothManager?
    
    @Published var isTimerRunning = false // Track whether the timer is running
    @Published var isLoading = true // True when finding and connecting bike to bluetooth; After successful connection, True
    
    @Published var isWattUnit: Bool
    @Published var isKMUnit: Bool
    @Published var sleepTime: Int
  
    @Published var lastActionTime: Date = LowMemoryDateProvider.current
    
    init() {
       print("Init ExerciseBike")
        self.exerciseData = ExerciseBikeData()
        
        // Accessing the shared instance of ConfigurationManager
        let configMgr = ConfigurationManager.shared
        
        // Accessing configuration settings
        self.isWattUnit = configMgr.isWattUnit
        self.isKMUnit = configMgr.isKMUnit
        self.sleepTime = configMgr.sleepTime
        
 //       print("isWattUnit:", self.isWattUnit)
 //       print("isKMUnit:", self.isKMUnit)
 //       print("sleepTime:", self.sleepTime)
        
 
    }
    
    // Separated connectDevice from init because I cannot send self ExerciseBike to BluetoothManager until all self initialized; this is circular
    public func connectDevice() {
        print("ConnectDevice ExerciseBike")
        fatalError("connectDevice MUST be implemented by sub-class")
    }
    
    public func setMessage(message: String ) {
        print("MESSAGE HERE")
        self.bikeMessage = message
    }
    
    // Update cadence and resistance with realistic bike numbers
    // Command should only be called by delegate class EchelonBluetoothManager
    // TODO: this should not be public, but perhaps protected?
    public func updateCadenceAndResistance() {
    /*    let cadence = Double.random(in: 60...120) // Realistic cadence range
        let resistance = Double.random(in: 1...10) // Realistic resistance range
     */
        // Check if new maximum values are reached and update accordingly
        if self.exerciseData.cadence > exerciseData.maximumCadence {
            exerciseData.maximumCadence = self.exerciseData.cadence
        }
     
     
  //      self.exerciseData.cadence = cadence
  //      self.exerciseData.resistance = resistance
        self.exerciseData.currentPower = self.calculatePower(cadence: self.exerciseData.cadence, resistance:  self.exerciseData.resistance)
        self.exerciseData.speed = self.calculateSpeed(cadence: self.exerciseData.cadence, resistance:  self.exerciseData.resistance)
      
        if   self.exerciseData.currentPower > exerciseData.maximumPower {
            exerciseData.maximumPower = self.exerciseData.currentPower
        }
        if  self.exerciseData.speed > exerciseData.maximumSpeed {
            exerciseData.maximumSpeed =  self.exerciseData.speed
        }
        
        // Get the time of the most recent activity
 //       LowMemoryDateProvider.updateCurrentDate()
   //     lastActionTime = LowMemoryDateProvider.current

     //   print("Updating Cadence and Resistance: \(lastActionTime)")

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

            // TODO: Fix bug when app is running background, but the total power and distance odes not accumulate
            // Update total power and average power ONLY every second
            if Int(elapsedTime) % 1 == 0 {
         //       self.exerciseData.totalPower +=  self.exerciseData.currentPower  / 3600 // Power is in Watt/second
                self.exerciseData.avgPower =  self.exerciseData.avgPower + ((self.exerciseData.currentPower - self.exerciseData.avgPower) / elapsedTime)
                
                                                                
                self.exerciseData.totalDistance += self.exerciseData.speed / 3600 // Distance is in units per second (e.g., kmeters/second)
                
                // Update elapsed time
                self.exerciseData.elapsedTime = elapsedTime
            }

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
   //     exercisdeData.totalPower = 0
        exerciseData.avgPower = 0
        exerciseData.maximumCadence = 0
        exerciseData.maximumSpeed = 0
        exerciseData.maximumPower = 0
    }

    // Calculate power from cadence and resistance
    public func calculatePower(cadence: Double, resistance: Double) -> Double {
        // Typical power calculation: power = cadence * resistance
        // Typicalthis bike has resistance level to N.m so the formula is Power (kW) = Torque (N.m) x Speed (RPM) / 9.5488

        return (cadence * resistance) / 9.5488
    }
    
    // Calculate speed from cadence and resistance
   public func calculateSpeed(cadence: Double, resistance: Double) -> Double {
   
       // Implement your speed calculation logic here
        // Example calculation: speed = (cadence * resistance) / 10
        //   return (cadence * resistance)/10
 //       return ((cadence - 35) * 0.4) * ((resistance/32) * 9) + 0.4
 //         return ((cadence) * 0.4) * ((resistance/32) * 9) + 0.4
  //The 2.5 is an exponent. I did the same thing as you, but I think the formula appears differently on // web/iPhone/Android. Works much better as an exponent!
        return pow(10 * self.exerciseData.currentPower, 0.4)
    }

}

struct LowMemoryDateProvider {
    static var current: Date = Date()
    
    static func updateCurrentDate() {
        // Update the current date only when necessary
        current = Date()
    }
}

