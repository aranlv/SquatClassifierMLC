//
//  CountdownOverlayView.swift
//  SquatClassifierMLC
//
//  Created by Patricia Putri Art Syani on 17/06/25.
//

import SwiftUI
import AVFoundation

struct CountdownView: View {
    @Binding var countdown: Int
    let viewModel: ViewModel
    var onFinished: () -> Void

    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            // Show live camera if available
            if let image = viewModel.liveCameraImageAndPoses?.image {
                CameraView(cameraImage: image)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
            
            // Countdown number
            Text("\(countdown)")
                .font(.system(size: 100, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.7), radius: 10, x: 0, y: 5)
                .transition(.opacity)
                .animation(.easeOut(duration: 0.2), value: countdown)
        }
        .onAppear {
            startCountdown()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startCountdown() {
        playTickSound()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                if countdown > 1 {
                    countdown -= 1
                    playTickSound()
                } else {
                    timer?.invalidate()
                    onFinished()
                }
            }
        }
    }

    private func playTickSound() {
        AudioServicesPlaySystemSound(1104) // Built-in "Tock" sound
    }
}
