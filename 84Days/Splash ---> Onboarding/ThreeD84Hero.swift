//
//  ThreeD84Hero.swift
//  84Days
//
//  Created by Isaac Evans on 4/10/2026.
//

import SwiftUI

struct ThreeD84Hero: View {

    var body: some View {

        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in

            let time = context.date.timeIntervalSinceReferenceDate

            // Gentle continuous movement
            let float1 = sin(time * 1.2)
            let float2 = sin(time * 0.9 + 1.5)
            let float3 = sin(time * 1.4 + 3.0)

            ZStack {

                // MARK: - Soft background glow

                Circle()
                    .fill(
                        Color(
                            red: 1.0,
                            green: 0.45,
                            blue: 0.35
                        )
                        .opacity(0.10)
                    )
                    .frame(width: 180, height: 180)
                    .blur(radius: 25)
                    .offset(x: -105, y: -105)


                // MARK: - Hourglass

                Image(systemName: "hourglass")
                    .font(.system(size: 25, weight: .medium))
                    .foregroundStyle(
                        Color(
                            red: 0.20,
                            green: 0.19,
                            blue: 0.20
                        )
                    )
                    .frame(width: 52, height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                    )
                    .shadow(
                        color: .black.opacity(0.10),
                        radius: 10,
                        y: 5
                    )
                    .rotationEffect(
                        .degrees(-12 + float1 * 3)
                    )
                    .offset(
                        x: -145 + float1 * 3,
                        y: -42 + float1 * 6
                    )


                // MARK: - Progress chart

                HStack(alignment: .bottom, spacing: 4) {

                    Capsule()
                        .frame(width: 5, height: 10)

                    Capsule()
                        .frame(width: 5, height: 17)

                    Capsule()
                        .frame(width: 5, height: 25)
                }
                .foregroundStyle(
                    Color(
                        red: 1.0,
                        green: 0.45,
                        blue: 0.35
                    )
                )
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                )
                .shadow(
                    color: .black.opacity(0.10),
                    radius: 10,
                    y: 5
                )
                .rotationEffect(
                    .degrees(10 + float2 * 3)
                )
                .offset(
                    x: 145 + float2 * 4,
                    y: -112 + float2 * 7
                )


                // MARK: - Small floating diamond

                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        Color(
                            red: 0.15,
                            green: 0.14,
                            blue: 0.15
                        )
                    )
                    .frame(width: 15, height: 15)
                    .rotationEffect(
                        .degrees(45 + float3 * 15)
                    )
                    .offset(
                        x: -155 + float3 * 4,
                        y: 52 + float3 * 7
                    )


                // MARK: - Achievement sparkle

                Image(systemName: "sparkle")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(
                        Color(
                            red: 1.0,
                            green: 0.45,
                            blue: 0.35
                        )
                    )
                    .scaleEffect(
                        1.0 + float2 * 0.10
                    )
                    .rotationEffect(
                        .degrees(float2 * 8)
                    )
                    .offset(
                        x: 130 + float2 * 3,
                        y: 96 + float2 * 5
                    )


                // MARK: - Tiny floating dots

                Circle()
                    .fill(
                        Color(
                            red: 1.0,
                            green: 0.45,
                            blue: 0.35
                        )
                    )
                    .frame(width: 10, height: 10)
                    .offset(
                        x: -155 + float1 * 3,
                        y: -115 + float1 * 4
                    )

                Circle()
                    .fill(Color.black.opacity(0.65))
                    .frame(width: 7, height: 7)
                    .offset(
                        x: 155 + float3 * 3,
                        y: -25 + float3 * 5
                    )


                // MARK: - 84 Block

                ZStack {

                    // Deep extrusion
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.black.opacity(0.18))
                        .frame(width: 245, height: 155)
                        .offset(y: 22)

                    // Coral side
                    RoundedRectangle(cornerRadius: 30)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(
                                        red: 0.95,
                                        green: 0.30,
                                        blue: 0.23
                                    ),
                                    Color(
                                        red: 0.80,
                                        green: 0.20,
                                        blue: 0.16
                                    )
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 245, height: 155)
                        .offset(y: 11)

                    // Main face
                    RoundedRectangle(cornerRadius: 30)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    Color(
                                        red: 0.94,
                                        green: 0.92,
                                        blue: 0.89
                                    )
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 245, height: 155)

                    // 84
                    Text("84")
                        .font(
                            .system(
                                size: 88,
                                weight: .black,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(
                                        red: 0.12,
                                        green: 0.11,
                                        blue: 0.12
                                    ),
                                    Color(
                                        red: 0.28,
                                        green: 0.26,
                                        blue: 0.27
                                    )
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(
                            color: .black.opacity(0.18),
                            radius: 3,
                            y: 4
                        )
                }
                .rotationEffect(.degrees(-7))
                .rotation3DEffect(
                    .degrees(8),
                    axis: (x: 1, y: 0, z: 0)
                )
                .shadow(
                    color: .black.opacity(0.20),
                    radius: 25,
                    y: 22
                )


                // MARK: - Mascot

                Image("18-happy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 155, height: 155)
                    .offset(
                        x: float1 * 2,
                        y: -75 + float1 * 5
                    )
                    .rotationEffect(
                        .degrees(float1 * 1.5)
                    )


                // MARK: - Floating check

                Image(systemName: "checkmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white)
                    )
                    .shadow(
                        color: .black.opacity(0.12),
                        radius: 10,
                        y: 6
                    )
                    .offset(
                        x: 145 + float2 * 3,
                        y: 45 + float2 * 5
                    )
                    .rotationEffect(
                        .degrees(12 + float2 * 3)
                    )
            }
            .frame(width: 350, height: 330)
        }
    }
}

#Preview {
    ThreeD84Hero()
        .padding()
}
