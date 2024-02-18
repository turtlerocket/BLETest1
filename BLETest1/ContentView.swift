import SwiftUI

import UIKit

// Global variablees and enums for UI Gauge, Header, and Bike Metrics

enum GaugeSize {
    static let small: Int = 200
    static let medium: Int = 300
    static let large: Int = 300
}

enum HeaderSize {
    static let small: Int = 12
    static let medium: Int = 13
    static let large: Int = 20
}

enum MetricSize {
    static let small: Int = 15
    static let medium: Int = 15
    static let large: Int = 25
}

var gaugeSize: Int = GaugeSize.medium
var headerSize: Int = HeaderSize.medium
var metricSize: Int = MetricSize.medium

// Main ContentView
struct ContentView: View {
    // For now swap ExcerciseBike for SimulatedExerciseBike
    // TODO: Refactor ExerciseBike and SimulatedExerciseBike to have same Bike super-class
    @ObservedObject var viewModel = EchelonBike()
 //   @ObservedObject var viewModel = SimulatedExerciseBike()
    
    @State private var isSpeedDisplayed = true // Toggle between speed and power
    
    // Defines how long before last state change - if more than 10 minutes, sleep screen
    @State private var lastStateChangeTime = Date()
    
    @State private var isLoading = true
    @State private var isIPhoneLandscape: Bool = false
    
    @State private var isSettingsVisible = false
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    init() {
        viewModel.connectDevice()
    }

