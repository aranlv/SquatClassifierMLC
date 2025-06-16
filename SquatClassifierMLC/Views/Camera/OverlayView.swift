/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 The app's overlay view.
 */

import SwiftUI

/// - Tag: OverlayView
struct OverlayView: View {
    
    let count: Float
    let actionLabel: String?
    let flip: () -> Void
    
    var body: some View {
        VStack {
            // Top‑left bubble – Reps
            HStack {
                Spacer()
                VStack(spacing: 4) {
                    Text("Reps")
                        .font(.title2).bold()
                        .foregroundColor(.white)
                    Text("\(count, specifier: "%2.0f")")
                        .font(.system(size: 40, weight: .heavy))
                        .foregroundColor(.green)
                }
                .bubbleBackground()
                
                // Middle bubble – action label
                if let label = actionLabel {
                    Spacer(minLength: 12)
                    Text(formatLabelForSpeech(label))
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                        .bubbleBackground()
                        .transition(.opacity)
                }
                Spacer()
            }
            .padding(.top, 16)
            
            if actionLabel == "Listening…" {
                Text("🎧 Listening…")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 10)
            }
            
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
        .padding()
    }
}

extension View {
    /// Semi‑transparent rounded rectangle behind any view.
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
        ZStack {
            Color.red.opacity(0.3)
            OverlayView(count: 3, actionLabel: "Squat", flip: {})
        }
    }
}
