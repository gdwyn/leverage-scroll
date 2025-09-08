//
//  ContentView.swift
//  scrollknob
//

import SwiftUI

struct ContentView: View {
    @State private var config: WheelPicker.Config = .init(count: 2, steps: 10, spacing: 10, multiplier: 10)
    @State private var value: Double = 10
    var body: some View {
        NavigationStack {
            HStack(alignment: .center, spacing: 8) {
                
                HStack(spacing: 2) {
                    TextField("0.0", value: $value, format: .number.precision(.fractionLength(1)))
                        .font(.title.bold())
                        .fontDesign(.rounded)
                        .keyboardType(.decimalPad)
                        .frame(width: 100)
                        .multilineTextAlignment(.trailing)
                    
                    Text("x")
                        .font(.title.bold())
                        .fontDesign(.rounded)
                }
                
                WheelPicker(config: config, value: $value)
                    .frame(width: 100, height: 80)
                    .mask {
                        LinearGradient(
                            colors: [
                                .clear,
                                .primary,
                                .primary,
                                .clear,
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
            }
            
        }
    }
}

#Preview {
    ContentView()
}
