// Manages all bluetooth connections from Echelon device.  Sends broadcast and receives resistance and cadence.
import CoreBluetooth



class EchelonBluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var exercisePeripheral: CBPeripheral?
    private let bikeUUID = CBUUID(string: "0bf669f0-45f2-11e7-9598-0800200c9a66")
    private let serviceUUID = CBUUID(string: "0bf669f1-45f2-11e7-9598-0800200c9a66")
    private let writeCharacteristicUUID = CBUUID(string: "0bf669f2-45f2-11e7-9598-0800200c9a66")
    private let notifyCharacteristicUUID1 = CBUUID(string: "0bf669f3-45f2-11e7-9598-0800200c9a66")
    private let notifyCharacteristicUUID2 = CBUUID(string: "0bf669f4-45f2-11e7-9598-0800200c9a66")
    
    private var viewModel: ExerciseBike
    
    init(viewModel: ExerciseBike) {
        
        self.viewModel = viewModel
        
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    // BLE code
    
    func startScan() {
        viewModel.isLoading = true
        // Searches for specific bluetooth echelon bike
        centralManager.scanForPeripherals(withServices: [bikeUUID], options: nil)
        
        // Searches for all bluetooth devices
//        centralManager.scanForPeripherals(withServices: nil, options: nil)
        debugPrint("Scanning for exercise bike UUID: \(bikeUUID)")
        viewModel.bikeMessage = "Scanning for exercise bike..."
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScan()
        } else {
            debugPrint("Bluetooth not available")
            viewModel.bikeMessage = "Bluetooth not available"
            
            
            viewModel.setMessage(message: "Bluetooth not available")
            viewModel.isLoading = true
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
  //      print("Discovered peripheral: \(peripheral.identifier), name: \(peripheral.name ?? "Unknown")")
        
       debugPrint("Initializing bike: \(peripheral)")
        //   if peripheral.identifier.uuidString == "D70DCA5C-1C30-B7EC-8CAB-69D5A540C259" {
        exercisePeripheral = peripheral
        exercisePeripheral?.delegate = self
        centralManager.stopScan()
        centralManager.connect(exercisePeripheral!)
        debugPrint("Echelon bike found, connecting...")
        viewModel.bikeMessage = "Echelon bike found, connecting..."
        //  }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        // Device connected, you can start interacting with the peripheral
        if peripheral.state == .connected {
            // Perform operations on the peripheral
            debugPrint("Connected to exercise bike, discovering services")
            peripheral.discoverServices([serviceUUID])
        }
        else {
            debugPrint("Peripheral is not in a connected state.")
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // Device disconnected, handle the disconnection event
        if let error = error {
            debugPrint("Peripheral DISCONNECTED with error: \(error.localizedDescription)")
            
            // Log more detailed error information if available
            if let cbError = error as? CBError {
                debugPrint("CoreBluetooth Error Code: \(cbError.errorCode)")
                debugPrint("CoreBluetooth Error Domain: \(CBError.errorDomain)")
                debugPrint("CoreBluetooth Error Description: \(cbError.localizedDescription)")
            }
        } else {
            debugPrint("Peripheral DISCONNECTED.")
        }
        
        // If bike disconnected, start searching for device
        debugPrint("ERROR in peripheral CONNECTION, start bike discovery")
        startScan()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            debugPrint("Peripheral FAIL TO CONNECT with error: \(error.localizedDescription)")
            // Log more detailed error information if available
            if let cbError = error as? CBError {
                debugPrint("CoreBluetooth Error Code: \(cbError.errorCode)")
                debugPrint("CoreBluetooth Error Domain: \(CBError.errorDomain)")
                debugPrint("CoreBluetooth Error Description: \(cbError.localizedDescription)")
            }
        } else {
            debugPrint("Peripheral  FAIL TO CONNECT .")
        }
        
        // If bike disconnected, start searching for device
        debugPrint("ERROR in peripheral  FAIL TO CONNECT , start bike discovery")
        startScan()
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics for service \(service.uuid): \(error.localizedDescription)")
            return
        }

        print("Discovering service: \(service.uuid)")
        
        guard let characteristics = service.characteristics else {
            print("No characteristics found for service \(service.uuid)")
            return
        }

        for characteristic in characteristics {
            print("Characteristics: \(characteristic.uuid)")

            if characteristic.uuid == notifyCharacteristicUUID1 || characteristic.uuid == notifyCharacteristicUUID2 {
                peripheral.setNotifyValue(true, for: characteristic)
                print("NOTIFYING characteristics set: \(characteristic.uuid)")
            }

            if characteristic.uuid == writeCharacteristicUUID {
                let dataToSend: [UInt8] = [0xF0, 0xB0, 0x01, 0x01, 0xA2]
                let data = Data(bytes: dataToSend, count: dataToSend.count)
                print("ENABLE Broadcast for Exercise Bike \(characteristic.uuid)) \(data)")

                peripheral.writeValue(data, for: characteristic, type: .withResponse)
                viewModel.bikeMessage = ""
            }
        }
    }

    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            let notificationType = data[1]
            
            //          debugPrint("Received notification from characteristic \(characteristic): \(data) : \(notificationType)")
            
            if notificationType == 0xD1 {  // Cadence notification
                //               debugPrint("CADENCE message: \(characteristic): \(data) : \(notificationType)")
                if data.count >= 11 {
                    viewModel.isLoading = false
                    viewModel.exerciseData.cadence = Double((Int16(data[9]) << 8) + Int16(data[10]))
                    viewModel.exerciseData.currentPower = viewModel.calculatePower(cadence: viewModel.exerciseData.cadence, resistance: Double(viewModel.exerciseData.resistance))
                    //                  debugPrint("  CADENCE: \( self.exerciseData.cadence)  resistance \(self.exerciseData.resistance)  power: \(self.exerciseData.currentPower)")
                    viewModel.updateCadenceAndResistance()
                } else {
                    debugPrint("Error: Invalid data length for Cadence message")
                }
            } else if notificationType == 0xD2 {  // Resistance notification
                #if DEBUG || SANDBOX
                debugPrint("Resistance message: \(characteristic): \(data) : \(notificationType)")
                #endif
                if data.count >= 4 {
                    viewModel.isLoading = false
                    viewModel.exerciseData.resistance = Double(data[3])
                    viewModel.exerciseData.currentPower = viewModel.calculatePower(cadence: viewModel.exerciseData.cadence, resistance: viewModel.exerciseData.resistance)
                    //            debugPrint("  RESISTANCE: \(self.exerciseData.resistance)  cadence: \(self.exerciseData.cadence) power: \(self.exerciseData.currentPower)")
                    viewModel.updateCadenceAndResistance()
                } else {
                    debugPrint("Error: Invalid data length for Resistance message")
                }
            }
        }
    }
    
}

