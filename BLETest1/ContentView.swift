import SwiftUI

import UIKit

// Main ContentView
struct ContentView: View {
    // For now swap ExcerciseBike for SimulatedExerciseBike
    // TODO: Refactor ExerciseBike and SimulatedExerciseBike to have same Bike super-class
    @StateObject var viewModel = ExerciseBike()
  //  @StateObject var viewModel = SimulatedExerciseBike()

    @State private var isSpeedDisplayed = true // Toggle between speed and power
    @State private var widthSize: CGFloat = 10.0 // Declare widthSize as a state variable
    // Defines how long before last state change - if more than 10 minutes, sleep screen
    @State private var lastStateChangeTime = Date()
    
    @State private var isLoading = true

    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 350, height: 350)
                        .shadow(color: Color.white.opacity(0.2), radius: 10, x: -5, y: -5)
                        .shadow(color: Color.black.opacity(0.7), radius: 10, x: 5, y: 5)
                    
                    GaugeView(value: isSpeedDisplayed ? viewModel.exerciseData.speed : viewModel.exerciseData.currentPower,
                              minValue: 0,
                              maxValue: isSpeedDisplayed ? 40 : 1000,
                              unit: isSpeedDisplayed ? "kph" : "watts") // kph: kilometers per hour, wph: watts per hour
                        .frame(width: 300, height: 300) // Set size of the gauge
                        .padding()
                        .font(.system(size: geometry.size.width * 0.05)) // Adjust font size based on width
                }

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
                        .onTapGesture {
                            if UIScreen.main.brightness == 0 {
                                UIScreen.main.brightness = 1
                                lastStateChangeTime = Date()
                            }
                        }
        }
        .onAppear {
            updateWidthSize()
        }
        .onChange(of: horizontalSizeClass) { _ in
            updateWidthSize()
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    LoadingViewControllerRepresentable(isLoading: $viewModel.isLoading)
                }
            }
        )
    }
            
    
    
    
    private func updateWidthSize() {
        if horizontalSizeClass == .compact && verticalSizeClass == .regular {
            widthSize = 20 // Adjust font size for compact width, regular height
        } else if horizontalSizeClass == .regular && verticalSizeClass == .compact {
            widthSize = 40
        } else {
            widthSize = 30 // Default font size for other size classes
        }
    }
}

struct SpeedPowerToggle: View {
    @Binding var isSpeedDisplayed: Bool

    var body: some View {
        HStack {
            Text("Powermeter")
                .font(.system(size: 15))
                .foregroundColor(isSpeedDisplayed ? .gray : .white) // Set font color based on isSpeedDisplayed
                .padding(.trailing, 15) // Apply trailing padding for Speed label

            Toggle("", isOn: $isSpeedDisplayed)
                .labelsHidden()
                .padding(.horizontal, 5) // Adjust horizontal padding for the Toggle button

            Text("Speedometer")
                .font(.system(size: 15))
                .foregroundColor(isSpeedDisplayed ? .white : .gray) // Set font color based on isSpeedDisplayed
                .padding(.leading, 15) // Apply leading padding for Power label
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

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(buttonColor)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 2, y: 2)
                    .shadow(color: Color.white.opacity(0.7), radius: 5, x: -2, y: -2)
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
                    HeaderCell(text: "Resistance")
                  
                }
                .padding(.vertical, 0)
            

                HStack {
                    TableCell(text: viewModel.exerciseData.formattedTime, alignment: .center)
                    TableCell(text: String(format: "%.2f", viewModel.exerciseData.totalDistance), alignment: .center)
                    TableCell(text: String(format: "%.2f", viewModel.exerciseData.totalPower), alignment: .center)
                    TableCell(text: "\(Int(viewModel.exerciseData.cadence))", alignment: .center)
                    TableCell(text: "\(Int(viewModel.exerciseData.resistance))", alignment: .center)
                }
                .padding(.vertical, 8)
                .neumorphicStyle()
                
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
                    TableCell(text: "Max:", alignment: .trailing)
                        .padding(.horizontal, 3)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    TableCell(text: "\(Int(viewModel.exerciseData.maximumCadence))", alignment: .center)
                        .padding(.vertical, 3)
                        .neumorphicStyle()
                    
                    TableCell(text: "\(Int(viewModel.exerciseData.maximumPower))", alignment: .center)
                        .padding(.vertical, 3)
                        .neumorphicStyle()
                    TableCell(text: "\(Int(viewModel.exerciseData.maximumSpeed))", alignment: .center)
                        .padding(.vertical, 3)
                        .neumorphicStyle()
                }
                    
            }
            .padding()
        }
    }
}

struct HeaderCell: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundColor(Color.white)
            .frame(maxWidth: .infinity, alignment: .bottom)
            .padding(.bottom, 8)
    }
}

struct TableCell: View {
    var text: String
    var alignment: Alignment

    var body: some View {
        Text(text)
            .font(.system(size: 12))
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
        let radius = CGFloat(150) // Set the radius of the Circle
        let circumference = 2 * CGFloat.pi * radius // Calculate the circumference
        let fontSize = circumference / CGFloat(unit.count) // Adjust font size based on the length of the unit
        return fontSize
    }
}


struct LoadingViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var isLoading: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        return LoadingViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isLoading {
            (uiViewController as? LoadingViewController)?.showLoadingScreen()
        } else {
            (uiViewController as? LoadingViewController)?.removeLoadingScreen()
        }
    }
}



class LoadingViewController: UIViewController {

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
