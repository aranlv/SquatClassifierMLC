//
//  HomeView.swift
//  SquatClassifierMLC
//
//  Created by Aretha Natalova Wahyudi on 14/06/25.
//
import SwiftUI

struct HomeView: View {
    @ObservedObject var navigationViewModel: AppNavigationViewModel
    @StateObject private var viewModel: HomeViewModel
    
    init(navigationViewModel: AppNavigationViewModel) {
        self.navigationViewModel = navigationViewModel
        self._viewModel = StateObject(wrappedValue: HomeViewModel(navigationViewModel: navigationViewModel))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("Home")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                Color.black.opacity(0.4)
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Text("Refine Every Rep")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Better posture, Safer squats, Real-time feedback to reach your fitness goals.")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                        
                        VStack(spacing: 15) {
                            Button(action: {
                                print("Start button tapped in HomeView") // Debug print
                                viewModel.navigateToSteps()
                            }) {
                                Text("Start")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color("Lime", bundle: nil))
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                            }
                            
                            Button(action: {
                                print("Tutorial button tapped in HomeView") // Debug print
                                viewModel.navigateToTutorial()
                            }) {
                                Text("Tutorial")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                    
                    Spacer()
                        .frame(height: 100)
                }
            }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .onAppear {
            print("HomeView appeared") // Debug print
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(navigationViewModel: AppNavigationViewModel())
            .preferredColorScheme(.dark)
    }
}
