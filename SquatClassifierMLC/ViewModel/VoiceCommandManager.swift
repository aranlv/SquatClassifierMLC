//
//  VoiceCommandManager.swift
//  SquatClassifierMLC
//
//  Created by Patricia Putri Art Syani on 15/06/25.
//

import Foundation
import AVFoundation
import Speech

class VoiceCommandManager: NSObject, ObservableObject, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate {
    
    // MARK: - Published Properties
    @Published var isWorkoutRunning: Bool = false
    @Published var lastCommand: String = ""
    @Published var isListening: Bool = false
    weak var viewModel: ViewModel?
    
    // MARK: - Private Properties
    private var lastRecognizedPhrase: String = ""
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    // MARK: - Init
    override init() {
        super.init()
        speechSynthesizer.delegate = self
    }

    // MARK: - Permissions
    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                print("🎙️ Speech permission: \(status)")
            }
        }
    }

    // MARK: - Listening
    func startListening() {
        stopListening()
        isListening = true
        lastCommand = ""

        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker])
        try? audioSession.setActive(true)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.inputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                let command = result.bestTranscription.formattedString.lowercased()
                print("🗣️ Heard: \(command)")

                guard command != self.lastRecognizedPhrase else { return }
                self.lastRecognizedPhrase = command

                // ✅ Listen only for "finish"
                if command.contains("finish") && self.isWorkoutRunning {
                    self.isWorkoutRunning = false

                    Task { @MainActor in
                        self.viewModel?.stopWorkout()
                        self.viewModel?.repCount = 0
                        self.viewModel?.uiCount = 0
                        self.viewModel?.navigateToSummary = true
                    }

                    self.lastRecognizedPhrase = "" // Reset for next command
                }

                // 🔁 Restart recognition if final result
                if result.isFinal {
                    print("🔁 Speech result is final — restarting recognition")
                    self.restartRecognitionAfterDelay()
                }
            } else if let error = error {
                print("❌ Speech error: \(error.localizedDescription)")
                self.restartRecognitionAfterDelay()
            }
        }
    }

    private func restartRecognitionAfterDelay() {
        stopListening()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.startListening()
        }
    }

    func stopListening() {
        isListening = false

        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        recognitionTask?.cancel()
        recognitionTask = nil
    }

    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }

    // MARK: - Speech
    func speak(_ text: String) {
        print("📢 Speaking: \(text)")
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        speechSynthesizer.speak(utterance)
    }

    func speakCountdown(number: Int) {
        let utterance = AVSpeechUtterance(string: "\(number)")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        speechSynthesizer.speak(utterance)
    }

    func speakStartWorkout() {
        let utterance = AVSpeechUtterance(string: "GO")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.6
        speechSynthesizer.speak(utterance)
    }
}
