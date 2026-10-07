import SwiftUI
import SwiftData
import Supabase
import Auth

struct OnboardingView: View {

    // MARK: - Environment

    @Environment(\.modelContext)
    private var modelContext

    // MARK: - State

    @State private var onboardingData = OnboardingData()
    @State private var currentStep = 0
    @State private var showingAvatarPicker = false
    @State private var isSendingLink = false
    @State private var authError: String?

    // MARK: - App Storage

    @AppStorage("hasCompletedOnboarding")
    private var hasCompletedOnboarding = false

    @AppStorage("journeyStartDate")
    private var journeyStartDate: Double = 0

    @AppStorage("selectedAvatar")
    private var storedAvatar = ""

    @AppStorage("firstName")
    private var storedFirstName = ""

    @AppStorage("lastName")
    private var storedLastName = ""

    // MARK: - Avatar Name

    private var avatarName: String {

        switch onboardingData.selectedAvatar {

        case "01-deadpan":
            return "Deadpan"

        case "02-smug":
            return "Smug"

        case "03-really":
            return "Really?"

        case "04-eye-roll":
            return "Eye Roll"

        case "05-mock-enthusiasm":
            return "Mock Enthusiasm"

        case "06-awkward":
            return "Awkward"

        case "07-slow-clap":
            return "Slow Clap"

        case "08-quip":
            return "Quip"

        case "09-exasperated":
            return "Exasperated"

        case "10-mock-shock":
            return "Mock Shock"

        case "11-wink":
            return "Wink"

        case "12-confident":
            return "Confident"

        case "13-warm":
            return "Warm"

        case "14-concerned":
            return "Concerned"

        case "15-listening":
            return "Listening"

        case "16-encouraging":
            return "Encouraging"

        case "17-proud":
            return "Proud"

        case "18-happy":
            return "Happy"

        case "19-celebrating":
            return "Celebrating"

        case "20-sympathetic":
            return "Sympathetic"

        case "21-determined":
            return "Determined"

        case "22-thinking":
            return "Thinking"

        case "23-hello":
            return "Hello"

        case "24-walking":
            return "Walking"

        default:
            return "Choose your avatar"
        }
    }

    // MARK: - Body

