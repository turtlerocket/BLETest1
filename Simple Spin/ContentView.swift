import SwiftUI

import UIKit

import Combine

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
  //  @ObservedObject var viewModel = SimulatedExerciseBike()
  //  @ObservedObject var viewModel = SleepingBike()
    
    @ObservedObject var demoModel = DemoExpirationViewModel()
 
    @State private var isSpeedDisplayed = true // Toggle between speed and power
    
    // Defines how long before last state change - if more than 10 minutes, sleep screen
    @State private var lastStateChangeTime = Date()
    
    @State private var isLoading = true
    //    @State private var isIPhoneLandscape: Bool = false
    //    @State private var isIPad = true
    
    @State private var isSubscriptionViewVisible = false
    
    @State private var isSettingsVisible = false
    
    @StateObject var orientationController = OrientationDetectionController()
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    
    init() {
        viewModel.connectDevice()
        
        // Simulate ALREADY subscribed - comment out for production depoyment
        // Note that isSubscribed should be set in production by the
        // DemoExpirationManager.shared.hasValidSubscription
  //      demoModel.isSubscribed = true
    }
    
    var body: some View {
        
        GeometryReader {    geometry in
            if (!orientationController.isIPhoneLandscape) {
                VStack {
                    GaugeWidget(isSpeedDisplayed: $isSpeedDisplayed, viewModel: viewModel)
                    
                    Spacer()
                    
                    SpeedPowerToggle(isSpeedDisplayed: $isSpeedDisplayed)
                    
                    
                    if !demoModel.isSubscribed {
                        
                        HStack {
                            Text("Expires on \(demoModel.demoExpirationDate)")
                                .foregroundColor(.white)
                            
                            Button(action: {
                                // Handle subscription action
                                isSubscriptionViewVisible = true
                            }) {
                                Text("Subscribe Now")
                            }
                        }
                        
                    }
                    
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
                    let currentTime = Date()
                    let timeDifference = currentTime.timeIntervalSince(lastStateChangeTime)
                    
                    // If Sleep Time is NOT Never, check for when to sleep
                    if (viewModel.sleepTime != -1) {
                         //       print("  Sleep time is: \(Double(viewModel.sleepTime * 60)) sec")
                           //   print("  timeDifference: \(timeDifference) sec")
                            //print("  UIScreen.main.brightness: \(UIScreen.main.brightness)")
                        
                        // If the bike is in action in last 5 seconds, automatically wake up the app
                        
                        // Sleep app if no activity in last Sleep Time (min)
                        if ((timeDifference > Double(viewModel.sleepTime * 60)) && (UIScreen.main.brightness > 0)) {
                            print("  SLEEPING screen from sleeping timeout; brightness: \(UIScreen.main.brightness)")
                            UIScreen.main.brightness = 0
                        }
                        else if (timeDifference < Double(viewModel.sleepTime * 60)) {
                            if (UIScreen.main.brightness == 0) {
                                print("  WAKING screen from sleeping timeout")
                                UIScreen.main.brightness = 1
                                lastStateChangeTime = Date()
                            }}
                    }
                    else {
                        // If sleep time is NEVER, always be sure brightness on
                        if (UIScreen.main.brightness == 0) {
                            print("  ALWAYS Awake - WAKING SCREEN")
                            UIScreen.main.brightness = 1
                            lastStateChangeTime = Date()
                        }}
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
                        
                        
                        SpeedPowerToggle(isSpeedDisplayed: $isSpeedDisplayed)
                        
                        
                        if !demoModel.isSubscribed {
                           
                            HStack {
                                Text("Expires on \(demoModel.demoExpirationDate)")
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    // Handle subscription action
                                    isSubscriptionViewVisible = true
                                }) {
                                    Text("Subscribe Now")
                                }
                            }
                        }
                        
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
                .overlay {
                    // Gear button
                    SettingButton(isSettingsVisible: $isSettingsVisible)
                }
            }
            
        }
        .onAppear {
            //  print("  onAppear")
            //        updateWidthSize()
        }
        .onChange(of: horizontalSizeClass) {
            print("  onChange HorizontalSizeClass:\(horizontalSizeClass)")
            updateWidthSize()
        }
        .onChange(of: viewModel.exerciseData.cadence) {
            if (UIScreen.main.brightness == 0) {
                print("  WAKING screen from cadence change!!")
                UIScreen.main.brightness = 1
            }
            
            // Always update the last StateChangeTime if there is activity on the bike
            lastStateChangeTime = Date()
        }
        .onTapGesture {
            print("Screen tapped with UIScreen.main.brightness: \(UIScreen.main.brightness)")
            if UIScreen.main.brightness < 1 {
                
                print("  TAP - WAKING up screen")
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
        .fullScreenCover(isPresented: $isSubscriptionViewVisible) {
            
            SubscriptionView(isVisible: $isSubscriptionViewVisible, isDemoExpired: $demoModel.isDemoExpired)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .padding()
            
            
        }
        
    }
    
    
    
    
    private func updateWidthSize() {
        
        // If an IPhone, check whether portrait or landscape
        if (!orientationController.isIPad) {
            //         if horizontalSizeClass == .compact && verticalSizeClass == .regular {
            
            if (!orientationController.isIPhoneLandscape) {
                // iPhone portrait layout
                print("DISPLAY: iPhone portrait")
                gaugeSize = GaugeSize.small
                headerSize = HeaderSize.small
                metricSize = MetricSize.small
                
                //   } else if horizontalSizeClass == .compact && verticalSizeClass == .compact {
                //     // iPhone landscape layout
            } else {
                print("DISPLAY: iPhone landscape")
                gaugeSize = GaugeSize.small
                headerSize = HeaderSize.small
                metricSize = MetricSize.small
            }
            
        }
        else {
            //else if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            // iPad portrait and landscape layout
            print("DISPLAY: iPad landscape or portrait")
            gaugeSize = GaugeSize.large
            headerSize = HeaderSize.large
            metricSize = MetricSize.large
        }
        
        
    }
    /*
     else if horizontalSizeClass == .regular && verticalSizeClass == .compact {
     // iPhone SOMETHING
     print("DISPLAY: iPhone something")
     gaugeSize = GaugeSize.medium
     headerSize = HeaderSize.medium
     metricSize = MetricSize.medium
     
     isIPad = false
     
     } else {
     // iPhone SOMETHING
     print("DISPLAY: Unknown")
     }
     */
    
    
}

