//
//  MascotView.swift
//  84Days
//
//  Created by Isaac Evans on 4/10/2026.
//

import SwiftUI

struct MascotView: View {

    let state: MascotState

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 12) {

            // MARK: Mascot

            Image(state.expression.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .scaleEffect(isAnimating ? 1.04 : 1.0)
                .offset(y: isAnimating ? -4 : 0)
                .animation(
                    .spring(
                        response: 0.35,
                        dampingFraction: 0.65
                    ),
                    value: isAnimating
                )

            // MARK: Speech Bubble

            if !state.message.isEmpty {
                MascotSpeechBubble(
                    text: state.message
                )
                .transition(
                    .asymmetric(
                        insertion: .scale(scale: 0.92)
                            .combined(with: .opacity),
                        removal: .opacity
                    )
                )
            }
        }
        .onAppear {
            animateMascot()
        }
        .onChange(of: state.expression) {
            animateMascot()
        }
        .onChange(of: state.message) {
            animateMascot()
        }
    }

    // MARK: Animation

    private func animateMascot() {

        isAnimating = false

        withAnimation {
            isAnimating = true
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.35
        ) {
            isAnimating = false
        }
    }
}

// MARK: - Preview

#Preview {
    let state = MascotEngine.state(
        for: .completedDay,
        context: MascotContext(
            currentDay: 8,
            currentStreak: 8,
            completedDays: 8,
            progressPercentage: 9.5
        )
    )

    MascotView(state: state)
}
