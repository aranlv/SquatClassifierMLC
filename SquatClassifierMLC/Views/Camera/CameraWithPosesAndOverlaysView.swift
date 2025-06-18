/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's camera with poses and the overlay view.
*/

import SwiftUI

struct CameraWithPosesAndOverlaysView : View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = ViewModel()
    @ObservedObject var voiceManager: VoiceCommandManager
    @EnvironmentObject var navigationViewModel: AppNavigationViewModel
    
    @State private var showCountdown = true
    @State private var countdownValue = 5
    @State private var showExitAlert = false
    var skipAlert: Bool = false
//    @State private var navigateToSummary = false

    var body: some View {
        ZStack {
        // 1. Camera and overlays
        OverlayView(count: viewModel.uiCount, actionLabel: viewModel.predictedAction) {
            viewModel.onCameraButtonTapped()
        }
        .background {
            if let (image, poses) = viewModel.liveCameraImageAndPoses {
                CameraView(
                    cameraImage: image
                )
                .overlay {
                    PosesView(poses: poses)
                }
                .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
        }
            
            // ✅ 2. Countdown overlay
            if showCountdown {
                Color.black.opacity(0.6).ignoresSafeArea()
                
                Text("\(countdownValue)")
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(.white)
                    .transition(.opacity)
                    .onAppear {
                        startCountdown()
                    }
            }
            
            // 3. Top X button
            VStack {
                HStack {
                    Button {
                        showExitAlert = true
                        voiceManager.stopListening()
                        viewModel.isWorkoutActive = false
                        if skipAlert {
                                dismiss()
                            } else {
                                showExitAlert = true
                            }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.white)
                            .padding()
                        
                }
                Spacer()
            }
            Spacer()
        }
    }
        .alert("End Workout?", isPresented: $showExitAlert) {
                    Button("End Workout", role: .destructive) {
                        voiceManager.stopListening()
                        viewModel.isWorkoutActive = false
                        viewModel.navigateToSummary = true
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to end this workout session?")
                }
        .onAppear {
            voiceManager.viewModel = viewModel
            voiceManager.requestPermission()
            voiceManager.startListening()
            //            voiceManager.observe(viewModel: viewModel)
            viewModel.voiceManager = voiceManager
            viewModel.initialize()
        }
        .onChange(of: voiceManager.isWorkoutRunning) { _, isRunning in
            viewModel.isWorkoutActive = isRunning
        }
        .navigationDestination(isPresented: $viewModel.navigateToSummary) {
            SummaryView(
                totalReps: viewModel.repCount,
                goodForm: viewModel.goodFormCount,
                badForm: viewModel.repCount - viewModel.goodFormCount, onRestart: {
                    showCountdown = true
                    viewModel.initialize()
                }
            )
            .environmentObject(navigationViewModel)
        }
    }
    //        .onChange (of: voiceManager.lastCommand) { _, newCommand in
//            if newCommand == "start" {
//                viewModel.isWorkoutActive = true
//            } else if newCommand == "stop" {
//                viewModel.isWorkoutActive = false
//            }
//        }
//        .onChange(of: viewModel.predictedAction) { _, label in
//            guard viewModel.isWorkoutActive,
//                  let label = label,
//                  ["good", "bad_toe", "bad_inwards"].contains(label) else { return }
//
//            let spokenText = label == "good" ? "Good!" : "Bad form"
//            voiceManager.speak(spokenText)
//                }
    private func startCountdown() {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if countdownValue > 1 {
                    countdownValue -= 1
                } else {
                    timer.invalidate()
                    showCountdown = false
                    
                    Task { @MainActor in
                        viewModel.isWorkoutActive = true
                    }
                }
            }
        }
    
}

//struct CameraWithOverlaysView_Previews: PreviewProvider {
//    static var previews: some View {
//        CameraWithPosesAndOverlaysView(voiceManager: )
//    }
//}
