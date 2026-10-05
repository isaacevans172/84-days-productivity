//
//  AvatarPickerVIew.swift
//  84Days
//
//  Created by Isaac Evans on 2/10/2026.
//

import SwiftUI

struct AvatarPickerView: View {

    // MARK: - State

    @Binding var selectedAvatar: String

    @Environment(\.dismiss)
    private var dismiss

    @State private var recentlySelected: String?

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 20) {

                    // MARK: Header

                    VStack(spacing: 6) {

                        Text("Choose your personality")
                            .font(
                                .system(
                                    size: 24,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )

                        Text(
                            "There are no wrong answers. Probably."
                        )
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 4)


                    // MARK: Avatar grid

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
                    ) {

                        ForEach(
                            avatars,
                            id: \.filename
                        ) { avatar in

                            avatarCard(avatar)
                        }
                    }


                    // MARK: Selected message

                    if let selected = avatars.first(
                        where: {
                            $0.filename == selectedAvatar
                        }
                    ) {

                        VStack(spacing: 4) {

                            Text("Selected")
                                .font(
                                    .system(
                                        size: 12,
                                        weight: .semibold
                                    )
                                )
                                .foregroundStyle(.secondary)

                            Text(selected.name)
                                .font(
                                    .system(
                                        size: 18,
                                        weight: .bold,
                                        design: .rounded
                                    )
                                )
                        }
                        .padding(.top, 4)
                        .transition(
                            .opacity
                                .combined(
                                    with: .move(edge: .bottom)
                                )
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
            )

            // MARK: Navigation

            .navigationTitle("Your Mascot")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {

                ToolbarItem(
                    placement: .topBarTrailing
                ) {

                    Button {

                        dismiss()

                    } label: {

                        Text("Done")
                            .font(
                                .system(
                                    size: 16,
                                    weight: .semibold
                                )
                            )
                            .foregroundStyle(
                                Color(
                                    red: 1.0,
                                    green: 0.45,
                                    blue: 0.35
                                )
                            )
                    }
                }
            }
        }
    }


    // MARK: - Avatar Card

    @ViewBuilder
    private func avatarCard(
        _ avatar: Avatar
    ) -> some View {

        let isSelected =
            selectedAvatar == avatar.filename

        Button {

            withAnimation(
                .spring(
                    response: 0.35,
                    dampingFraction: 0.65
                )
            ) {

                selectedAvatar = avatar.filename
                recentlySelected = avatar.filename
            }

        } label: {

            VStack(spacing: 7) {

                ZStack {

                    Image(avatar.filename)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: 82,
                            height: 82
                        )
                        .scaleEffect(
                            isSelected ? 1.08 : 1.0
                        )

                    if isSelected {

                        Image(
                            systemName:
                                "checkmark.circle.fill"
                        )
                        .font(
                            .system(
                                size: 21,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(
                            Color(
                                red: 1.0,
                                green: 0.45,
                                blue: 0.35
                            )
                        )
                        .background(
                            Circle()
                                .fill(
                                    Color(
                                        .systemBackground
                                    )
                                )
                        )
                        .offset(
                            x: 30,
                            y: -30
                        )
                    }
                }
                .frame(height: 86)

                Text(avatar.name)
                    .font(
                        .system(
                            size: 12,
                            weight: isSelected
                                ? .bold
                                : .medium,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(
                maxWidth: .infinity,
                minHeight: 120
            )
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(
                    cornerRadius: 18
                )
                .fill(
                    isSelected
                    ? Color(
                        red: 1.0,
                        green: 0.45,
                        blue: 0.35
                    ).opacity(0.10)
                    : Color(.secondarySystemBackground)
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 18
                )
                .stroke(
                    isSelected
                    ? Color(
                        red: 1.0,
                        green: 0.45,
                        blue: 0.35
                    )
                    : Color.clear,
                    lineWidth: 2
                )
            )
            .shadow(
                color: isSelected
                    ? Color(
                        red: 1.0,
                        green: 0.45,
                        blue: 0.35
                    ).opacity(0.15)
                    : Color.clear,
                radius: 8,
                y: 4
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {

    AvatarPickerView(
        selectedAvatar:
            .constant("01-deadpan")
    )
}
