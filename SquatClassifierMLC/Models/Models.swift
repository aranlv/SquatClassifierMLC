//
//  NavigationDestination.swift
//  ReForm
//
//  Created by Muhammad HAFIZH on 12/06/25.
//

import Foundation

// MARK: - Models
struct SquatFormData {
    var isCorrectForm: Bool = true
    var forwardLeanAngle: Double = 0.0
    var squatDepth: Double = 0.0
    var feedback: String = ""
}

enum NavigationDestination: Equatable {
    case home
    case tutorial
    case step1
    case step2
    case step3
}
