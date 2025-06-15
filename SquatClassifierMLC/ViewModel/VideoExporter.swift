/*
 RepExporter.swift
 -----------------
 A tiny utility that turns a buffer of `[[Pose]]` — the same structure you
 use in `ViewModel` — into a `.mov` clip written to the temporary directory.

 ‣ Works on iOS, iPadOS, macOS Catalyst, or macOS App Kit.
 ‣ Draws a simple stick‑figure skeleton so you can visually verify which
   frames the classifier saw.

 Usage from ViewModel:
 ---------------------
 ```swift
 if debugExport {          // your own flag
     RepExporter.save(rep: frameBuffer, repNumber: repCount)
 }
 ```
 The export runs on the calling queue; invoke it **after** finishing a rep,
 preferably on a background thread if your UI must stay responsive.
*/

import AVFoundation
import CoreGraphics
import CoreVideo
import CreateMLComponents
import UIKit   // iOS / iPadOS / tvOS / visionOS

// MARK: – Public façade
struct RepExporter {

    /// Save one finished rep to a `.mov` in the temporary directory. The
    /// method is synchronous (blocks until `finishWriting`) so wrap it in a
    /// background Task/queue if needed.
    static func save(rep buffer: [[Pose]],
                     repNumber: Int,
                     size: CGSize = .init(width: 1280, height: 720),
                     fps: Int32 = 30) {

        guard !buffer.isEmpty else {
            print("🚫 RepExporter: empty buffer – nothing saved")
            return
        }

        let url = FileManager.default.temporaryDirectory
                     .appendingPathComponent("rep-\(repNumber).mov")

        // Safety: if file exists, remove it
        try? FileManager.default.removeItem(at: url)

        do {
            let writer  = try AVAssetWriter(outputURL: url, fileType: .mov)
            guard let adaptor = makePixelBufferAdaptor(writer: writer, size: size) else {
                print("🚫 RepExporter: could not create pixel-buffer adaptor")
                return
            }

            writer.startWriting()
            writer.startSession(atSourceTime: .zero)

            for (i, poses) in buffer.enumerated() {
                let t = CMTime(value: CMTimeValue(i), timescale: fps)
                if let pb = renderPoses(poses, size: size) {
                    while !adaptor.assetWriterInput.isReadyForMoreMediaData {
                        Thread.sleep(forTimeInterval: 0.002)
                    }
                    adaptor.append(pb, withPresentationTime: t)
                }
            }

            adaptor.assetWriterInput.markAsFinished()
            writer.finishWriting {
                switch writer.status {
                case .completed:
                    print("💾 RepExporter: rep #\(repNumber) saved → \(url.path)")
                case .failed, .cancelled:
                    print("🚫 RepExporter: writer failed –",
                          writer.error?.localizedDescription ?? "unknown error")
                default:
                    break
                }
            }

        } catch {
            print("🚫 RepExporter: AVAssetWriter init failed –", error)
        }
    }
}

// MARK: – Private helpers

private func makePixelBufferAdaptor(writer: AVAssetWriter,
                                    size:   CGSize,
                                    codec:  AVVideoCodecType = .h264)
-> AVAssetWriterInputPixelBufferAdaptor? {

    let settings: [String: Any] = [
        AVVideoCodecKey:  codec.rawValue,
        AVVideoWidthKey:  size.width,
        AVVideoHeightKey: size.height
    ]

    let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
    input.expectsMediaDataInRealTime = false

    guard writer.canAdd(input) else { return nil }
    writer.add(input)

    return AVAssetWriterInputPixelBufferAdaptor(
        assetWriterInput: input,
        sourcePixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String:  size.width,
            kCVPixelBufferHeightKey as String: size.height
        ])
}

/// Renders a very simple stick figure for the first person in `poses`.
/// If you want the real camera frame, swap the clear‑background call with
/// drawing that CGImage first.
private func renderPoses(_ poses: [Pose], size: CGSize) -> CVPixelBuffer? {
    // Allocate pixel buffer
    var pb: CVPixelBuffer?
    guard CVPixelBufferCreate(kCFAllocatorDefault,
                              Int(size.width), Int(size.height),
                              kCVPixelFormatType_32BGRA, nil, &pb) == kCVReturnSuccess,
          let pixelBuffer = pb else { return nil }

    CVPixelBufferLockBaseAddress(pixelBuffer, [])
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }

    guard let base = CVPixelBufferGetBaseAddress(pixelBuffer) else { return nil }

    let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
    guard let ctx = CGContext(data: base,
                               width: Int(size.width), height: Int(size.height),
                               bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                               space: CGColorSpaceCreateDeviceRGB(),
                               bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
    else { return nil }

    // Background
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    ctx.fill(CGRect(origin: .zero, size: size))

    guard let pose = poses.first else { return pixelBuffer }

    // Joints helper closure
    func pt(_ key: JointKey) -> CGPoint? {
        guard let kp = pose.keypoints[key]?.location else { return nil }
        return CGPoint(x: CGFloat(kp.x) * size.width,
                       y: CGFloat(kp.y) * size.height)
    }

    // Draw limbs first (blue lines)
    ctx.setLineWidth(4); ctx.setStrokeColor(CGColor(red: 0, green: 0.5, blue: 1, alpha: 1))
    let limbs: [(JointKey, JointKey)] = [
        (.leftShoulder, .leftElbow), (.leftElbow, .leftWrist),
        (.rightShoulder, .rightElbow), (.rightElbow, .rightWrist),
        (.leftHip, .leftKnee), (.leftKnee, .leftAnkle),
        (.rightHip, .rightKnee), (.rightKnee, .rightAnkle),
        (.leftShoulder, .rightShoulder), (.leftHip, .rightHip),
        (.leftShoulder, .leftHip), (.rightShoulder, .rightHip)
    ]
    for (a, b) in limbs {
        if let pa = pt(a), let pb = pt(b) {
            ctx.move(to: pa); ctx.addLine(to: pb)
        }
    }
    ctx.strokePath()

    // Draw joints (green circles)
    ctx.setFillColor(CGColor(red: 0, green: 0.8, blue: 0.3, alpha: 1))
    for key in pose.keypoints.keys {
        if let p = pt(key) {
            ctx.fillEllipse(in: CGRect(x: p.x - 3, y: p.y - 3, width: 6, height: 6))
        }
    }

    return pixelBuffer
}
