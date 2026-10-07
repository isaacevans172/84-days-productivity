//
//  DataModels.swift
//  84Days
//
//  Created by Isaac Evans on 6/10/2026.
//
import SwiftUI

struct MascotHomeView: View {
    @AppStorage("firstName") private var firstName = ""
    @AppStorage("selectedAvatar") private var selectedAvatar = "02-smug"

    @State private var mascotComment = "You've got this. Keep moving forward."

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: - Header

                    VStack(alignment: .leading, spacing: 6) {
                        Text("YOUR MASCOT")
                            .font(.system(size: 13, weight: .bold))
                            .tracking(1.2)
                            .foregroundStyle(.secondary)

                        Text("Your personal development hub")
                            .font(.system(size: 28, weight: .bold))
                    }
                    .padding(.top, 10)


                    // MARK: - Mascot

                    HStack(alignment: .center, spacing: 16) {

                        Image(selectedAvatar)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 125, height: 125)

                        VStack(alignment: .leading, spacing: 10) {
                            Text(mascotComment)
                                .font(.system(size: 16, weight: .medium))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .background(
                            Color(.secondarySystemBackground),
                            in: RoundedRectangle(cornerRadius: 18)
                        )
                    }


                    // MARK: - Personal Development

                    VStack(alignment: .leading, spacing: 12) {

                        Text("PERSONAL DEVELOPMENT")
                            .font(.system(size: 13, weight: .bold))
                            .tracking(1.2)
                            .foregroundStyle(.secondary)

                        NavigationLink {
                            ReflectionView()
                        } label: {
                            HStack(spacing: 16) {

                                Image(systemName: "star.bubble.fill")
                                    .font(.system(size: 22))
                                    .frame(width: 42, height: 42)
                                    .background(
                                        Color.accentColor.opacity(0.12),
                                        in: RoundedRectangle(cornerRadius: 12)
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Daily Reflection")
                                        .font(.system(size: 17, weight: .bold))

                                    Text("Reflect on how your day went")
                                        .font(.system(size: 13))
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(16)
                            .background(
                                Color(.secondarySystemBackground),
                                in: RoundedRectangle(cornerRadius: 18)
                            )
                        }
                        .buttonStyle(.plain)
                    }


                    // MARK: - Coming Soon

                    VStack(alignment: .leading, spacing: 12) {

                        Text("COMING SOON")
                            .font(.system(size: 13, weight: .bold))
                            .tracking(1.2)
                            .foregroundStyle(.secondary)

                        developmentCard(
                            icon: "brain.head.profile",
                            title: "AI Coaching",
                            subtitle: "Get personalised guidance from your mascot"
                        )

                        developmentCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Insights",
                            subtitle: "See patterns across your productivity"
                        )

                        developmentCard(
                            icon: "book.closed.fill",
                            title: "Journal",
                            subtitle: "Keep track of your thoughts and progress"
                        )
                    }

                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
        }
    }


    // MARK: - Development Card

    private func developmentCard(
        icon: String,
        title: String,
        subtitle: String
    ) -> some View {

        HStack(spacing: 16) {

            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.secondary)
                .frame(width: 42, height: 42)
                .background(
                    Color(.tertiarySystemBackground),
                    in: RoundedRectangle(cornerRadius: 12)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("SOON")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 18)
        )
        .opacity(0.7)
    }
}

#Preview {
    MascotHomeView()
}