    var body: some View {
        
        GeometryReader {    geometry in
            if (!isIPhoneLandscape) {
                VStack {
                    GaugeWidget(isSpeedDisplayed: $isSpeedDisplayed, viewModel: viewModel)
                    
                    Spacer()
                    
                    SpeedPowerToggle(isSpeedDisplayed: $isSpeedDisplayed)
                        .padding()
                    
                    Spacer()
                    
                    NeomorphicTable(viewModel: viewModel)
                    
                    Spacer()
                    
                    // Buttons for start/pause and reset
                    HStack {
                        Spacer()
                        if viewModel.isTimerRunning {
                            Button(action: {
                                viewModel.stopTimer()
                            }) {
                                Image(systemName: "pause.fill") // Use system image for Pause action
                                    .font(.system(size: geometry.size.width * 0.03)) // Adjust font size based on width
                            }
                            .buttonStyle(NeomorphicButtonStyle(buttonColor: Color.red, fontColor: Color.white)) // Apply neomorphic button style
                        } else {
                            Button(action: {
                                viewModel.startTimer()
                            }) {
                                Image(systemName: "play.fill") // Use system image for Start action
                                    .font(.system(size: geometry.size.width * 0.03)) // Adjust font size based on width
                            }
                            .buttonStyle(NeomorphicButtonStyle(buttonColor: Color.green, fontColor: Color.white)) // Apply neomorphic button style
                        }
                        
                        Spacer(minLength: 10).frame(maxWidth: 20) // Add spacer with maximum length of 50
                        
                        Button(action: {
                            viewModel.resetTimer()
                        }) {
                            Text("Reset")
                                .font(.system(size: geometry.size.width * 0.03)) // Adjust font size based on width
                        }
                        .buttonStyle(NeomorphicButtonStyle(buttonColor: Color.black, fontColor: Color.white)) // Apply neomorphic button style
                        
                        Spacer()
                    }
                    .padding()
                    
                    
                }
                .background(Color.black.edgesIgnoringSafeArea(.all)) // Set background color to black
                .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                    let timeDifference = Date().timeIntervalSince(lastStateChangeTime)
                    
                    // Sleep app if no activity in last 600 seconds
                    if timeDifference > 600 && UIScreen.main.brightness != 0 {
                        UIScreen.main.brightness = 0
                    }
                }
                .overlay {
                    // Gear button
                    SettingButton(isSettingsVisible: $isSettingsVisible)
                }
            }
            else {
                // If IPhone is landscape mode do this horizontal view
                HStack {
                    VStack {
                        GaugeWidget(isSpeedDisplayed: $isSpeedDisplayed, viewModel: viewModel)
                        
                        Spacer()
                        
                        SpeedPowerToggle(isSpeedDisplayed: $isSpeedDisplayed)
                            .padding()
                        
                    }
                    
                    VStack {
                        NeomorphicTable(viewModel: viewModel)
                        
                        Spacer()
                        
                        // Buttons for start/pause and reset
                        HStack {
                            Spacer()
                            if viewModel.isTimerRunning {
                                Button(action: {
                                    viewModel.stopTimer()
                                }) {
                                    Image(systemName: "pause.fill") // Use system image for Pause action
                                        .font(.system(size: geometry.size.width * 0.03)) // Adjust font size based on width
                                }
                                .buttonStyle(NeomorphicButtonStyle(buttonColor: Color.red, fontColor: Color.white)) // Apply neomorphic button style
                            } else {
                                Button(action: {
                                    viewModel.startTimer()
                                }) {
                                    Image(systemName: "play.fill") // Use system image for Start action
                                        .font(.system(size: geometry.size.width * 0.03)) // Adjust font size based on width
                                }
                                .buttonStyle(NeomorphicButtonStyle(buttonColor: Color.green, fontColor: Color.white)) // Apply neomorphic button style
                            }
                            
                            Spacer(minLength: 10).frame(maxWidth: 20) // Add spacer with maximum length of 50
                            
                            Button(action: {
                                viewModel.resetTimer()
                            }) {
                                Text("Reset")
                                    .font(.system(size: geometry.size.width * 0.03)) // Adjust font size based on width
                            }
                            .buttonStyle(NeomorphicButtonStyle(buttonColor: Color.black, fontColor: Color.white)) // Apply neomorphic button style
                            
                            Spacer()
                        }
                        .padding()
                    }
                    Spacer()
                    
                }
                .background(Color.black.edgesIgnoringSafeArea(.all)) // Set background color to black
                .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                    let timeDifference = Date().timeIntervalSince(lastStateChangeTime)
                    
                    // Sleep app if no activity in last 600 seconds
                    if timeDifference > 600 && UIScreen.main.brightness != 0 {
                        UIScreen.main.brightness = 0
                    }
                }
                .overlay {
                    // Gear button
                    SettingButton(isSettingsVisible: $isSettingsVisible)
                }
            }
            
        }
        .onAppear {
            print("  onAppear")
            updateWidthSize()
        }
        .onChange(of: horizontalSizeClass) { _ in
            print("  onChange HorizontalSizeClass:\(horizontalSizeClass)")
            updateWidthSize()
        }
        .onTapGesture {
            if UIScreen.main.brightness == 0 {
                UIScreen.main.brightness = 1
                lastStateChangeTime = Date()
            }
            
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    LoadingViewControllerRepresentable(isLoading: $viewModel.isLoading,
                                                       bikeMessage: $viewModel.bikeMessage)
                }
                
            }
        )
        .fullScreenCover(isPresented: $isSettingsVisible) {
            // Present your SettingsView here
            SettingsView(isVisible: $isSettingsVisible, viewModel: viewModel)
        }
        
    }
    
    
    
    
    private func updateWidthSize() {
        if horizontalSizeClass == .compact && verticalSizeClass == .regular {
            // iPhone portrait layout
            print("DISPLAY: iPhone portrait")
            gaugeSize = GaugeSize.small
            headerSize = HeaderSize.small
            metricSize = MetricSize.small
            
            isIPhoneLandscape = false
            
        } else if horizontalSizeClass == .compact && verticalSizeClass == .compact {
            // iPhone landscape layout
            print("DISPLAY: iPhone landscape")
            gaugeSize = GaugeSize.small
            headerSize = HeaderSize.small
            metricSize = MetricSize.small
            isIPhoneLandscape = true
            
            
        } else if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            // iPad portrait and landscape layout
            print("DISPLAY: iPad landscape or portrait")
            gaugeSize = GaugeSize.large
            headerSize = HeaderSize.large
            metricSize = MetricSize.large
            isIPhoneLandscape = false
        } else if horizontalSizeClass == .regular && verticalSizeClass == .compact {
            // iPhone SOMETHING
            print("DISPLAY: iPhone something")
            gaugeSize = GaugeSize.medium
            headerSize = HeaderSize.medium
            metricSize = MetricSize.medium
            isIPhoneLandscape = false
        } else {
            // iPhone SOMETHING
            print("DISPLAY: Unknown")
            isIPhoneLandscape = false
        }
    }
}

