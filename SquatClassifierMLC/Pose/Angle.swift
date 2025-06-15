//
//  PoseMath.swift
//  SquatClassifierMLC
//
//  Created by Angeline Rachel on 14/06/25.
//

import CoreGraphics
import Foundation

/// Calculates the angle at the knee formed by hip-knee-ankle joints
/// Returns angle in degrees (0° to 180°)
func calculateKneeAngle(hip: CGPoint, knee: CGPoint, ankle: CGPoint) -> CGFloat {
    let vectorA = CGVector(dx: hip.x - knee.x, dy: hip.y - knee.y)
    let vectorB = CGVector(dx: ankle.x - knee.x, dy: ankle.y - knee.y)

    let dotProduct = vectorA.dx * vectorB.dx + vectorA.dy * vectorB.dy
    let magnitudeA = sqrt(vectorA.dx * vectorA.dx + vectorA.dy * vectorA.dy)
    let magnitudeB = sqrt(vectorB.dx * vectorB.dx + vectorB.dy * vectorB.dy)

    guard magnitudeA > 0, magnitudeB > 0 else { return 0 }

    let cosineAngle = dotProduct / (magnitudeA * magnitudeB)
    let angleRadians = acos(max(min(cosineAngle, 1), -1)) // Clamp to avoid NaN
    let angleDegrees = angleRadians * 180 / .pi

    return angleDegrees
}
