//
//  SquatClassifierMLCApp.swift
//  SquatClassifierMLC
//
//  Created by Aretha Natalova Wahyudi on 12/06/25.
//

import SwiftUI

@main
struct SquatClassifierMLCApp: App {
    @StateObject private var navModel = AppNavigationViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navModel)
        }
    }
}
