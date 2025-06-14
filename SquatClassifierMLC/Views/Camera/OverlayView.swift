/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's overlay view.
*/

import SwiftUI

/// - Tag: OverlayView
struct OverlayView: View {

    let count: Float
    let flip: () -> Void

    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    Text("Reps")
                        .font(.title2)
                        .foregroundColor(.white)
                        .bold()
                    Text("\(count, specifier: "%2.0f")")
                        .font(.system(size: 40, weight: .heavy))
                        .foregroundColor(.green)
                }
                .bubbleBackground()
                Spacer()
            }
            .padding(.top, 16)
            
            Spacer()

            HStack {
                Button {
                    flip()
                } label: {
                    Label("Flip", systemImage: "arrow.triangle.2.circlepath.camera.fill")
                        .foregroundColor(.primary)
                        .labelStyle(.iconOnly)
                        .bubbleBackground()
                }

                Spacer()
            }
        }.padding()
    }
}

extension View {
    func bubbleBackground() -> some View {
        self.padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.primary)
                    .opacity(0.4)
            }
    }
}

struct OverlayView_Previews: PreviewProvider {
    static var previews: some View {
        OverlayView(count: 3.0) { }
            .background(Color.red.opacity(0.4))

    }
}
