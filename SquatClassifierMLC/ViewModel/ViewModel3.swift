//  ViewModel.swift
//  SquatClassifierMLC
//
//  Created by Aretha Natalova Wahyudi on 15/06/25.

import SwiftUI
import CreateMLComponents
import AsyncAlgorithms
import CoreML
import CoreGraphics
import Foundation

class ViewModel: ObservableObject {
    @Published var liveCameraImageAndPoses: (image: CGImage, poses: [Pose])?
    @Published var predictedAction: String?
    var uiCount: Float = 0.0

    // MARK: Constants & Tuneables
    private let requiredFrames     = 60
    private let maxRepsInMemory    = 10
    private let kneeDownThreshold  = 110.0
    private let kneeUpThreshold    = 150.0

    // MARK: - [REVISION] Shoulder tracking vars
    private var shoulderTopY: CGFloat = 0
    private var shoulderBottomY: CGFloat = .greatestFiniteMagnitude
    private let shoulderMotionDelta: CGFloat = 0.05

    private lazy var classifier: SquatClassification = {
        do { return try SquatClassification(configuration: MLModelConfiguration()) }
        catch { fatalError("❌ Could not load SquatClassification.mlmodelc — \(error)") }
    }()
    private let poseExtractor = HumanBodyPoseExtractor()

    private var configuration = VideoReader.CameraConfiguration()
    private var displayCameraTask: Task<Void, Error>?

    private enum SquatState { case standing, squatting, unknown }
    private var squatState: SquatState = .unknown
    private var repCount   = 0
    private var frameBuffer: [[Pose]] = []
    private var selectedRepWindow: [[[Pose]]] = []

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

    private func displayPoseInCamera() async throws {
        let frames = try await VideoReader.readCamera(configuration: configuration)
        print("🎬 Camera pipeline started — awaiting frames…")
        var lastTime = CFAbsoluteTimeGetCurrent()

        for try await frame in frames {
            if Task.isCancelled { return }

            let allPoses = try await poseExtractor.applied(to: frame.feature)

            // MARK: - [REVISION] Always use the largest person
            let sortedPoses = allPoses.sorted { $0.boundingBoxArea() > $1.boundingBoxArea() }
            guard let person = sortedPoses.first else { continue }
            let poses = [person]

            // MARK: - [REVISION] Add shoulder detection to rep logic
            if
                let hip      = person.keypoints[.leftHip]?.location,
                let knee     = person.keypoints[.leftKnee]?.location,
                let ankle    = person.keypoints[.leftAnkle]?.location,
                let shoulder = person.keypoints[.leftShoulder]?.location,
                person.keypoints[.leftHip]?.confidence ?? 0 > JointPoint.confidenceThreshold,
                person.keypoints[.leftKnee]?.confidence ?? 0 > JointPoint.confidenceThreshold,
                person.keypoints[.leftAnkle]?.confidence ?? 0 > JointPoint.confidenceThreshold,
                person.keypoints[.leftShoulder]?.confidence ?? 0 > JointPoint.confidenceThreshold {

                let angle = calculateKneeAngle(hip: hip, knee: knee, ankle: ankle)
                print(String(format: "📐 Angle: %.2f | ShoulderY: %.6f | Baseline: %.6f", angle, shoulder.y, shoulderTopY))

                switch squatState {
                    case .unknown:
                        if angle > kneeUpThreshold {
                            squatState = .standing
                            shoulderTopY = shoulder.y
                            shoulderBottomY = .greatestFiniteMagnitude
                            print("🟢 Initialized to standing")
                        }

                    case .standing:
                        if angle < kneeDownThreshold {
                            squatState = .squatting
                            shoulderBottomY = shoulder.y
                            print("⬇️ Transitioned to squatting")
                        }

                    case .squatting:
                        shoulderBottomY = min(shoulderBottomY, shoulder.y)
                        if angle > kneeUpThreshold {
                            let shoulderRise = shoulder.y - shoulderBottomY
                            if shoulderRise > shoulderMotionDelta {
                                squatState = .standing
                                repCount += 1
                                await MainActor.run { self.uiCount = Float(repCount) }
                                print("✅ REP \(repCount) counted")

                                selectedRepWindow.append(frameBuffer)
                                if selectedRepWindow.count > maxRepsInMemory {
                                    selectedRepWindow.removeFirst(selectedRepWindow.count - maxRepsInMemory)
                                }

                                classifyRep(buffer: frameBuffer)
                                frameBuffer.removeAll()
                            }
                        }
                }

                frameBuffer.append(poses)
            }

            if let cgImage = CIContext().createCGImage(frame.feature, from: frame.feature.extent) {
                await display(image: cgImage, poses: poses)
            }

            let now = CFAbsoluteTimeGetCurrent()
            print(String(format: "Frame rate %2.2f fps", 1 / (now - lastTime)))
            lastTime = now
        }
    }

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

    private func resample(_ poses: [[Pose]], to n: Int) -> [[Pose]] {
        guard !poses.isEmpty else { return Array(repeating: [], count: n) }
        guard poses.count != n else { return poses }
        let step = Double(poses.count - 1) / Double(max(n - 1, 1))
        return (0..<n).map { poses[Int(round(Double($0) * step))] }
    }

    @MainActor private func display(image: CGImage, poses: [Pose]) {
        self.liveCameraImageAndPoses = (image, poses)
    }

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

