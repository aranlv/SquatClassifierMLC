///*
//See LICENSE folder for this sample’s licensing information.
//
//Abstract:
//The app's camera view.
//*/
//
import SwiftUI

struct CameraView: View {
    @StateObject var viewModel = SquatViewModel()
    @ObservedObject var navigationViewModel = AppNavigationViewModel()
    @ObservedObject var voiceManager = VoiceCommandManager()
    @State private var showCountdown = true
    
    var body: some View {
        ZStack {
            if let renderedImage = viewModel.renderedImage {
                Image(uiImage: renderedImage)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                OverlayView(viewModel: viewModel, flip: {
                    viewModel.toggleCamera()
                }, stopAction: {
                    viewModel.stopCamera()
                    navigationViewModel.navigate(to: .summary(total:viewModel.repCount, good: viewModel.goodFormCount))
                })
                
                if showCountdown {
                    CountdownView(voiceManager: voiceManager, isShowing: $showCountdown)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                        .zIndex(2)
                        .transition(.opacity)
                }
                
            } else {
                Text("Waiting for camera feed...")
                    .font(.headline)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.startCamera()
            UIApplication.shared.isIdleTimerDisabled = true
            voiceManager.onFinishCommand = {
                self.handleFinishCommand()
            }
            voiceManager.startListening()
        }
        .onDisappear(){
            viewModel.stopCamera()
            UIApplication.shared.isIdleTimerDisabled = false
            voiceManager.stopListening()
        }
    }
    
    private func handleFinishCommand() {
        print("Finish command received!")
        navigationViewModel.navigate(to: .summary(total:viewModel.repCount, good: viewModel.goodFormCount))
    }
}

//struct CameraView_Previews: PreviewProvider {
//    static var previews: some View {
//        CameraView()
//    }
//}
