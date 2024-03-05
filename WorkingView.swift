//
//  WorkingView.swift
//  Simple Spin
//
//  Created by Benjamin  Dai on 3/5/24.
//

import Foundation
import SwiftUI

struct WorkingView: View {
    @Binding var isWorking: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                
                // Customize your working animation view
                ProgressView("Working...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}
