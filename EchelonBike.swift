// Works - captures cadence, resistance - calculates power.
import Foundation

class EchelonBike: ExerciseBike {
     private var bluetoothMgr: EchelonBluetoothManager?
 
    override init() {
        print("CREATING Echelon Exercise Model")
   
        super.init()
    }
    
    // Separated connectDevice from init because I cannot send self ExerciseBike to BluetoothManager until all self initialized; this is circular
    override func connectDevice() {
        // Setup bluetooth manager
        if self.bluetoothMgr == nil {
            print("CREATING Bluetooth Manager")
            self.bluetoothMgr = EchelonBluetoothManager(viewModel: self)
        }
    }
    
 
}


