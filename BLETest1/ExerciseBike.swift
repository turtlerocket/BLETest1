// Works - captures cadence, resistance - calculates power.

import SwiftUI
import CoreBluetooth

class ExerciseBike: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var exercisePeripheral: CBPeripheral?
    private let bikeUUID = CBUUID(string: "0bf669f0-45f2-11e7-9598-0800200c9a66")
    private let serviceUUID = CBUUID(string: "0bf669f1-45f2-11e7-9598-0800200c9a66")
    private let writeCharacteristicUUID = CBUUID(string: "0bf669f2-45f2-11e7-9598-0800200c9a66")
    private let notifyCharacteristicUUID1 = CBUUID(string: "0bf669f3-45f2-11e7-9598-0800200c9a66")
    private let notifyCharacteristicUUID2 = CBUUID(string: "0bf669f4-45f2-11e7-9598-0800200c9a66")
    
    @Published var cadence: UInt16 = 0
    @Published var resistance: UInt16 = 0
    @Published var power: UInt16 = 0
    @Published var speed: UInt16 = 0
    @Published var currentTime: String = ""
    
    @Published var totalPower: UInt16 = 0
    @Published var timerValue: Int = 0
    @Published var totalDistance: UInt16 = 0
    
    // Timer properties
    private var timer: Timer?
    public var isTimerRunning: Bool = false
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() {
        centralManager.scanForPeripherals(withServices: [bikeUUID], options: nil)
   //     centralManager.scanForPeripherals(withServices: nil, options: nil)
        print("Scanning for exercise bike...")
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScan()
        } else {
            print("Bluetooth not available")
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
     //   }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to exercise bike")
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
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == notifyCharacteristicUUID1 || characteristic.uuid == notifyCharacteristicUUID2 {
                    peripheral.setNotifyValue(true, for: characteristic)
                    print("NOTIFYING characteristics set: \(characteristic)")
                }
                if characteristic.uuid == writeCharacteristicUUID {
                    let dataToSend: [UInt8] = [0xF0, 0xB0, 0x01, 0x01, 0xA2]
                    let data = Data(bytes: dataToSend, count: dataToSend.count)
                    print("ENABLE Broadcast for Exercise Bike \(characteristic)) \(data)")

                    peripheral.writeValue(data, for: characteristic, type: .withResponse)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            let notificationType = data[1]
            
  //          print("Received notification from characteristic \(characteristic): \(data) : \(notificationType)")
            
            if notificationType == 0xD1 {  // Cadence notification
                print("CADENCE message: \(characteristic): \(data) : \(notificationType)")
                if data.count >= 11 {
                    cadence = (UInt16(data[9]) << 8) + UInt16(data[10])
                    power = getPower(cadence: cadence, resistance: UInt8(resistance))
                    print("  CADENCE: \(cadence)  resistance \(resistance)  power: \(power)")
                } else {
                    print("Error: Invalid data length for Cadence message")
                }
            } else if notificationType == 0xD2 {  // Resistance notification
                print("Resistance message: \(characteristic): \(data) : \(notificationType)")
                if data.count >= 4 {
                    resistance = UInt16(data[3])
                    power = getPower(cadence: cadence, resistance: UInt8(resistance))
                    print("  RESISTANCE: \(resistance)  cadence: \(cadence) power: \(power)")
                } else {
                    print("Error: Invalid data length for Resistance message")
                }
            }
        }
    }
    
    func getPower(cadence: UInt16, resistance: UInt8) -> UInt16 {
        // Implement your power calculation here
        return cadence * UInt16(resistance)
    }
    
    // Start the timer
    func startTimer() {
        guard !isTimerRunning else { return }
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.timerValue += 1
            self.updateValues()
        }
    }
    
    // Stop the timer
    func stopTimer() {
        guard isTimerRunning else { return }
        isTimerRunning = false
        timer?.invalidate()
    }
    
    // Reset all values
    func reset() {
        stopTimer()
        timerValue = 0
        totalDistance = 0
        totalPower = 0
    }
    
    // Update values based on timer
    private func updateValues() {
        speed = (cadence * resistance) / 100
        power = (cadence * resistance) / 2
        
        // Update total distance and power if the timer is running
        if isTimerRunning {
            
            totalDistance += speed / 3600
            totalPower += power
            debugPrint("  totalDistance: \(totalDistance)  totalPower \(totalPower)")
        }
    }
    

    
    
}