    var body: some View {

        VStack(spacing: 20) {

            // MARK: Top Bar

            HStack {

                if currentStep > 0 {

                    Button {

                        withAnimation {
                            currentStep -= 1
                        }

                    } label: {

                        Image(
                            systemName:
                                "chevron.left"
                        )
                        .font(.headline)
                    }
                }

                Spacer()

                Text(
                    "\(currentStep + 1) / 2"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            Spacer()

            // MARK: Step 1

            if currentStep == 0 {

                VStack(spacing: 20) {

                    Text(
                        "Let's get to know you"
                    )
                    .font(.largeTitle)
                    .fontWeight(.bold)

                    Text(
                        "Tell us a little about yourself"
                    )
                    .foregroundStyle(.secondary)

                    TextField(
                        "First name",
                        text:
                            $onboardingData.firstName
                    )
                    .textFieldStyle(
                        .roundedBorder
                    )

                    TextField(
                        "Last name",
                        text:
                            $onboardingData.lastName
                    )
                    .textFieldStyle(
                        .roundedBorder
                    )

                    TextField(
                        "Email",
                        text:
                            $onboardingData.email
                    )
                    .textFieldStyle(
                        .roundedBorder
                    )
                    .keyboardType(
                        .emailAddress
                    )
                    .textInputAutocapitalization(
                        .never
                    )
                    .autocorrectionDisabled()
                }
                .padding(.horizontal)
            }

            // MARK: Step 2

            else {

                VStack(spacing: 20) {

                    Text(
                        "Choose your avatar"
                    )
                    .font(.largeTitle)
                    .fontWeight(.bold)

                    Text(
                        "Pick the one that feels most like you."
                    )
                    .foregroundStyle(.secondary)

                    Button {

                        showingAvatarPicker = true

                    } label: {

                        HStack {

                            if !onboardingData
                                .selectedAvatar
                                .isEmpty {

                                Image(
                                    onboardingData
                                        .selectedAvatar
                                )
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: 70,
                                    height: 70
                                )
                            }

                            VStack(
                                alignment: .leading
                            ) {

                                Text(avatarName)
                                    .font(.headline)

                                Text(
                                    "Tap to change"
                                )
                                .font(.subheadline)
                                .foregroundStyle(
                                    .secondary
                                )
                            }

                            Spacer()

                            Image(
                                systemName:
                                    "chevron.right"
                            )
                            .foregroundStyle(
                                .secondary
                            )
                        }
                        .padding()
                        .background(
                            Color.gray.opacity(
                                0.1
                            )
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 20
                            )
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }

            Spacer()

            // MARK: Error

            if let authError {

                Text(authError)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(
                        .center
                    )
                    .padding(.horizontal)
            }

            // MARK: Bottom Button

            Button {

                if currentStep == 0 {

                    withAnimation {
                        currentStep = 1
                    }

                } else {

                    sendMagicLink()
                }

            } label: {

                HStack {

                    if isSendingLink {

                        ProgressView()
                            .tint(.white)
                    }

                    Text(
                        isSendingLink
                        ? "Sending..."
                        : currentStep == 0
                        ? "Choose your avatar"
                        : "Let's go"
                    )
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Color.blue
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 16
                    )
                )
            }
            .padding(.horizontal, 24)
            .disabled(
                isSendingLink ||
                (
                    currentStep == 0 &&
                    (
                        onboardingData
                            .firstName
                            .isEmpty ||
                        onboardingData
                            .lastName
                            .isEmpty ||
                        onboardingData
                            .email
                            .isEmpty
                    )
                )
            )
            .opacity(
                (
                    currentStep == 0 &&
                    (
                        onboardingData
                            .firstName
                            .isEmpty ||
                        onboardingData
                            .lastName
                            .isEmpty ||
                        onboardingData
                            .email
                            .isEmpty
                    )
                )
                ? 0.5
                : 1
            )
        }
        .padding(.vertical)

        // MARK: Avatar Picker

        .sheet(
            isPresented:
                $showingAvatarPicker
        ) {

            AvatarPickerView(
                selectedAvatar:
                    $onboardingData
                        .selectedAvatar
            )
        }

        // MARK: Authentication

        .task {

            for await (
                event,
                session
            ) in supabase.auth.authStateChanges {

                if event == .signedIn {

                    guard let session else {

                        print(
                            "❌ Signed in event received, but no session exists"
                        )

                        continue
                    }

                    do {

                        // ------------------------------------------------
                        // CREATE SUPABASE PROFILE
                        // ------------------------------------------------

                        try await ProfileService
                            .createProfile(
                                userID:
                                    session.user.id,
                                firstName:
                                    onboardingData
                                        .firstName,
                                lastName:
                                    onboardingData
                                        .lastName,
                                email:
                                    onboardingData
                                        .email,
                                avatar:
                                    onboardingData
                                        .selectedAvatar
                            )

                        // ------------------------------------------------
                        // SAVE LOCAL USER DATA
                        // ------------------------------------------------

                        storedFirstName =
                            onboardingData.firstName

                        storedLastName =
                            onboardingData.lastName

                        storedAvatar =
                            onboardingData.selectedAvatar

                        // ------------------------------------------------
                        // START THE 84 DAY JOURNEY
                        // ------------------------------------------------

                        if journeyStartDate == 0 {

                            journeyStartDate =
                                Date()
                                .timeIntervalSince1970
                        }

                        // ------------------------------------------------
                        // SAVE LOCAL PROFILE
                        //
                        // This is intentionally kept simple so the
                        // onboarding flow does not depend on additional
                        // profile fields.
                        // ------------------------------------------------

                        let existingProfiles =
                            try modelContext.fetch(
                                FetchDescriptor<
                                    LocalUserProfile
                                >()
                            )

                        if let existingProfile =
                            existingProfiles.first {

                            existingProfile.firstName =
                                onboardingData
                                    .firstName

                            existingProfile.lastName =
                                onboardingData
                                    .lastName

                            existingProfile.email =
                                onboardingData
                                    .email

                            existingProfile.avatar =
                                onboardingData
                                    .selectedAvatar

                        } else {

                            let profile =
                                LocalUserProfile(
                                    firstName:
                                        onboardingData
                                            .firstName,
                                    lastName:
                                        onboardingData
                                            .lastName,
                                    email:
                                        onboardingData
                                            .email,
                                    avatar:
                                        onboardingData
                                            .selectedAvatar
                                )

                            modelContext.insert(
                                profile
                            )
                        }

                        try modelContext.save()

                        print(
                            "✅ Authentication complete"
                        )

                        print(
                            "✅ Profile created for user: \(session.user.id)"
                        )

                        print(
                            "✅ Avatar saved: \(onboardingData.selectedAvatar)"
                        )

                        print(
                            "✅ 84 day journey started"
                        )

                        hasCompletedOnboarding =
                            true

                    } catch {

                        print(
                            "❌ Failed to create profile: \(error)"
                        )

                        authError =
                            "We couldn't finish setting up your profile. Please try again."
                    }

                    break
                }
            }
        }
    }

    // MARK: - Send Magic Link

    private func sendMagicLink() {

        isSendingLink = true
        authError = nil

        Task {

            do {

                try await supabase.auth
                    .signInWithOTP(
                        email:
                            onboardingData.email,
                        redirectTo:
                            URL(
                                string:
                                    "days84://auth-callback"
                            )
                    )

                print(
                    "✅ Magic link sent"
                )

                isSendingLink = false

            } catch {

                authError =
                    error.localizedDescription

                print(
                    "❌ Authentication error: \(error)"
                )

                isSendingLink = false
            }
        }
    }
}

#Preview {
    OnboardingView()
}
