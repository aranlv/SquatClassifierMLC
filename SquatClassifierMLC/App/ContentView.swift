//
//  ContentView.swift
//  SquatClassifierMLC
//
//  Created by Aretha Natalova Wahyudi on 12/06/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var navigationViewModel = AppNavigationViewModel()
    @StateObject private var voiceManager = VoiceCommandManager()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                switch navigationViewModel.currentDestination {
                case .home:
                    HomeView(navigationViewModel: navigationViewModel)
                case .tutorial:
                    TutorialView(navigationViewModel: navigationViewModel)
                case .step1, .step2, .step3:
                    StepView(navigationViewModel: navigationViewModel, voiceManager: voiceManager)
                case let .summary(total, good):
                    SummaryView(
                        totalReps: total,
                        goodForm:  good,
                        badForm:   max(0, total - good),
                        navigationViewModel: navigationViewModel
                    )
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
    }
}
