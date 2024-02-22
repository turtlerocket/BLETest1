import SwiftUI


struct SettingsView: View {
    @Binding var isVisible: Bool
    
    @State private var selectedDistanceUnit = ConfigurationManager.shared.isKMUnit ? "km" : "mi"
    @State private var selectedSleepTime =      ConfigurationManager.shared.sleepTime
    @State private var errorMessage = ""
    
    @ObservedObject var viewModel: ExerciseBike
    
    let metricSize: Double = 16 // Define your metric size here
    
    var body: some View {
        VStack {
            Text("Settings")
                .foregroundColor(.white)
                .font(.title)
                .padding()
            
            Spacer()
            
            Form {
                Section {
                    HStack {
                        
                        Text("Unit")
                            .frame(width: 50, alignment: .trailing)
                            .font(.system(size: CGFloat(metricSize) * 1.5))
                        
                        Spacer()
                        Picker("", selection: $selectedDistanceUnit) {
                            Text("Kilometer").tag("km")
                            Text("Mile").tag("mi")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .font(.system(size: CGFloat(metricSize) * 1.5))
                        Spacer()
                    }
                    .font(.system(size: CGFloat(metricSize) * 1.5))
                }
                
                Section(header: Text("")) {
                    Picker("Sleep Time", selection: $selectedSleepTime) {
                        Text("1 min").tag(1)
                        Text("5 min").tag(5)
                        Text("10 min").tag(10)
                        Text("15 min").tag(15)
                        Text("30 min").tag(30)
                        Text("45 min").tag(45)
                        Text("60 min").tag(60)
                        Text("Never").tag(-1)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .font(.system(size: CGFloat(metricSize) * 1.5))
                }
            }
            .padding()
            .background(neomorphicBackground)
            
            Text(errorMessage)
                .foregroundColor(.red)
                .padding()
            
            HStack {
                Spacer()
                
                Button("Cancel") {
                    isVisible = false
                }
                .buttonStyle(NeomorphicButtonStyle(buttonColor: Color.white, fontColor: Color.black))
                
                Button("Save") {
                    // Accessing the shared instance of ConfigurationManager
                    let configMgr = ConfigurationManager.shared
                    
                    // Check the distance format
                    if selectedDistanceUnit == "km" {
                        configMgr.isKMUnit = true
                        viewModel.isKMUnit = true
                    } else if selectedDistanceUnit == "mi" {
                        configMgr.isKMUnit = false
                        viewModel.isKMUnit = false
                    }
                    
                    // Save sleep time setting
                    configMgr.sleepTime = selectedSleepTime
                    viewModel.sleepTime = selectedSleepTime
                    
                    configMgr.saveChanges()
                    
                    isVisible = false
                }
                .buttonStyle(NeomorphicButtonStyle(buttonColor: Color.white, fontColor: Color.black))
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .cornerRadius(20)
        .shadow(color: Color.white.opacity(0.2), radius: 10, x: -5, y: -5)
        .shadow(color: Color.black.opacity(0.7), radius: 10, x: 5, y: 5)
    }
    
    var neomorphicBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.black)
            .shadow(color: Color.white.opacity(0.2), radius: 10, x: -5, y: -5)
            .shadow(color: Color.black.opacity(0.7), radius: 10, x: 5, y: 5)
    }
}



struct SettingButton : View {
    @Binding var isSettingsVisible: Bool
    
    var body: some View {
        // Gear button
        VStack {
            HStack {
                Button(action: {
                    isSettingsVisible.toggle()
                }) {
                    Image(systemName: "gear")
                        .foregroundColor(.white)
                        .padding() // Adjust padding to increase button size
                    
                }
                .font(.system(size: CGFloat(Double(metricSize) * 1.5)))
                .padding(.leading) // Add leading padding to position the button to the right
                
                Spacer()
            }
            Spacer()
        }
    }
}
