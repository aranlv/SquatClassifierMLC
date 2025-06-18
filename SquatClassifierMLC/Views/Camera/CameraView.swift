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
                    navigationViewModel.navigate(to: .home)
                })
                
                if showCountdown {
                    CountdownView(isShowing: $showCountdown)
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
        }
        .onDisappear(){
            viewModel.stopCamera()
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
