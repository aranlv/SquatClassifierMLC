//
//  ViewModels.swift
//  ReForm
//
//  Created by Muhammad HAFIZH on 14/06/25.
//

import Foundation
import Combine

enum NavigationDestination: Equatable {
    case home
    case tutorial
    case step1
    case step2
    case step3
}

// MARK: - ViewModels
class AppNavigationViewModel: ObservableObject {
    @Published var currentDestination: NavigationDestination = .home
    @Published var previousDestination: NavigationDestination = .home
    @Published var restartFromSummary: Bool = false
    
    func navigate(to destination: NavigationDestination) {
        previousDestination = currentDestination
        currentDestination = destination
    }
    
    func goBack() {
        let temp = currentDestination
        currentDestination = previousDestination
        previousDestination = temp
    }
}

class HomeViewModel: ObservableObject {
    private let navigationViewModel: AppNavigationViewModel
    
    init(navigationViewModel: AppNavigationViewModel) {
        self.navigationViewModel = navigationViewModel
    }
    
    func navigateToTutorial() {
        navigationViewModel.navigate(to: .tutorial)
    }
    
    func navigateToSteps() {
        navigationViewModel.navigate(to: .step1)
    }
}

class TutorialViewModel: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var showCorrectForm: Bool = true
    private let navigationViewModel: AppNavigationViewModel
    
    init(navigationViewModel: AppNavigationViewModel) {
        self.navigationViewModel = navigationViewModel
    }
    
    func toggleFormExample() {
        showCorrectForm.toggle()
    }
    
    func navigateToHome() {
        navigationViewModel.navigate(to: .home)
    }
    
    func navigateToSteps() {
        navigationViewModel.navigate(to: .step1)
    }
}
