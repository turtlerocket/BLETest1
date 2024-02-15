// Works - captures cadence, resistance - calculates power.

import SwiftUI
import CoreBluetooth

// Model data for exercise bike
struct ExerciseBikeData {
    var speed: Double
    var cadence: Double
    var resistance: Double
    var currentPower: Double
    var totalPower: Double
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
        self.totalPower = 0
        self.totalDistance = 0
        self.elapsedTime = 0
        self.maximumCadence = 0
        self.maximumSpeed = 0
        self.maximumPower = 0
    }
}


class ExerciseBike: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var exercisePeripheral: CBPeripheral?
    private let bikeUUID = CBUUID(string: "0bf669f0-45f2-11e7-9598-0800200c9a66")
    private let serviceUUID = CBUUID(string: "0bf669f1-45f2-11e7-9598-0800200c9a66")
    private let writeCharacteristicUUID = CBUUID(string: "0bf669f2-45f2-11e7-9598-0800200c9a66")
    private let notifyCharacteristicUUID1 = CBUUID(string: "0bf669f3-45f2-11e7-9598-0800200c9a66")
    private let notifyCharacteristicUUID2 = CBUUID(string: "0bf669f4-45f2-11e7-9598-0800200c9a66")
    
    @Published var exerciseData: ExerciseBikeData
    @Published var bikeMessage: String? = nil
    
    private var timer: Timer?
    private var startTime: Date?
    
    @Published var isTimerRunning = false // Track whether the timer is running
    @Published var isLoading = true // True when finding and connecting bike to bluetooth; After successful connection, True

    
    override init() {
        // Initialize with default values
        self.exerciseData = ExerciseBikeData()
        
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Start updating cadence and resistance every 2 seconds
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateCadenceAndResistance()
        }
    }
    
    // Update cadence and resistance with realistic bike numbers
    private func updateCadenceAndResistance() {
    /*    let cadence = Double.random(in: 60...120) // Realistic cadence range
        let resistance = Double.random(in: 1...10) // Realistic resistance range
        
        // Check if new maximum values are reached and update accordingly
        if cadence > exerciseData.maximumCadence {
            exerciseData.maximumCadence = cadence
        }
     */
     
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
                self.exerciseData.totalDistance += currentSpeed / 3600 // Distance is in units per second (e.g., kmeters/second)
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
 //       return ((cadence - 35) * 0.4) * ((resistance/32) * 9) + 0.4
 //         return ((cadence) * 0.4) * ((resistance/32) * 9) + 0.4
  //The 2.5 is an exponent. I did the same thing as you, but I think the formula appears differently on // web/iPhone/Android. Works much better as an exponent!
        return pow(10 * self.exerciseData.currentPower, 0.4)
    }
    
    
// BLE code
    
    func startScan() {
        isLoading = true
        centralManager.scanForPeripherals(withServices: [bikeUUID], options: nil)
   //     centralManager.scanForPeripherals(withServices: nil, options: nil)
        print("Scanning for exercise bike...")
        bikeMessage = "Scanning for exercise bike..."
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScan()
        } else {
            print("Bluetooth not available")
            bikeMessage = "Bluetooth not available"
            isLoading = true
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Initializing bike: \(peripheral)")
     //   if peripheral.identifier.uuidString == "D70DCA5C-1C30-B7EC-8CAB-69D5A540C259" {
            exercisePeripheral = peripheral
            exercisePeripheral?.delegate = self
            centralManager.stopScan()
            centralManager.connect(exercisePeripheral!)
            print("Exercise bike found, connecting...")
            bikeMessage = "Exercise bike found, connecting..."
     //   }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to exercise bike, discovering services")
        peripheral.discoverServices([serviceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        debugPrint("Discovering service: \(service)")
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                debugPrint("  Characteristics: \(characteristic)")
                if characteristic.uuid == notifyCharacteristicUUID1 || characteristic.uuid == notifyCharacteristicUUID2 {
                    peripheral.setNotifyValue(true, for: characteristic)
                    print("NOTIFYING characteristics set: \(characteristic)")
                }
                if characteristic.uuid == writeCharacteristicUUID {
                    let dataToSend: [UInt8] = [0xF0, 0xB0, 0x01, 0x01, 0xA2]
                    let data = Data(bytes: dataToSend, count: dataToSend.count)
                    print("ENABLE Broadcast for Exercise Bike \(characteristic)) \(data)")

                    peripheral.writeValue(data, for: characteristic, type: .withResponse)
                    bikeMessage = nil
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            let notificationType = data[1]
            
  //          print("Received notification from characteristic \(characteristic): \(data) : \(notificationType)")
            
            if notificationType == 0xD1 {  // Cadence notification
 //               print("CADENCE message: \(characteristic): \(data) : \(notificationType)")
                if data.count >= 11 {
                    isLoading = false
                    self.exerciseData.cadence = Double((Int16(data[9]) << 8) + Int16(data[10]))
                    self.exerciseData.currentPower = calculatePower(cadence: self.exerciseData.cadence, resistance: Double(self.exerciseData.resistance))
             //       print("  CADENCE: \( self.exerciseData.cadence)  resistance \(self.exerciseData.resistance)  power: \(self.exerciseData.currentPower)")
                } else {
                    print("Error: Invalid data length for Cadence message")
                }
            } else if notificationType == 0xD2 {  // Resistance notification
                print("Resistance message: \(characteristic): \(data) : \(notificationType)")
                if data.count >= 4 {
                    isLoading = false
                    self.exerciseData.resistance = Double(data[3])
                    self.exerciseData.currentPower = calculatePower(cadence: self.exerciseData.cadence, resistance: self.exerciseData.resistance)
        //            print("  RESISTANCE: \(self.exerciseData.resistance)  cadence: \(self.exerciseData.cadence) power: \(self.exerciseData.currentPower)")
                } else {
                    print("Error: Invalid data length for Resistance message")
                }
            }
        }
    }
}

