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

    var body: some View {
        ZStack {
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
            }
        }
        
        VStack {
            HStack {
                Button {
                    voiceManager.stopListening()
                    viewModel.isWorkoutActive = false
                    dismiss()
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
        .onAppear {
            voiceManager.viewModel = viewModel
            voiceManager.requestPermission()
            voiceManager.startListening()
//            voiceManager.observe(viewModel: viewModel)
            viewModel.voiceManager = voiceManager
            viewModel.initialize()
        }
        .onChange(of: voiceManager.isWorkoutRunning) { oldValue, newValue in
            viewModel.isWorkoutActive = newValue
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
    }
}

//struct CameraWithOverlaysView_Previews: PreviewProvider {
//    static var previews: some View {
//        CameraWithPosesAndOverlaysView(voiceManager: )
//    }
//}
