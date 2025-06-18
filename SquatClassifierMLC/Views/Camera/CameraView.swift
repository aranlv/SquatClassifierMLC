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
    
    var body: some View {
        ZStack {
            if let renderedImage = viewModel.renderedImage {
                Image(uiImage: renderedImage)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(10)
            } else {
                Text("Waiting for camera feed...")
                    .font(.headline)
            }
            
            OverlayView(viewModel: viewModel, flip: {
                viewModel.toggleCamera()
            }, stopAction: {
                viewModel.stopCamera()
                navigationViewModel.navigate(to: .home)
            })
        }
        .edgesIgnoringSafeArea([.top, .bottom])
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