struct SettingsView: View {
    @Binding var isVisible: Bool
    @State private var selectedPowerFormat = ConfigurationManager.shared.isWattUnit ? "watt" : "joule"
    @State private var selectedDistanceUnit = ConfigurationManager.shared.isKMUnit ? "km" : "mi"
   
    @State private var errorMessage = ""
    
 // @StateObject var viewModel: SimulatedExerciseBike
  @StateObject var viewModel: ExerciseBike

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
                        Spacer()
                        Text("Power")
                            .frame(width: 50, alignment: .trailing)
                        Picker("", selection: $selectedPowerFormat) {
                            Text("Watt").tag("watt")
                            Text("Joule").tag("joule")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        Text("Unit")
                            .frame(width: 50, alignment: .trailing)
                        Picker("", selection: $selectedDistanceUnit) {
                            Text("Kilometer").tag("km")
                            Text("Mile").tag("mi")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        Spacer()
                    }
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
                    print("SAVE PRESSED")
                    
                    // Accessing the shared instance of ConfigurationManager
                    let configMgr = ConfigurationManager.shared
                
                    // Check the selected time format
                    if selectedPowerFormat == "watt" {
                            print("Watt format selected")
                            configMgr.isWattUnit = true
                    } else if selectedPowerFormat == "joule" {
                            print("Joule format selected")
                            configMgr.isWattUnit = false
                        
                    }
                    
                    // Check the distance format
                    if selectedDistanceUnit == "km" {
                            print("KM format selected")
                            configMgr.isKMUnit = true
                    } else if selectedDistanceUnit == "mi" {
                            print("Mile format selected")
                            configMgr.isKMUnit = false
                        
                    }
                    
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

struct SpeedPowerToggle: View {
    @Binding var isSpeedDisplayed: Bool
    
    var body: some View {
        HStack {
            Text("Powermeter")
                .font(.system(size: CGFloat(headerSize)))
                .foregroundColor(isSpeedDisplayed ? .gray : .white) // Set font color based on isSpeedDisplayed
                .padding(.trailing, CGFloat(headerSize)) // Apply trailing padding for Speed label
            
            Toggle("", isOn: $isSpeedDisplayed)
                .labelsHidden()
                .padding(.horizontal, 5) // Adjust horizontal padding for the Toggle button
            
            Text("Speedometer")
                .font(.system(size: CGFloat(headerSize)))
                .foregroundColor(isSpeedDisplayed ? .white : .gray) // Set font color based on isSpeedDisplayed
                .padding(.leading, CGFloat(headerSize)) // Apply leading padding for Power label
        }
        .padding(20) // Apply padding around the HStack
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .cornerRadius(10)
    }
}


// Define a neomorphic button style
struct NeomorphicButtonStyle: ButtonStyle {
    let buttonColor: Color
    let fontColor: Color
    let isRectangle: Bool
    
    init(buttonColor: Color, fontColor: Color, isRectangle: Bool = true) {
          self.buttonColor = buttonColor
          self.fontColor = fontColor
          self.isRectangle = isRectangle
      }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                Group {
                    if isRectangle {
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(buttonColor)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 2, y: 2)
                            .shadow(color: Color.white.opacity(0.7), radius: 5, x: -2, y: -2)
                        
                    }  else {
                        Circle()
                            .fill(buttonColor)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 2, y: 2)
                            .shadow(color: Color.white.opacity(0.7), radius: 5, x: -2, y: -2)
                    }
                }
            )
            .foregroundColor(fontColor)
            .font(.headline)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Add scale effect on press
    }
}

