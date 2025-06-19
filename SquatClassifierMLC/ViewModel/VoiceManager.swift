//
//  VoiceCommandManager.swift
//  SquatClassifierMLC
//
//  Created by Patricia Putri Art Syani on 15/06/25.
//

import Foundation
import AVFoundation
import Speech

@MainActor
class VoiceCommandManager: NSObject, ObservableObject, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate {
    
    // MARK: - Voice Synthesizer
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    // MARK: - Speech Recognizer
    @Published private var lastRecognizedPhrase: String = ""
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // Navigation action delegate
    var onFinishCommand: (() -> Void)?

    // MARK: - Init
    override init() {
        super.init()
//        speechSynthesizer.delegate = self
    }
    
    // MARK: - Start/Stop Listening
    func startListening() {
            guard let recognizer = speechRecognizer, recognizer.isAvailable else {
                return
            }
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else {
                return
            }
            
            recognitionRequest.shouldReportPartialResults = true
            
            recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    let bestTranscription = result.bestTranscription.formattedString
                    self.lastRecognizedPhrase = bestTranscription
                    // Check if user says "finish"
                    if bestTranscription.lowercased().contains("finish") {
                        self.handleFinishCommand()
                    }
                }
                if let error = error {
                    print("Error recognizing speech: \(error)")
                }
            }
            
            // Set up the audio input
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, time) in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            do {
                try audioEngine.start()
            } catch {
                print("Error starting audio engine: \(error)")
            }
        }
        
        func stopListening() {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recognitionTask?.cancel()
        }
        
        // MARK: - Handle "finish" Command
        private func handleFinishCommand() {
            DispatchQueue.main.async {
                self.onFinishCommand?()
            }
        }


    // MARK: - Speech
    func speakFeedback(number: Int, label: String) {
        DispatchQueue.main.async {
            let formattedLabel = self.formatLabelForSpeech(label)
            let text = String("Rep \(number), \(formattedLabel)")
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.5
            self.speechSynthesizer.speak(utterance)
        }
    }

    func speakCountdown(number: Int) {
        DispatchQueue.main.async {
            let utterance = AVSpeechUtterance(string: "\(number)")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.5
            self.speechSynthesizer.speak(utterance)
        }
    }

    func speakStartWorkout() {
        DispatchQueue.main.async {
            let utterance = AVSpeechUtterance(string: "GO")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.6
            self.speechSynthesizer.speak(utterance)
        }
    }
    
    private func formatLabelForSpeech(_ label: String) -> String {
        switch label {
        case "bad_toe":
            return "Push your knees back"
        case "bad_inwards":
            return "Push your knees out"
        case "good":
            return "Nice form"
        default:
            return label.replacingOccurrences(of: "_", with: " ")
        }
    }
}
