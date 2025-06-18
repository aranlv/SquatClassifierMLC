///*
// See LICENSE folder for this sample’s licensing information.
//
// Abstract:
// The app's overlay view.
// */
//
import SwiftUI

/// - Tag: OverlayView
struct OverlayView: View {
    
    @ObservedObject var viewModel: SquatViewModel
    let flip: () -> Void
    let stopAction: () -> Void
    
    var body: some View {
        VStack {
            // Action label and reps
            HStack {
                // Exit button
                Button(action: stopAction) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding()
                        .clipShape(Circle())
                }
                
                // Reps
                HStack(spacing: 4) {
                    Text("Rep")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text("\(viewModel.repCount)")
                        .font(.title2).bold()
                        .foregroundColor(.white)
                }
                .opacity(0.60)
                .bubbleBackground()
                
                // Action Label
                if viewModel.actionLabel != "Start" {
                    Text(viewModel.actionLabel)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .opacity(0.60)
                        .bubbleBackground()
                }
                
                Spacer()
            }
            .padding(.top, 25)
            
            
            Spacer()
            
            // Bottom‑left flip button
            HStack {
                Button(action: flip) {
                    Label("Flip", systemImage: "arrow.triangle.2.circlepath.camera.fill")
                        .labelStyle(.iconOnly)
                        .foregroundColor(.primary)
                        .bubbleBackground()
                }
                Spacer()
            }
        }
        .padding(30)
    }
}

extension View {
    /// Semi‑transparent rounded rectangle behind any view.
    func bubbleBackground() -> some View {
        self.padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(red: 2/255, green: 2/255, blue: 2/255, opacity: 0.6))
            }
    }
}

//struct OverlayView_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack {
//            Color.red.opacity(0.3)
//            OverlayView(
//        }
//        .edgesIgnoringSafeArea([.top, .bottom])
//    }
//}
