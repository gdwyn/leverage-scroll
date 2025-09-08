//
//  WheelPicker.swift
//  CustomSlider
//
//  Created by Godwin IE on 09/09/2024.
//

import SwiftUI
import AVFoundation

struct WheelPicker: View {
    
    // config
    var config: Config
    @Binding var value: Double
    
    // view properties
    @State private var isLoaded: Bool = false
    @State private var lastValue: Double = 0
    @State private var audioPlayer: AVAudioPlayer?
    
    // Haptic feedback generator
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let verticalPadding = size.height / 2
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: config.spacing) {
                    let totalSteps = config.steps * config.count
                    
                    ForEach(0...totalSteps, id: \.self) { index in
                        let remainder = index % config.steps
                        
                        Capsule()
                            .fill(.gray.opacity(0.5))
                            .frame(height: 3)
                            .frame(width: remainder == 0 ? 44 : 28, height: 0, alignment: .center)
                            .frame(maxWidth: 20, alignment: .trailing)

                    }
                }
                .frame(width: size.width)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: .init(get: {
                let position: Int? = isLoaded ? (Int(value) * config.steps) / config.multiplier : nil
                return position
            }, set: { newValue in
                if let newValue {
                    let newCalculatedValue = (CGFloat(newValue) / CGFloat(config.steps)) * CGFloat(config.multiplier)
                    
                    // Trigger feedback when value changes
                    if abs(newCalculatedValue - lastValue) >= config.feedbackThreshold {
                        triggerFeedback()
                        lastValue = newCalculatedValue
                    }
                    
                    value = newCalculatedValue
                }
            }))
            .overlay(alignment: .center) {
                Capsule()
                    .fill(Color.primary)
                    .frame(width: 52, height: 3)
                    .offset(x: -16)
            }
            .safeAreaPadding(.vertical, verticalPadding)
            .onAppear {
                if !isLoaded {
                    isLoaded = true
                    lastValue = value
                    setupAudioPlayer()
                    hapticGenerator.prepare()
                }
            }
        }
    }
    
    // MARK: - Feedback Methods
    
    private func triggerFeedback() {
        // Haptic feedback
        if config.hapticFeedback {
            hapticGenerator.impactOccurred()
        }
        
        // Sound feedback
        if config.soundFeedback {
            playTickSound()
        }
    }
    
    private func setupAudioPlayer() {
        // Create a subtle tick sound programmatically
        let sampleRate: Double = 44100
        let duration: Double = 0.1
        let frequency: Double = 800 // Higher frequency for a more subtle tick
        
        let frameCount = UInt32(sampleRate * duration)
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else {
            return
        }
        
        audioBuffer.frameLength = frameCount
        
        let samples = audioBuffer.floatChannelData![0]
        for i in 0..<Int(frameCount) {
            let time = Double(i) / sampleRate
            let envelope = exp(-time * 15) // Quick decay for subtlety
            samples[i] = Float(sin(2.0 * Double.pi * frequency * time) * envelope * 0.1)
        }
        
        do {
            let audioFile = try AVAudioFile(forWriting: URL(fileURLWithPath: NSTemporaryDirectory() + "tick.wav"), settings: audioFormat.settings)
            try audioFile.write(from: audioBuffer)
            
            audioPlayer = try AVAudioPlayer(contentsOf: audioFile.url)
            audioPlayer?.volume = 0.3 // Subtle volume
            audioPlayer?.prepareToPlay()
        } catch {
            print("Failed to setup audio player: \(error)")
        }
    }
    
    private func playTickSound() {
        guard let audioPlayer = audioPlayer else { return }
        
        // Check if haptic feedback is enabled
        if UIAccessibility.isReduceMotionEnabled {
            return
        }
        
        audioPlayer.currentTime = 0
        audioPlayer.play()
    }
    
    struct Config: Equatable {
        var count: Int
        var steps: Int = 10
        var spacing: CGFloat = 5
        var multiplier: Int = 10
        var showsText: Bool = true
        var hapticFeedback: Bool = true
        var soundFeedback: Bool = true
        var feedbackThreshold: Double = 1.0
    }
}

#Preview {
    ContentView()
}
