

import SwiftUI

struct ContentView: View {
    @StateObject var exerciseBike = ExerciseBike()
    @State private var currentTime = Date()
    @State private var isTimerStarted = false
    
    // Timer to update current time every minute
    private let internalTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    // DateFormatter for current time
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "tortoise")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding(.leading, 20)
                Spacer()
    //            Text("\(currentTime, formatter: dateFormatter)")
                    .padding(.trailing, 20)
            }
            
            Spacer()
            
            // Display exercise bike information
            Text("Cadence: \(Int(exerciseBike.cadence)) RPM")
            Text("Resistance: \(Int(exerciseBike.resistance))")
            Text("Speed: \(String(format: "%.2f", exerciseBike.speed)) mph")
            Text("Current Power: \(Int(exerciseBike.power)) Watts")
            Text("Total Power: \(Int(exerciseBike.totalPower)) Watts")
            Text("Timer: \(exerciseBike.timerValue) seconds")
            Text("Total Distance: \(String(format: "%.2f", exerciseBike.totalDistance)) miles")
            
            Spacer()
            
            // Buttons to control timer and reset values
            HStack {
                Button(action: {
                    isTimerStarted.toggle()
                    if isTimerStarted {
                        exerciseBike.startTimer()
                    } else {
                        exerciseBike.stopTimer()
                    }
                }) {
                    Text(isTimerStarted ? "Stop Timer" : "Start Timer")
                        .padding()
                }
                
                Button(action: {
                    exerciseBike.reset()
                }) {
                    Text("Reset")
                        .padding()
                }
            }
            .padding()
        }
        .onReceive(internalTimer) { _ in
      //      currentTime = Date()
       //     debugPrint("UPDATED current date time: \(currentTime)")
            //exerciseBike.updateBikingNumbers()
        }
        .onAppear {
          //  exerciseBike.updateBikingNumbers()
            
            // Update cadence and resistance every 2 seconds
    //        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
              //  exerciseBike.updateBikingNumbers()
        //    }
        }
    }
}
/*
struct ContentView: View {
    @StateObject var exerciseBike = ExerciseBike()
    
    var body: some View {
        VStack {
            Text("Cadence: \(exerciseBike.cadence)")
            Text("Resistance: \(exerciseBike.resistance)")
            Text("Power: \(exerciseBike.power)")
            Spacer()
            Text("Current Time: \(exerciseBike.currentTime)")
                .padding(.top, 20)
                .padding(.trailing, 20)
        }
        .onAppear {
            exerciseBike.startScan()
        }
    }
}
*/

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
