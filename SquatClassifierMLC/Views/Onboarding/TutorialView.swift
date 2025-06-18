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
                .background(
                    Color.black
                )
                
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

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView(navigationViewModel: AppNavigationViewModel())
            .preferredColorScheme(.light)
    }
}