struct NeomorphicTable: View {
 //  @ObservedObject var viewModel: SimulatedExerciseBike
       @ObservedObject var viewModel: ExerciseBike
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    HeaderCell(text: "Timer")
                    HeaderCell(text: "Distance")
                    HeaderCell(text: "Total Power")
                    HeaderCell(text: "Cadence")
                    HeaderCell(text: "Level")
                    
                }
                .padding(.vertical, 0)
                
                
                HStack {
                    TableCell(text: viewModel.exerciseData.formattedTime, alignment: .center)
                        .padding(.vertical, 1)
                        .neumorphicStyle()
                    TableCell(text: String(format: "%.2f km", viewModel.exerciseData.totalDistance), alignment: .center)
                        .padding(.vertical, 1)
                        .neumorphicStyle()
                    TableCell(text: String(format: "%.2f watts", viewModel.exerciseData.totalPower), alignment: .center)
                        .padding(.vertical, 1)
                        .neumorphicStyle()
                    TableCell(text: "\(Int(viewModel.exerciseData.cadence)) rpm", alignment: .center)
                        .padding(.vertical, 1)
                        .neumorphicStyle()
                    TableCell(text: "\(Int(viewModel.exerciseData.resistance))", alignment: .center)
                        .padding(.vertical, 1)
                        .neumorphicStyle()
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    HeaderCell(text: "")
                    HeaderCell(text: "Cadence")
                    HeaderCell(text: "Power")
                    HeaderCell(text: "Speed")
                }
                .padding(.vertical, 0)
                
                
                HStack {
                    Spacer()
                    HeaderCell(text: "Max:", alignment: .trailing)
                        .padding(.horizontal, 3)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    TableCell(text: "\(Int(viewModel.exerciseData.maximumCadence)) rpm", alignment: .center)
                        .padding(.vertical, 1)
                        .neumorphicStyle()
                    
                    TableCell(text: "\(Int(viewModel.exerciseData.maximumPower)) watts", alignment: .center)
                        .padding(.vertical, 1)
                        .neumorphicStyle()
                    TableCell(text: "\(Int(viewModel.exerciseData.maximumSpeed)) kph", alignment: .center)
                        .padding(.vertical, 1)
                        .neumorphicStyle()
                }
                
            }
            .padding()
        }
    }
}

struct HeaderCell: View {
    var text: String
    var alignment: Alignment = .bottom
    
    var body: some View {
        Text(text)
            .font(.system(size: CGFloat(headerSize)))
            .foregroundColor(Color.white)
            .frame(maxWidth: .infinity, alignment: alignment)
            .padding(.bottom, 3)
    }
}

struct TableCell: View {
    var text: String
    var alignment: Alignment
    
    var body: some View {
        Text(text)
            .font(.system(size: CGFloat(metricSize)))
            .foregroundColor(Color.white)
            .frame(maxWidth: .infinity, alignment: alignment)
    }
}
// Neumorphic Style Modifier
extension View {
    func neumorphicStyle() -> some View {
        self.padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black)
                    .shadow(color: Color.white.opacity(0.2), radius: 5, x: -2, y: -2)
                    .shadow(color: Color.black.opacity(0.7), radius: 5, x: 2, y: 2)
            )
    }
}

struct BikeInfoView: View {
    let title: String
    let value: Double
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
            Text("\(value)")
                .font(.body)
                .foregroundColor(.black)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

struct GaugeWidget: View {
    @Binding var isSpeedDisplayed: Bool
//    @ObservedObject var viewModel: SimulatedExerciseBike
        @ObservedObject var viewModel: ExerciseBike
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black)
                .frame(width: CGFloat(gaugeSize + 50), height: CGFloat(gaugeSize + 50))
                .shadow(color: Color.white.opacity(0.2), radius: 10, x: -5, y: -5)
                .shadow(color: Color.black.opacity(0.7), radius: 10, x: 5, y: 5)
            
