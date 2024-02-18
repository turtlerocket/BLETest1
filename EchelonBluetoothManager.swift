// Works - captures cadence, resistance - calculates power.
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
        centralManager.scanForPeripherals(withServices: [bikeUUID], options: nil)
   //     centralManager.scanForPeripherals(withServices: nil, options: nil)
        print("Scanning for exercise bike...")
        viewModel.bikeMessage = "Scanning for exercise bike"
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScan()
        } else {
            print("Bluetooth not available")
            viewModel.bikeMessage = "Bluetooth not available"
            
            
            viewModel.setMessage(message: "Bluetooth not available")
            viewModel.isLoading = true
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Initializing bike: \(peripheral)")
     //   if peripheral.identifier.uuidString == "D70DCA5C-1C30-B7EC-8CAB-69D5A540C259" {
            exercisePeripheral = peripheral
            exercisePeripheral?.delegate = self
            centralManager.stopScan()
            centralManager.connect(exercisePeripheral!)
            print("Excehlon bike found, connecting...")
        viewModel.bikeMessage = "Echelon bike found, connecting..."
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
                    viewModel.bikeMessage = ""
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
                    viewModel.isLoading = false
                    viewModel.exerciseData.cadence = Double((Int16(data[9]) << 8) + Int16(data[10]))
                    viewModel.exerciseData.currentPower = viewModel.calculatePower(cadence: viewModel.exerciseData.cadence, resistance: Double(viewModel.exerciseData.resistance))
  //                  print("  CADENCE: \( self.exerciseData.cadence)  resistance \(self.exerciseData.resistance)  power: \(self.exerciseData.currentPower)")
                    viewModel.updateCadenceAndResistance()
                } else {
                    print("Error: Invalid data length for Cadence message")
                }
            } else if notificationType == 0xD2 {  // Resistance notification
                print("Resistance message: \(characteristic): \(data) : \(notificationType)")
                if data.count >= 4 {
                    viewModel.isLoading = false
                    viewModel.exerciseData.resistance = Double(data[3])
                    viewModel.exerciseData.currentPower = viewModel.calculatePower(cadence: viewModel.exerciseData.cadence, resistance: viewModel.exerciseData.resistance)
        //            print("  RESISTANCE: \(self.exerciseData.resistance)  cadence: \(self.exerciseData.cadence) power: \(self.exerciseData.currentPower)")
                    viewModel.updateCadenceAndResistance()
                } else {
                    print("Error: Invalid data length for Resistance message")
                }
            }
        }
    }
}

