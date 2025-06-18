//
//  ContentView.swift
//  SquatClassifierMLC
//
//  Created by Aretha Natalova Wahyudi on 12/06/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var navigationViewModel = AppNavigationViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                switch navigationViewModel.currentDestination {
                case .home:
                    HomeView(navigationViewModel: navigationViewModel)
                case .tutorial:
                    TutorialView(navigationViewModel: navigationViewModel)
                case .step1, .step2, .step3:
                    ZStack(alignment: .top) {
                        TabView(selection: $navigationViewModel.currentDestination) {
                            Step1View(navigationViewModel: navigationViewModel)
                                .tag(NavigationDestination.step1)
                            Step2View(navigationViewModel: navigationViewModel)
                                .tag(NavigationDestination.step2)
                            Step3View(navigationViewModel: navigationViewModel)
                                .id(navigationViewModel.restartFromSummary ? AnyHashable(UUID()) : AnyHashable("step3"))
                                .tag(NavigationDestination.step3)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        
                        VStack {
                            HStack {
                                Button(action: {
                                    navigationViewModel.navigate(to: .home)
                                }) {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                        .padding()
                                        .background(Color.black.opacity(0.3))
                                        .clipShape(Circle())
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    Capsule()
                                        .fill(navigationViewModel.currentDestination == .step1 ? Color.white : Color.white.opacity(0.3))
                                        .frame(width: 16, height: 8)
                                    Capsule()
                                        .fill(navigationViewModel.currentDestination == .step2 ? Color.white : Color.white.opacity(0.3))
                                        .frame(width: 16, height: 8)
                                    Capsule()
                                        .fill(navigationViewModel.currentDestination == .step3 ? Color.white : Color.white.opacity(0.3))
                                        .frame(width: 16, height: 8)
                                }
                                
                                Spacer()
                                
                                Text("")
                                    .font(.headline)
                                    .foregroundColor(.clear)
                                    .frame(width: 60)
                            }
                            .padding(.horizontal, 20)
                            .background(
                                Color.black.opacity(0.7)
                                    .blur(radius: 10)
                                    .ignoresSafeArea(edges: .top))
                        }
                    }
                }
            }
        }
        .environmentObject(navigationViewModel)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
