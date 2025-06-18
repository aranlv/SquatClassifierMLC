//
//  SquatViewModel.swift
//  SquatClassifierMLC
//
//  Created by Aretha Natalova Wahyudi on 17/06/25.
//

import Foundation
import Vision
import Combine
import UIKit

@MainActor
class SquatViewModel: ObservableObject {
    @Published var actionLabel: String = "Starting Up"
    @Published var confidenceLabel: String = "Observing..."
    @Published var renderedImage: UIImage?
    @Published var repCount: Int = 0
    @Published var currentAngle: Double = 0.0
    @Published var goodFormCount: Int = 0 // to be passed to summary view
    
    private var videoCapture: VideoCapture!
    private var videoProcessingChain: VideoProcessingChain!
    private var cancellables = Set<AnyCancellable>()
    
    var actionFrameCounts = [String: Int]()
    
    // MARK: Squat‑counter state machine
    private enum SquatState { case standing, squatting, unknown }
    private var squatState: SquatState = .unknown
    private let kneeDownThreshold  = 110.0      // deg
    private let kneeUpThreshold    = 150.0      // deg
    
    private var shoulderTopY: CGFloat = 0
    private var shoulderBottomY: CGFloat = .greatestFiniteMagnitude
    private var shoulderMotionDelta: CGFloat = 0.05
    
    // total frames seen so far
    private var frameIndex = 0
    
    // store model outputs keyed by the window's last frame index
    private var lastPredictions: [Int: ActionPrediction] = [:]
    
    init() {
        setupPipeline()
    }
    
    deinit {
        cancellables.removeAll()
        videoCapture?.isEnabled = false
        videoCapture = nil
        videoProcessingChain = nil
    }
    
    func cleanup() {
        videoCapture?.isEnabled = false
        cancellables.removeAll()
    }
    
    func setupPipeline() {
        videoProcessingChain = VideoProcessingChain()
        videoProcessingChain.delegate = self
        
        videoCapture = VideoCapture()
        videoCapture.delegate = self
    }
    
    func toggleCamera() {
        videoCapture.toggleCameraSelection()
    }
    
    func updateOrientation() {
        videoCapture.updateDeviceOrientation()
    }
    
    func stopCamera() {
        videoCapture.isEnabled = false
    }
    
    func startCamera() {
        videoCapture.isEnabled = true
    }
    
    private func updateUI(with prediction: ActionPrediction) {
        let rewrittenLabel = rewriteActionLabel(prediction.label)
        actionLabel = rewrittenLabel
        confidenceLabel = prediction.confidenceString ?? "Observing..."
    }
    
    private func rewriteActionLabel(_ rawLabel: String) -> String {
        switch rawLabel {
        case "good":
            return "Good form"
        case "bad_inwards":
            return "Inwards Knees"
        case "bad_toe":
            return "Knees Over Toes"
        default:
            return rawLabel
        }
    }
    
    
    private func drawPoses(_ poses: [Pose]?, onto frame: CGImage) {
        let frameSize = CGSize(width: frame.width, height: frame.height)
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: frameSize, format: rendererFormat)
        
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let inverse = cgContext.ctm.inverted()
            cgContext.concatenate(inverse)
            
            cgContext.draw(frame, in: CGRect(origin: .zero, size: frameSize))
            
            let transform = CGAffineTransform(scaleX: frameSize.width, y: frameSize.height)
            
            poses?.forEach { pose in
                pose.drawWireframeToContext(cgContext, applying: transform)
            }
        }
        
        self.renderedImage = image
        
        if let poses = poses, !poses.isEmpty {
            detectRep(from: poses.first!)
        }
    }
    
    private func detectRep(from pose: Pose) {
        guard let hip = pose.landmarks.first(where: { $0.name == .leftHip })?.location,
              let knee = pose.landmarks.first(where: { $0.name == .leftKnee })?.location,
              let ankle = pose.landmarks.first(where: { $0.name == .leftAnkle })?.location,
        let shoulder = pose.landmarks.first(where: {$0.name == .leftShoulder})?.location else { return }
        
        let angle = calculateKneeAngle(hip: hip, knee: knee, ankle: ankle)
        
        switch squatState {
        case .unknown:
            if angle > kneeUpThreshold {
                squatState = .standing
                shoulderTopY = shoulder.y
                shoulderBottomY = .greatestFiniteMagnitude
                
            }
        case .standing:
            if angle < kneeDownThreshold {
                squatState = .squatting
                shoulderBottomY = shoulder.y
            }
        case .squatting:
            shoulderBottomY = min(shoulderBottomY, shoulder.y)
            if angle > kneeUpThreshold {
                let shoulderRise = shoulder.y - shoulderBottomY
                if shoulderRise > shoulderMotionDelta {
                    squatState = .standing
                    onRepCompleted()
                }
                
            }
        }
    }
    
    private func onRepCompleted() {
        repCount += 1
        
        // find the prediction whose window ended at or just before this frame:
        let key = lastPredictions.keys
            .filter { $0 <= frameIndex }
            .max()
        if let k = key, let pred = lastPredictions[k] {
            // singulated form feedback for this rep:
            actionLabel       = pred.label
            confidenceLabel   = pred.confidenceString ?? ""
            print("💡 Rep \(repCount) form → \(pred.label) (\(pred.confidenceString ?? ""))")
            if pred.label == "good" { goodFormCount += 1 }
            updateUI(with: pred)
        }
        
        // optionally purge old entries:
        lastPredictions.keys
            .filter { $0 < (frameIndex - 60) }
            .forEach { lastPredictions.removeValue(forKey: $0) }
    }
    
    private func addFrameCount(_ count: Int, to label: String) {
        actionFrameCounts[label, default: 0] += count
    }
    
    
}

// MARK: –– Delegates

extension SquatViewModel: VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCreate framePublisher: FramePublisher) {
        updateUI(with: .startingPrediction)
        videoProcessingChain.upstreamFramePublisher = framePublisher
    }
}

extension SquatViewModel: VideoProcessingChainDelegate {
    func videoProcessingChain(_ chain: VideoProcessingChain,
                              didPredict actionPrediction: ActionPrediction,
                              for frameCount: Int) {
        if actionPrediction.isModelLabel {
            addFrameCount(frameCount, to: actionPrediction.label)
        }
        lastPredictions[frameCount] = actionPrediction
    }
    
    func videoProcessingChain(_ chain: VideoProcessingChain,
                              didDetect poses: [Pose]?, in frame: CGImage) {
        frameIndex += 1
        drawPoses(poses, onto: frame)
    }
}