            GaugeView(value: isSpeedDisplayed ? viewModel.exerciseData.speed : viewModel.exerciseData.currentPower,
                      minValue: 0,
                      maxValue: isSpeedDisplayed ? 40 : 1000,
                      unit: isSpeedDisplayed ? "kph" : "watts") // kph: kilometers per hour, wph: watts per hour
            .frame(width: CGFloat(gaugeSize), height: CGFloat(gaugeSize)) // Set size of the gauge
            .padding()
            .font(.system(size: CGFloat(metricSize * 2))) // Adjust font size based on width
        }
    }
}


struct GaugeView: View {
    var value: Double
    var minValue: Double
    var maxValue: Double
    var unit: String // Unit of measurement (e.g., kph, watts)
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: CGFloat(value / maxValue))
                .stroke(LinearGradient(gradient: Gradient(colors: [.red, .blue]), startPoint: .leading, endPoint: .trailing), lineWidth: 40)
                .rotationEffect(.degrees(90))
                .padding(10)
            
            VStack {
                Text("\(Int(value))")
                    .font(.system(size: circleFontSize() * 0.30)) // Set font size based on circle dimensions
                    .fontWeight(.bold)
                    .foregroundColor(.white) // Set text color to black
                
                Text("\(unit)")
                    .font(.system(size: circleFontSize() * 0.10)) // Set font size to 50% of value font size
                    .foregroundColor(.white) // Set text color to black
            }
        }
    }
    
    // Calculate font size based on the dimensions of the Circle
    private func circleFontSize() -> CGFloat {
        let radius = CGFloat(gaugeSize/2) // Set the radius of the Circle
        let circumference = 2 * CGFloat.pi * radius // Calculate the circumference
        let fontSize = circumference / CGFloat(unit.count) // Adjust font size based on the length of the unit
        return fontSize
    }
}


struct LoadingViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var isLoading: Bool
    @Binding var bikeMessage: String
    
    func makeUIViewController(context: Context) -> UIViewController {
        let loadingVC = LoadingViewController(bikeMessage: $bikeMessage)
        
        loadingVC.bikeMessage = self.$bikeMessage
        return loadingVC
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isLoading {
            //     print("LOADING is TRUE")
            (uiViewController as? LoadingViewController)?.showLoadingScreen()
        } else {
            //        print("LOADING is FALSE")
            (uiViewController as? LoadingViewController)?.removeLoadingScreen()
        }
    }
}



class LoadingViewController: UIViewController {
    var bikeMessage: Binding<String>
    
    // Initializer that accepts a Binding<String>
    init(bikeMessage: Binding<String>) {
        self.bikeMessage = bikeMessage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingScreen()
    }
    
    func setupLoadingScreen() {
        let loadingView = UIView(frame: UIScreen.main.bounds)
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.center = loadingView.center
        activityIndicator.startAnimating()
        
        loadingView.addSubview(activityIndicator)
        
        // Add bike message label
        let bikeMessageLabel = UILabel(frame: CGRect(x: 0, y: activityIndicator.frame.maxY + 20, width: 400, height: 50))
        
        //    print("LOADING SCREEN: bikeMessage:\(bikeMessage)")
        bikeMessageLabel.text = bikeMessage.wrappedValue
        bikeMessageLabel.textColor = .white
        bikeMessageLabel.textAlignment = .center
        bikeMessageLabel.center.x = loadingView.center.x
        
        loadingView.addSubview(bikeMessageLabel)
        
        
        view.addSubview(loadingView)
    }
    
    func removeLoadingScreen() {
        DispatchQueue.main.async {
            self.view.subviews.filter({ $0 is UIView }).forEach({
                $0.removeFromSuperview()
            })
        }
    }
    
    
    
    func showLoadingScreen() {
        DispatchQueue.main.async {
            self.setupLoadingScreen()
        }
    }
}



// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
    
}
