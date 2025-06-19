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
    
//    // MARK: - Private Properties
//    private var lastRecognizedPhrase: String = ""
//    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
//    private let audioEngine = AVAudioEngine()
    private let speechSynthesizer = AVSpeechSynthesizer()
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?

    // MARK: - Init
    override init() {
        super.init()
        speechSynthesizer.delegate = self
    }

    // MARK: - Speech
    func speakFeedback(number: Int, label: String) {
        let formattedLabel = formatLabelForSpeech(label)
        let text = String("Rep \(number), \(formattedLabel)")
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
