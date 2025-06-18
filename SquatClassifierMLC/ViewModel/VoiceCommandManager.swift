//
//  VoiceCommandManager.swift
//  SquatClassifierMLC
//
//  Created by Patricia Putri Art Syani on 15/06/25.
//

import Foundation
import AVFoundation
import Speech
//import Combine

class VoiceCommandManager: NSObject, ObservableObject, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate {
    @Published var isWorkoutRunning: Bool = false
    @Published var lastCommand: String = ""
    @Published var isListening: Bool = false
    weak var viewModel: ViewModel?
    
//    private var cancellables = Set<AnyCancellable>()
    private var lastRecognizedPhrase: String = ""

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    override init() {
        super.init()
        speechSynthesizer.delegate = self
    }

//    @MainActor
//    func observe(viewModel: ViewModel) {
//            // Speak prediction every time it changes
//            viewModel.predictedActionPublisher
//                .compactMap { $0 }
//                .sink { [weak self] label in
//                    guard let self = self, viewModel.repCount > 0 else { return }
//                    if label == "other_actions" { return } // Skip garbage
//                    self.speak("Reps \(viewModel.repCount), \(label.replacingOccurrences(of: "_", with: " "))")
//                }
//                .store(in: &cancellables)
//    }
    
    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                print("🎙️ Speech permission: \(status)")
            }
        }
    }

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

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, _ in
            guard let result = result else { return }
            let command = result.bestTranscription.formattedString.lowercased()
            print("🗣️ Heard: \(command)")

            // Prevent repeats
                        guard command != self.lastRecognizedPhrase else { return }
                        self.lastRecognizedPhrase = command

                        print("🗣️ Heard: \(command)")

                        if command.contains("start workout") && !self.isWorkoutRunning {
                            self.isWorkoutRunning = true
                            self.speak("Workout started")
                            self.lastCommand = "start"
                            Task { @MainActor in
                                self.viewModel?.startWorkout()
                                }
                            self.lastRecognizedPhrase = ""
                        } else if command.contains("done workout") && self.isWorkoutRunning {
                            self.isWorkoutRunning = false
                            self.speak("Workout ended")
                            //                            self.stopListening()
                            
                            Task { @MainActor in
                                self.viewModel?.stopWorkout()
                                self.viewModel?.repCount = 0
                                self.viewModel?.uiCount = 0
                                self.viewModel?.navigateToSummary = true 
                            }
                            
                            self.lastRecognizedPhrase = "" // Allow future re-triggers
                        }
        }
    }

    func stopListening() {
        isListening = false
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
    }

    func speak(_ text: String) {
        print("📢 Speaking: \(text)")
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        speechSynthesizer.speak(utterance)
    }
    
}
