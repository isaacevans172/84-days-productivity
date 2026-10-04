//
//  OnboardingMascotView.swift
//  84Days
//
//  Created by Isaac Evans on 4/10/2026.
//

import SwiftUI

struct OnboardingMascotView: View {

    enum Expression {
        case hello
        case listening
        case warm
        case thinking
        case concerned
        case encouraging
        case happy
    }

    let expression: Expression

    @State private var isBouncing = false

    private var imageName: String {
        switch expression {
        case .hello:
            return "23-hello"

        case .listening:
            return "15-listening"

        case .warm:
            return "13-warm"

        case .thinking:
            return "22-thinking"

        case .concerned:
            return "14-concerned"

        case .encouraging:
            return "16-encouraging"

        case .happy:
            return "18-happy"
        }
    }

    var body: some View {

        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 150, height: 150)
            .scaleEffect(isBouncing ? 1.04 : 1.0)
            .offset(y: isBouncing ? -4 : 0)
            .animation(
                .spring(
                    response: 0.35,
                    dampingFraction: 0.65
                ),
                value: isBouncing
            )
            .onChange(of: expression) {
                isBouncing = false

                withAnimation {
                    isBouncing = true
                }

                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 0.35
                ) {
                    isBouncing = false
                }
            }
    }
}

#Preview {
    VStack(spacing: 30) {

        OnboardingMascotView(
            expression: .hello
        )

        OnboardingMascotView(
            expression: .happy
        )
    }
}
