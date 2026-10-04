//
//  WelcomeView.swift
//  84Days
//
//  Created by Isaac Evans on 2/10/2026.
//
import SwiftUI

struct WelcomeView: View {

    var body: some View {

        NavigationStack {

            ZStack {

                // MARK: - Background

                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: - Logo

                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .padding(.top, 10)

                    // MARK: - Tagline

                    Text("Progress, not Perfection")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)

                    // MARK: - 3D Hero

                    ThreeD84Hero()
                        .frame(maxWidth: .infinity)
                        .frame(height: 350)
                        .padding(.top, 5)

                    Spacer(minLength: 0)

                    // MARK: - Welcome Text

                    VStack(spacing: 8) {

                        Text("Welcome to 84Days")
                            .font(
                                .system(
                                    size: 30,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .multilineTextAlignment(.center)

                        Text("Build better habits.\nOne day at a time.")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }

                    // MARK: - Get Started

                    NavigationLink {
                        OnboardingView()
                    } label: {

                        HStack(spacing: 10) {

                            Text("Get Started")
                                .font(
                                    .system(
                                        size: 17,
                                        weight: .semibold
                                    )
                                )

                            Image(systemName: "arrow.right")
                                .font(
                                    .system(
                                        size: 15,
                                        weight: .bold
                                    )
                                )
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            Color(
                                red: 1.0,
                                green: 0.45,
                                blue: 0.35
                            )
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 18
                            )
                        )
                        .shadow(
                            color: Color(
                                red: 1.0,
                                green: 0.45,
                                blue: 0.35
                            ).opacity(0.25),
                            radius: 12,
                            y: 6
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 12)
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
}
