//
//  CountdownView.swift
//  SquatClassifierMLC
//
//  Created by Aretha Natalova Wahyudi on 18/06/25.
//

import SwiftUI
import Combine

struct CountdownView: View {
    @Binding var isShowing: Bool
    @State private var value = 5
    @State private var timer = Timer.publish(every: 1.5, on: .main, in: .common)
        .autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            Text("\(value)")
                .font(.system(size: 100, weight: .bold))
                .foregroundColor(.white)
                .transition(.opacity)
                .padding(.leading, -35)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(timer) { _ in
            if value > 1 {
                value -= 1
                // voiceManager.speakCountdown(number: countdownValue)
            } else {
                timer.upstream.connect().cancel()
                withAnimation { isShowing = false }
            }
        }
        .onAppear {
            value = 5
        }
    }
}

struct CountdownView_Previews: PreviewProvider {
    static var previews: some View {
        CountdownView(isShowing: .constant(true))
    }
}
