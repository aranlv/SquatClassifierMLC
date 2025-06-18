//
//  StepViews.swift
//  SquatClassifierMLC
//
//  Created by Aretha Natalova Wahyudi on 18/06/25.
//

import SwiftUI

struct StepView: View {
    @ObservedObject var navigationViewModel: AppNavigationViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $navigationViewModel.currentDestination) {
                Step1View(navigationViewModel: navigationViewModel)
                    .tag(NavigationDestination.step1)
                Step2View(navigationViewModel: navigationViewModel)
                    .tag(NavigationDestination.step2)
                Step3View(navigationViewModel: navigationViewModel)
                    .tag(NavigationDestination.step3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)
            
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
                    
                    if navigationViewModel.currentDestination != .step3 {
                        NavigationLink(
                            destination: CameraView(navigationViewModel: navigationViewModel)
                        ) {
                            Text("Skip")
                                .font(.headline)
                                .foregroundColor(.lime)
                                .frame(width: 60)
                        }
                    } else {
                        Text("")
                            .font(.headline)
                            .foregroundColor(.lime)
                            .frame(width: 60)
                    }
                }
                .padding(.horizontal, 20)
                .background(
                    Color.black)
            }
        }
    }
}

struct Step1View: View {
    @ObservedObject var navigationViewModel: AppNavigationViewModel
    
    var body: some View {
        ZStack (alignment: .bottom) {
            ScrollView {
                VStack(spacing: -30) {
                    Spacer().frame(height: 100)
                    
                    VStack(spacing: 15) {
                        Text("Step 1")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 30)
                        
                        Text("Prepare yourself for more accurate tracking")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 30)
                            .padding(.top, -10)
                        
                        Image("step1")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .padding(.horizontal, 30)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(spacing: 15) {
                                Image("wear")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 70)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Wear Fitted Clothing")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text("Avoid baggy outfits for more accurate tracking")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 15) {
                                Image("earphone")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 70)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Use earphone")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    //                                        .fixedSize(horizontal: false, virtual: true)
                                    Text("For accurate voice commands and better real-time feedback")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                                Spacer()
                            }
                        }
                        .frame(width: 320)
                        .padding(.horizontal, 30)
                    }
                }
            }
            
            Button {
                navigationViewModel.navigate(to: .step2)
            } label: {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color("Lime", bundle: nil))
                    .cornerRadius(12)
                    .padding(.horizontal, 30)
                    .shadow(radius: 5)
                    .padding(.bottom, 60)
            }
            .background(Color.black.opacity(1))
            .zIndex(1)
        }
        .background(Color.black)
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .onAppear {
            print("Step1View appeared") // Debug print
        }
    }
}

struct Step2View: View {
    @ObservedObject var navigationViewModel: AppNavigationViewModel
    
    var body: some View {
        ZStack (alignment: .bottom) {
            ScrollView {
                VStack(spacing: -30) {
                    Spacer().frame(height: 100)
                    
                    VStack(spacing: 15) {
                        Text("Step 2")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 30)
                        Text("Place your phone on provided tripod")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 30)
                            .padding(.top, -10)

                        
                        Image("step2")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal, 30)
                        
                        Text("Set your phone on the tripod and position yourself at a 45° angle")
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 30)
                    }
                }
            }
            
            Button {
                navigationViewModel.navigate(to: .step3)
            } label: {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color("Lime", bundle: nil))
                    .cornerRadius(12)
                    .padding(.horizontal, 30)
                    .shadow(radius: 5)
                    .padding(.bottom, 60)
            }
            .background(Color.black.opacity(1))
            .zIndex(1)
        }
        .background(Color.black)
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .onAppear {
            print("Step2View appeared")
        }
    }
}

struct Step3View: View {
    @ObservedObject var navigationViewModel: AppNavigationViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Color.black
                    .overlay(
                        GeometryReader { proxy in
                            let offset = proxy.frame(in: .global).minY
                            Color.black.opacity(min(max(offset / 100, 0), 0.7))
                                .blur(radius: min(max(offset / 20, 0), 10))
                        }
                    )
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: -30) {
                        Spacer().frame(height: 100)
                        
                        VStack(spacing: 15) {
                            Text("Step 3")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 30)
                            
                            Text("Voice commands to start and end your workout")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 30)
                                .padding(.top, -10)
                            
                            Image("step3")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .padding(.horizontal, 30)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                HStack(spacing: 15) {
                                    Image("startwo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 70, height: 70)
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Tap \"I'm Ready\"")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Text("Tap to start, and make sure your whole body is in frame")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    
                                    Spacer()
                                }
                                
                                HStack(spacing: 15) {
                                    Image("endwo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 70, height: 70)
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Tap X or Say \"Finish\"")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Text("Say “Finish” or Tap (X) button when you end your workout")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .frame(width: 320)
                            .padding(.horizontal, 30)
                        }
                        
                        Spacer().frame(height: 150)
                    }
                }
                
                NavigationLink(
                    destination: CameraView(navigationViewModel: navigationViewModel)
                ) {
                    Text("I'm Ready")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color("Lime", bundle: nil))
                        .cornerRadius(12)
                        .padding(.horizontal, 30)
                        .shadow(radius: 5)
                        .padding(.bottom, 60)
                }
                .background(Color.black.opacity(1))
                .zIndex(1)
            }
        }
        .background(Color.black)
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .onAppear {
            print("Step3View appeared") // Debug print
        }
    }
}

struct Step2View_Previews: PreviewProvider {
    static var previews: some View {
        Step2View(navigationViewModel: AppNavigationViewModel())
            .preferredColorScheme(.light)
    }
}

struct Step1View_Previews: PreviewProvider {
    static var previews: some View {
        Step1View(navigationViewModel: AppNavigationViewModel())
            .preferredColorScheme(.light)
    }
}

struct Step3View_Previews: PreviewProvider {
    static var previews: some View {
        Step3View(navigationViewModel: AppNavigationViewModel())
            .preferredColorScheme(.light)
    }
}
