//
//  SpinBike.swift
//
//  Created by Benjamin  Dai on 2/17/24.
//

import Foundation

protocol SpinBike: ObservableObject {
    var exerciseData: ExerciseBikeData { get }
    var isTimerRunning: Bool { get }
    var isLoading: Bool { get }
    var bikeMessage: String { get }
    var isWattUnit: Bool { get set }
    var isKMUnit: Bool { get set }
    
    func startTimer()
    func stopTimer()
    func resetTimer()
}
