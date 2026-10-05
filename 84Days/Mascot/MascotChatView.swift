//
//  MascotChatView.swift
//  84Days
//
//  Created by Isaac Evans on 4/10/2026.
//

import SwiftUI

struct MascotChatView: View {

    @State private var message = ""
    @State private var mascotReply = "Alright. I'm listening."
    @State private var isLoading = false
    @State private var errorMessage: String?

    // Temporary values for testing.
    // We'll eventually pull these from the user's actual profile.
    let mascotName = "Smug"
    let mascotExpression = "smug"

    var body: some View {

        VStack(spacing: 0) {

            // MARK: Mascot

            VStack(spacing: 12) {

                Image("02-smug")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)

                MascotSpeechBubble(text: mascotReply)
                    .padding(.horizontal, 24)
            }
            .padding(.top, 20)

            Spacer()

            // MARK: Quick prompts

            VStack(spacing: 10) {

                Text("Try asking me something")
                    .font(
                        .system(
                            size: 14,
                            weight: .medium,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(.secondary)

                HStack(spacing: 10) {

                    QuickPromptButton(
                        title: "I missed a day"
                    ) {
                        sendMessage("I missed a day")
                    }

                    QuickPromptButton(
                        title: "Motivate me"
                    ) {
                        sendMessage("I need some motivation")
                    }
                }

                HStack(spacing: 10) {

                    QuickPromptButton(
                        title: "What now?"
                    ) {
                        sendMessage("What should I do today?")
                    }

                    QuickPromptButton(
                        title: "Talk to me"
                    ) {
                        sendMessage("Talk to me")
                    }
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            // MARK: Message input

            HStack(spacing: 10) {

                TextField(
                    "Talk to your mascot...",
                    text: $message
                )
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .background(
                    Color.secondary.opacity(0.08)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 18)
                )
                .onSubmit {
                    sendCurrentMessage()
                }

                Button {
                    sendCurrentMessage()
                } label: {

                    Image(systemName: "arrow.up")
                        .font(
                            .system(
                                size: 16,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            message.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ).isEmpty
                            ? Color.gray.opacity(0.4)
                            : Color.accentColor
                        )
                        .clipShape(Circle())
                }
                .disabled(
                    message
                        .trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                        .isEmpty
                    || isLoading
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .navigationTitle("Your Mascot")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {

            if isLoading {
                ProgressView()
                    .padding(16)
                    .background(.regularMaterial)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )
            }
        }
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: {
                    errorMessage != nil
                },
                set: { newValue in
                    if !newValue {
                        errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: Send current message

    private func sendCurrentMessage() {

        let trimmedMessage = message
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !trimmedMessage.isEmpty else {
            return
        }

        message = ""

        sendMessage(trimmedMessage)
    }

    // MARK: Send to AI

    private func sendMessage(_ text: String) {

        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        Task {

            do {

                let reply = try await MascotAIService.sendMessage(
                    message: text,
                    mascotName: mascotName,
                    expression: mascotExpression,
                    context: """
                    The user is currently using the mascot chat.
                    This is an early test of the 84Days mascot companion.
                    Keep the response short, natural and characterful.
                    """
                )

                await MainActor.run {

                    mascotReply = reply
                    isLoading = false
                }

            } catch {

                await MainActor.run {

                    isLoading = false

                    errorMessage =
                        "The mascot couldn't respond right now.\n\n\(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Quick Prompt Button

private struct QuickPromptButton: View {

    let title: String
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            Text(title)
                .font(
                    .system(
                        size: 14,
                        weight: .semibold,
                        design: .rounded
                    )
                )
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    Color.secondary.opacity(0.08)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 14)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        MascotChatView()
    }
}
