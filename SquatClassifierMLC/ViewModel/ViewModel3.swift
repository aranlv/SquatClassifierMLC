//  ViewModel.swift
//  SquatClassifierMLC
//
//  Created by Aretha Natalova Wahyudi on 15/06/25.
//

import SwiftUI
import CreateMLComponents
import AsyncAlgorithms
import CoreML
import CoreGraphics
import Foundation


/// - Tag: ViewModel
class ViewModel: ObservableObject {
    // MARK: UI‑bound @Published properties
    @Published var liveCameraImageAndPoses: (image: CGImage, poses: [Pose])?
    @Published var predictedAction: String?
    var uiCount: Float = 0.0                    // reps shown in the overlay
    
    // MARK: Constants & tuneables
    private let requiredFrames     = 60         // frames fed into the classifier
    private let maxRepsInMemory    = 10         // cap memory usage
    private let kneeDownThreshold  = 110.0      // deg
    private let kneeUpThreshold    = 150.0      // deg
    private let predictionThresh   = 0.70       // min confidence to switch state
    
    // MARK: ML components
    private lazy var classifier: SquatClassification = {
        do { return try SquatClassification(configuration: MLModelConfiguration()) }
        catch { fatalError("❌ Could not load SquatClassification.mlmodelc — \(error)") }
    }()
    private let poseExtractor = HumanBodyPoseExtractor()
    
    // MARK: Camera
    private var configuration = VideoReader.CameraConfiguration()
    private var displayCameraTask: Task<Void, Error>?
    
    // MARK: Squat‑counter state machine
    private enum SquatState { case standing, squatting, unknown }
    private var squatState: SquatState = .unknown
    private var repCount   = 0
    private var frameBuffer: [[Pose]] = []          // frames inside current rep
    private var selectedRepWindow: [[[Pose]]] = []  // last N finished reps (Upgrade A)
    
    // MARK: – Lifecycle helpers
    func initialize() { startVideoProcessingPipeline() }
    
    func onCameraButtonTapped() {
        configuration.position = (configuration.position == .front ? .back : .front)
        uiCount = 0.0
        startVideoProcessingPipeline()
    }
    
    private func startVideoProcessingPipeline() {
        displayCameraTask?.cancel()
        displayCameraTask = Task { try await displayPoseInCamera() }
    }
    
    // MARK: – Main camera loop
    private func displayPoseInCamera() async throws {
        let frames = try await VideoReader.readCamera(configuration: configuration)
        print("🎬 Camera pipeline started — awaiting frames…")
        var lastTime = CFAbsoluteTimeGetCurrent()
        
        for try await frame in frames {
            if Task.isCancelled { return }
            
            // 1. Pose extraction
            let poses = try await poseExtractor.applied(to: frame.feature)
            
            // 2. Squat state machine
            if let person   = poses.first,
               let hip      = person.keypoints[.leftHip]?.location,
               let knee     = person.keypoints[.leftKnee]?.location,
               let ankle    = person.keypoints[.leftAnkle]?.location,
               person.keypoints[.leftHip]?.confidence ?? 0 > JointPoint.confidenceThreshold,
               person.keypoints[.leftKnee]?.confidence ?? 0 > JointPoint.confidenceThreshold,
               person.keypoints[.leftAnkle]?.confidence ?? 0 > JointPoint.confidenceThreshold {
                
                let angle = calculateKneeAngle(hip: hip, knee: knee, ankle: ankle)
                
                switch squatState {
                case .standing where angle < kneeDownThreshold:
                    squatState = .squatting
                    print("⬇️ Squatting…")
                    
                case .squatting where angle > kneeUpThreshold:
                    squatState = .standing
                    repCount += 1
                    await MainActor.run { self.uiCount = Float(repCount) }
                    print("✅ REP \(repCount) finished (\(frameBuffer.count) frames)")
                    
                    // Keep only last N reps
                    selectedRepWindow.append(frameBuffer)
                    if selectedRepWindow.count > maxRepsInMemory {
                        selectedRepWindow.removeFirst(selectedRepWindow.count - maxRepsInMemory)
                    }
                    
                    // Classify this rep once
                    classifyRep(buffer: frameBuffer)
                    
                    frameBuffer.removeAll()           // reset for next rep
                    
                default:
                    if squatState == .unknown && angle > kneeUpThreshold {
                        squatState = .standing
                    }
                }
                
                // Accumulate current frame inside the ongoing rep
                frameBuffer.append(poses)
            }
            
            // 3. UI overlay
            if let cgImage = CIContext().createCGImage(frame.feature, from: frame.feature.extent) {
                await display(image: cgImage, poses: poses)
            }
            
            // 4. FPS debug
            let now = CFAbsoluteTimeGetCurrent()
            print(String(format: "Frame rate %2.2f fps", 1 / (now - lastTime)))
            lastTime = now
        }
    }
    
    // MARK: Rep classification (always‑resample)
    private func classifyRep(buffer: [[Pose]]) {
        guard !buffer.isEmpty else { return }
        let resampled = resample(buffer, to: requiredFrames)
        guard let mlInput = try? makeInputArray(from: resampled),
              let result  = try? classifier.prediction(poses: mlInput) else { return }
        Task { @MainActor in
            self.predictedAction = result.label
            print("🏷️ Rep label → \(result.label)")
        }
    }
    
    // Linear nearest‑index resampler
    private func resample(_ poses: [[Pose]], to n: Int) -> [[Pose]] {
        guard !poses.isEmpty else { return Array(repeating: [], count: n) }
        guard poses.count != n else { return poses }
        let step = Double(poses.count - 1) / Double(max(n - 1, 1))
        return (0..<n).map { poses[Int(round(Double($0) * step))] }
    }
    
    // MARK: – UI helper
    @MainActor private func display(image: CGImage, poses: [Pose]) {
        self.liveCameraImageAndPoses = (image, poses)
    }
    
    // MARK: – MLMultiArray builder (unchanged)
    private func makeInputArray(from window: [[Pose]]) throws -> MLMultiArray {
        let array = try MLMultiArray(shape: [requiredFrames as NSNumber, 3, 18], dataType: .float32)
        let jointOrder: [JointKey] = [.nose,
                                      .leftEye, .rightEye,
                                      .leftEar, .rightEar,
                                      .leftShoulder, .rightShoulder,
                                      .leftElbow, .rightElbow,
                                      .leftWrist, .rightWrist,
                                      .leftHip, .rightHip,
                                      .leftKnee, .rightKnee,
                                      .leftAnkle, .rightAnkle]
        for (t, posesInFrame) in window.enumerated() {
            guard let pose = posesInFrame.first else { continue }
            for (k, jointKey) in jointOrder.enumerated() {
                let base = [NSNumber(value: t), 0, NSNumber(value: k)]
                if let joint = pose.keypoints[jointKey] {
                    array[base] = Float(joint.location.x) as NSNumber
                    array[[NSNumber(value: t), 1, NSNumber(value: k)]] = Float(joint.location.y) as NSNumber
                    array[[NSNumber(value: t), 2, NSNumber(value: k)]] = Float(joint.confidence)  as NSNumber
                } else {
                    array[base] = 0; array[[NSNumber(value: t), 1, NSNumber(value: k)]] = 0; array[[NSNumber(value: t), 2, NSNumber(value: k)]] = 0
                }
            }
        }
        return array
    }
}