extension TimeInterval {
    func formattedTimeString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .full
        
        return formatter.string(from: self) ?? ""
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
                    TableCell(text: String(format: "%.2f \(viewModel.isKMUnit ? "km" : "mi")", convertDistance(viewModel.exerciseData.totalDistance)), alignment: .center)
                        .padding(.vertical, 1)
                        .neumorphicStyle()
                    TableCell(text: String(format: "%.2f watt", viewModel.exerciseData.totalPower), alignment: .center)
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
                    
                    TableCell(text: "\(Int(viewModel.exerciseData.maximumPower)) watt", alignment: .center)
                        .padding(.vertical, 1)
                        .neumorphicStyle()
                    TableCell(text: "\(Int(convertSpeed(viewModel.exerciseData.maximumSpeed))) \(viewModel.isKMUnit ? "km/h" : "mi/h")", alignment: .center)
                        .padding(.vertical, 1)
                        .neumorphicStyle()
                }
                
            }
            .padding()
        }
    }
    
    func convertSpeed(_ speed: Double) -> Double {
        if self.viewModel.isKMUnit {
            // Speed is already in KM
            return speed
        } else {
            // Convert KM to MI
            return speed * 0.621371
        }
    }
    
    func convertDistance(_ distance: Double) -> Double {
        if self.viewModel.isKMUnit {
            // Distance is already in KM
            return distance
        } else {
            // Convert KM to MI
            return distance * 0.621371
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
    //   @Binding var isKMFlag: Bool // Flag to determine if speed is in KM or MI
    @ObservedObject var viewModel: ExerciseBike
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black)
                .frame(width: CGFloat(gaugeSize + 50), height: CGFloat(gaugeSize + 50))
                .shadow(color: Color.white.opacity(0.2), radius: 10, x: -5, y: -5)
                .shadow(color: Color.black.opacity(0.7), radius: 10, x: 5, y: 5)
            
            GaugeView(value: isSpeedDisplayed ? convertSpeed(viewModel.exerciseData.speed) : viewModel.exerciseData.currentPower,
                      minValue: 0,
                      maxValue: isSpeedDisplayed ? (viewModel.isKMUnit ? 70 : 45) : 1000,
                      unit: isSpeedDisplayed ? (viewModel.isKMUnit ? "km/h" : "mi/h") : "watts")
            .frame(width: CGFloat(gaugeSize), height: CGFloat(gaugeSize)) // Set size of the gauge
            .padding()
            .font(.system(size: CGFloat(metricSize * 2))) // Adjust font size based on width
        }
    }
    
    func convertSpeed(_ speed: Double) -> Double {
        if self.viewModel.isKMUnit {
            //    print("GaugeWidget: Unit is KM convert")
            
            // Speed is already in KM
            return speed
        } else {
            //  print("GaugeWidget: Unit is miles convert")
            // Convert KM to MI
            return speed * 0.621371
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

class OrientationDetectionController: ObservableObject {
    var isIPad: Bool = false
    var isIPhoneLandscape: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        setupOrientationDetection()
    }
    
    private func setupOrientationDetection() {
        // Check device type
        isIPad = UIDevice.current.userInterfaceIdiom == .pad
        
        // Initial orientation check
        updateOrientation()
        
        // Add observer for orientation changes
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { _ in
                self.updateOrientation()
            }
            .store(in: &cancellables)
    }
    
    private func updateOrientation() {
        if isIPad {
            //           print("iPad MODE")
            isIPhoneLandscape = false
        } else {
            if UIDevice.current.orientation.isLandscape {
                //      print("iPhone LANDSCAPE MODE")
                isIPhoneLandscape = true
            } else {
                //     print("iPhone PORTRAIT MODE")
                isIPhoneLandscape = false
            }
        }
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
            
            // If screen sleeping, wake it up
            if (UIScreen.main.brightness == 0) {
                print("  WAKING Controller screen")
                UIScreen.main.brightness = 1
            }
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
        
        // Register for notifications when the app enters background or foreground
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // Disable the idle timer initially
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        
        
    }
    
    // Function to handle app entering background
    @objc func appDidEnterBackground() {
        // Enable the idle timer when app enters background
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // Function to handle app entering foreground
    @objc func appWillEnterForeground() {
        // Disable the idle timer when app enters foreground
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    deinit {
        // Remove observers
        NotificationCenter.default.removeObserver(self)
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
