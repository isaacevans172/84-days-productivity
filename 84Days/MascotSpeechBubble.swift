//
//  MascotSpeechBubble.swift
//  84Days
//
//  Created by Isaac Evans on 4/10/2026.
//

import SwiftUI

struct MascotSpeechBubble: View {

    let text: String

    var body: some View {

        VStack(spacing: 0) {

            Text(text)
                .font(
                    .system(
                        size: 15,
                        weight: .medium,
                        design: .rounded
                    )
                )
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.secondary.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            Color.secondary.opacity(0.08),
                            lineWidth: 1
                        )
                )

            // Little speech-bubble tail
            Triangle()
                .fill(Color.secondary.opacity(0.08))
                .frame(width: 16, height: 8)
                .offset(y: -1)
        }
        .transition(
            .asymmetric(
                insertion: .scale(scale: 0.92)
                    .combined(with: .opacity),
                removal: .opacity
            )
        )
    }
}

private struct Triangle: Shape {

    func path(in rect: CGRect) -> Path {

        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(
            to: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(
            to: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.closeSubpath()

        return path
    }
}

#Preview {
    MascotSpeechBubble(
        text: "Hey! Let's get this thing started."
    )
    .padding()
}
