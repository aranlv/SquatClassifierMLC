//
//  TutorialView.swift
//  SquatClassifierMLC
//
//  Created by Aretha Natalova Wahyudi on 14/06/25.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct TutorialView: View {
    @ObservedObject var navigationViewModel: AppNavigationViewModel
//    @ObservedObject var voiceManager: VoiceCommandManager
    @StateObject private var viewModel: TutorialViewModel
    
    init(navigationViewModel: AppNavigationViewModel) {
        self.navigationViewModel = navigationViewModel
        self._viewModel = StateObject(wrappedValue: TutorialViewModel(navigationViewModel: navigationViewModel))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer().frame(height: 60)
                        
                        VStack {
                            WebView(url: URL(string: "https://youtube.com/embed/lRYBbchqxtI?autoplay=1&mute=1&controls=1")!)
                                .frame(height: 300)
                                .cornerRadius(12)
                            Text("Normal Barbell Squat")
                                .font(.title)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .padding(.vertical, 15)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .firstTextBaseline) {
                                    Text("1.")
                                        .font(.body)
                                        .foregroundColor(.gray)
                                        .frame(width: 20, alignment: .leading)
                                    VStack(alignment: .leading) {
                                        Text("Position feet shoulder-width apart, toes slightly out.")
                                            .font(.body)
                                            .foregroundColor(.white)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer()
                                }
                                HStack(alignment: .firstTextBaseline) {
                                    Text("2.")
                                        .font(.body)
                                        .foregroundColor(.gray)
                                        .frame(width: 20, alignment: .leading)
                                    VStack(alignment: .leading) {
                                        Text("Keep spine neutral and core braced throughout.")
                                            .font(.body)
                                            .foregroundColor(.white)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer()
                                }
                                HStack(alignment: .firstTextBaseline) {
                                    Text("3.")
                                        .font(.body)
                                        .foregroundColor(.gray)
                                        .frame(width: 20, alignment: .leading)
                                    VStack(alignment: .leading) {
                                        Text("Squat to knee level, keeping knees over toes.")
                                            .font(.body)
                                            .foregroundColor(.white)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer()
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                        
                        Spacer().frame(height: 100)
                    }
                }
                
                VStack {
                    HStack(alignment: .center) {
                        Button(action: {
                            print("Back button tapped in TutorialView") // Debug print
                            viewModel.navigateToHome()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.title2)
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Text("TUTORIAL")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .baselineOffset(-2)
                        
                        Spacer()
                        
                        Text("")
                            .font(.headline)
                            .foregroundColor(.clear)
                            .frame(width: 60)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Color.black
                            .ignoresSafeArea(edges: .top)
                    )
                    Spacer()
                }
                .zIndex(2)
                
                VStack {
                    Button(action: {
                        print("Start button tapped in TutorialView") // Debug print
                        viewModel.navigateToSteps()
                    }) {
                        Text("Start")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color("Lime", bundle: nil))
                            .cornerRadius(12)
                            .padding(.horizontal, 30)
                    }
                    .padding(.bottom, 10)
                    .padding(.top, 20)
                    .shadow(radius: 5)
                }
                .background(Color.black.opacity(1))
                .zIndex(1)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            print("TutorialView appeared") // Debug print
        }
    }
}

