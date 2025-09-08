//
//  WheelPicker.swift
//  CustomSlider
//
//  Created by Godwin IE on 09/09/2024.
//

import SwiftUI

struct WheelPicker: View {
    
    // config
    var config: Config
    @Binding var value: Double
    
    // view properties
    @State private var isLoaded: Bool = false
    @State private var lastValue: Double = 0
    
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
                    
                    // Trigger haptic feedback when value changes
                    if abs(newCalculatedValue - lastValue) >= config.feedbackThreshold {
                        triggerHapticFeedback()
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
                    hapticGenerator.prepare()
                }
            }
        }
    }
    
    // MARK: - Haptic Feedback
    
    private func triggerHapticFeedback() {
        // Haptic feedback
        if config.hapticFeedback {
            hapticGenerator.impactOccurred()
        }
    }
    
    struct Config: Equatable {
        var count: Int
        var steps: Int = 10
        var spacing: CGFloat = 5
        var multiplier: Int = 10
        var showsText: Bool = true
        var hapticFeedback: Bool = true
        var feedbackThreshold: Double = 1.0
    }
}

#Preview {
    ContentView()
}