struct Step1View: View {
    @ObservedObject var navigationViewModel: AppNavigationViewModel
    @State private var showCameraWithPoses: Bool = false
    @StateObject private var voiceManager = VoiceCommandManager()
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: -30) {
                    Spacer().frame(height: 100)
                    
                    VStack(spacing: 15) {
                        Text("Step 1")
                            .font(.largeTitle)
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
                        
                        Image("step1")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .padding(.horizontal, 30)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(spacing: 15) {
                                Image(systemName: "tshirt.fill")
                                    .foregroundColor(Color("Lime", bundle: nil))
                                    .frame(width: 30, height: 30)
                                    .background(Color.green.opacity(0.2))
                                    .clipShape(Circle())
                                
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
                                Image(systemName: "headphones")
                                    .foregroundColor(Color("Lime", bundle: nil))
                                    .frame(width: 30, height: 30)
                                    .background(Color.green.opacity(0.2))
                                    .clipShape(Circle())
                                
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
                        .padding(.horizontal, 30)
                        
                        Button(action: {
                            print("Skip button tapped in Step1View") // Debug print
                            showCameraWithPoses = true
                        }) {
                            Text("Skip")
                                .font(.headline)
                                .foregroundColor(Color("Lime", bundle: nil))
                                .frame(maxWidth: .infinity)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(12)
                                .padding(.horizontal, 30)
                        }
                        .padding(.bottom, 10)
                        .padding(.top, 10)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showCameraWithPoses) {
            CameraWithPosesAndOverlaysView(voiceManager: voiceManager)
                .onAppear {
                    print("CameraWithPosesAndOverlaysView presented from Step1View")
                }
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
    @State private var showCameraWithPoses: Bool = false
    @StateObject private var voiceManager = VoiceCommandManager()
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: -30) {
                    Spacer().frame(height: 100)
                    
                    VStack(spacing: 15) {
                        Text("Step 2")
                            .font(.largeTitle)
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
                        
                        Button(action: {
                            print("Skip button tapped in Step2View") // Debug print
                            showCameraWithPoses = true
                        }) {
                            Text("Skip")
                                .font(.headline)
                                .foregroundColor(Color("Lime", bundle: nil))
                                .frame(maxWidth: .infinity)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(12)
                                .padding(.horizontal, 30)
                        }
                        .padding(.bottom, 10)
                        .padding(.top, 10)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showCameraWithPoses) {
            CameraWithPosesAndOverlaysView(voiceManager: voiceManager)
                .onAppear {
                    print("CameraWithPosesAndOverlaysView presented from Step2View")
                }
        }
        .background(Color.black)
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .onAppear {
            print("Step2View appeared") // Debug print
        }
    }
}

struct Step3View: View {
    @ObservedObject var navigationViewModel: AppNavigationViewModel
    @StateObject private var voiceManager = VoiceCommandManager()
    @State private var showCameraWithPoses: Bool = false
    
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
                                .font(.largeTitle)
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
                            
                            Image("step3")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                                .padding(.horizontal, 30)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                HStack(spacing: 15) {
                                    Image(systemName: "mic.fill")
                                        .foregroundColor(Color("Lime", bundle: nil))
                                        .frame(width: 30, height: 30)
                                        .background(Color.green.opacity(0.2))
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Say \"Start Workout\"")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Text("Stand in position and say this to begin your workout")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    
                                    Spacer()
                                }
                                
                                HStack(spacing: 15) {
                                    Image(systemName: "mic.fill")
                                        .foregroundColor(Color("Lime", bundle: nil))
                                        .frame(width: 30, height: 30)
                                        .background(Color.green.opacity(0.2))
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Say \"End Workout\"")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Text("Say this when you finish your workout or complete a set")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .padding(.horizontal, 30)
                        }
                        
                        Spacer().frame(height: 150)
                    }
                }
                
                VStack {
                    Button(action: {
                        print("I'm Ready button tapped in Step3View") // Debug print
                        showCameraWithPoses = true
                    }) {
                        Text("I'm Ready")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color("Lime", bundle: nil))
                            .cornerRadius(12)
                            .padding(.horizontal, 30)
                    }
                    .padding(.bottom, 10)
                    .shadow(radius: 5)
                }
                .background(
                    Color.black.opacity(1)
                )
                .zIndex(1)
            }
            .fullScreenCover(isPresented: $showCameraWithPoses) {
                CameraWithPosesAndOverlaysView(voiceManager: voiceManager)
                    .onAppear {
                        print("CameraWithPosesAndOverlaysView presented from Step3View") // Debug print
                    }
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

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView(navigationViewModel: AppNavigationViewModel())
            .preferredColorScheme(.dark)
    }
}
