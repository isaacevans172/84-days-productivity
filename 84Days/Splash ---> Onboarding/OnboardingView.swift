import SwiftUI
import Supabase
import Auth

struct OnboardingView: View {

    // MARK: - State

    @State private var onboardingData = OnboardingData()
    @State private var currentStep = 0
    @State private var showingAvatarPicker = false
    @State private var isSendingLink = false
    @State private var authError: String?
    @State private var emailSent = false

    @FocusState private var focusedField: Field?

    @AppStorage("hasCompletedOnboarding")
    private var hasCompletedOnboarding = false

    enum Field {
        case firstName
        case lastName
        case email
    }

    // MARK: - Avatar name

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

    // MARK: - Email validation

    private var isValidEmail: Bool {

        let email = onboardingData.email

        guard !email.isEmpty else {
            return false
        }

        return email.contains("@") &&
               email.contains(".")
    }

    // MARK: - Continue validation

    private var canContinue: Bool {

        if currentStep == 0 {

            return !onboardingData.firstName.isEmpty &&
                   !onboardingData.lastName.isEmpty &&
                   isValidEmail

        } else {

            return !onboardingData.selectedAvatar.isEmpty
        }
    }

    // MARK: - Mascot expression

    private var mascotExpression:
        OnboardingMascotView.Expression {

        if emailSent {
            return .happy
        }

        if currentStep == 1 {

            switch onboardingData.selectedAvatar {

            case "14-concerned":
                return .concerned

            case "22-thinking":
                return .thinking

            case "18-happy":
                return .happy

            case "19-celebrating":
                return .encouraging

            case "13-warm":
                return .warm

            case "16-encouraging":
                return .encouraging

            default:
                return .hello
            }
        }

        if let focusedField {

            switch focusedField {

            case .firstName:
                return .listening

            case .lastName:
                return .listening

            case .email:
                return .thinking
            }
        }

        if !onboardingData.firstName.isEmpty &&
            !onboardingData.lastName.isEmpty &&
            isValidEmail {

            return .happy
        }

        if !onboardingData.firstName.isEmpty {
            return .warm
        }

        return .hello
    }

    // MARK: - Mascot comment

    private var currentMascotComment: String {

        if emailSent {

            return "Magic link sent! Check your inbox. I'll wait here."
        }

        if currentStep == 1 {

            if onboardingData.selectedAvatar.isEmpty {

                return "Now pick your personality. Choose wisely."
            }

            switch onboardingData.selectedAvatar {

            case "01-deadpan":
                return "Yeah... that tracks."

            case "02-smug":
                return "Oh, we're feeling confident."

            case "03-really":
                return "Really? That's your choice?"

            case "04-eye-roll":
                return "Starting with the attitude, I see."

            case "05-mock-enthusiasm":
                return "Wow. I'm thrilled for you."

            case "06-awkward":
                return "Interesting choice."

            case "07-slow-clap":
                return "I'll allow it."

            case "08-quip":
                return "You've got jokes. I like it."

            case "09-exasperated":
                return "Already exasperated? We haven't started."

            case "10-mock-shock":
                return "Oh! I did not see that coming."

            case "11-wink":
                return "Okay, I see you."

            case "12-confident":
                return "Now that's some confidence."

            case "13-warm":
                return "That's a nice one."

            case "14-concerned":
                return "Everything okay?"

            case "15-listening":
                return "I'm listening."

            case "16-encouraging":
                return "You've got this."

            case "17-proud":
                return "You look proud already."

            case "18-happy":
                return "Okay, we're bringing the good vibes."

            case "19-celebrating":
                return "Bit enthusiastic. I respect it."

            case "20-sympathetic":
                return "I'll be here for the rough days too."

            case "21-determined":
                return "Right. Let's get this done."

            case "22-thinking":
                return "You're thinking about it. Fair."

            case "23-hello":
                return "Hello again!"

            case "24-walking":
                return "Alright, let's get moving."

            default:
                return "I think we've found your vibe."
            }
        }

        if let focusedField {

            switch focusedField {

            case .firstName:

                if onboardingData.firstName.isEmpty {
                    return "Alright, what's your first name?"
                }

                return "I'm listening..."

            case .lastName:

                if onboardingData.lastName.isEmpty {
                    return "And your last name?"
                }

                return "Got it. Keep going."

            case .email:

                if onboardingData.email.isEmpty {
                    return "I'll need an email for the magic link."
                }

                if !isValidEmail {
                    return "Hmm... that doesn't look quite right."
                }

                return "That looks good."
            }
        }

        if !onboardingData.firstName.isEmpty &&
            !onboardingData.lastName.isEmpty &&
            isValidEmail {

            return "Perfect. You're ready to go."
        }

        if !onboardingData.lastName.isEmpty {

            return "Got it. We're getting somewhere."
        }

        if !onboardingData.firstName.isEmpty {

            return "Nice to meet you, \(onboardingData.firstName)."
        }

        return "Hey! Let's get this thing started."
    }

    // MARK: - Body

    var body: some View {

        VStack(spacing: 0) {

            // MARK: Progress bar

            HStack {

                Spacer()

                HStack(spacing: 6) {

                    Capsule()
                        .fill(
                            currentStep == 0
                            ? Color(
                                red: 1.0,
                                green: 0.45,
                                blue: 0.35
                            )
                            : Color.secondary.opacity(0.2)
                        )
                        .frame(
                            width: 45,
                            height: 5
                        )

                    Capsule()
                        .fill(
                            currentStep == 1
                            ? Color(
                                red: 1.0,
                                green: 0.45,
                                blue: 0.35
                            )
                            : Color.secondary.opacity(0.2)
                        )
                        .frame(
                            width: 45,
                            height: 5
                        )
                }

                Spacer()

                Text("\(currentStep + 1) / 2")
                    .font(
                        .system(
                            size: 14,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.secondary)
                    .frame(width: 40)
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)

            // MARK: Main content

            ScrollView {

                VStack(spacing: 0) {

                    if currentStep == 0 {

                        stepOne

                    } else {

                        stepTwo
                    }
                }
                .padding(.horizontal, 24)
            }

            // MARK: Error

            if let authError {

                Text(authError)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
            }

            // MARK: Bottom button

            Button {

                if currentStep == 0 {

                    focusedField = nil

                    withAnimation(
                        .spring(
                            response: 0.4,
                            dampingFraction: 0.8
                        )
                    ) {
                        currentStep = 1
                    }

                } else {

                    sendMagicLink()
                }

            } label: {

                HStack(spacing: 10) {

                    if isSendingLink {

                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .frame(
                                width: 18,
                                height: 18
                            )
                    }

                    Text(
                        isSendingLink
                        ? "Sending..."
                        : currentStep == 0
                        ? "Choose your mascot"
                        : "Let's go"
                    )

                    if !isSendingLink {

                        Image(systemName: "arrow.right")
                            .font(
                                .system(
                                    size: 14,
                                    weight: .bold
                                )
                            )
                    }
                }
                .font(
                    .system(
                        size: 17,
                        weight: .semibold
                    )
                )
                .foregroundStyle(.white)
                .frame(
                    maxWidth: .infinity,
                    minHeight: 54,
                    maxHeight: 54
                )
                .background(
                    Color(
                        red: 1.0,
                        green: 0.45,
                        blue: 0.35
                    )
                    .opacity(
                        canContinue ? 1 : 0.45
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
                    )
                    .opacity(
                        canContinue ? 0.20 : 0
                    ),
                    radius: 12,
                    y: 6
                )
            }
            .disabled(
                !canContinue ||
                isSendingLink
            )
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 12)
        }
        .background(
            Color(.systemBackground)
                .ignoresSafeArea()
        )

        // MARK: Avatar picker

        .sheet(
            isPresented: $showingAvatarPicker
        ) {

            AvatarPickerView(
                selectedAvatar:
                    $onboardingData.selectedAvatar
            )
        }

        // MARK: Authentication listener

        .task {

            for await (event, session)
                in supabase.auth.authStateChanges {

                if event == .signedIn {

                    guard let session else {

                        print(
                            "❌ Signed in event received, but no session exists"
                        )

                        continue
                    }

                    do {

                        try await ProfileService.createProfile(
                            userID: session.user.id,
                            firstName:
                                onboardingData.firstName,
                            lastName:
                                onboardingData.lastName,
                            email:
                                onboardingData.email,
                            avatar:
                                onboardingData.selectedAvatar
                        )

                        print(
                            "✅ Authentication complete"
                        )

                        print(
                            "✅ Profile created for user: \(session.user.id)"
                        )

                        hasCompletedOnboarding = true

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

    // MARK: - Step 1

    private var stepOne: some View {

        VStack(spacing: 0) {

            // Mascot + speech bubble

            VStack(spacing: 4) {

                MascotSpeechBubble(
                    text: currentMascotComment
                )
                .id(currentMascotComment)

                OnboardingMascotView(
                    expression: mascotExpression
                )
                .frame(height: 145)
            }
            .animation(
                .spring(
                    response: 0.45,
                    dampingFraction: 0.85
                ),
                value: currentMascotComment
            )
            .padding(.top, 8)

            Text("Let's get to know you")
                .font(
                    .system(
                        size: 30,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            Text(
                "A few details to make 84Days yours."
            )
            .font(.system(size: 16))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.top, 6)
            .padding(.bottom, 28)

            // Fields

            VStack(spacing: 14) {

                onboardingField(
                    title: "First name",
                    placeholder: "Your first name",
                    text: $onboardingData.firstName,
                    keyboard: .default,
                    field: .firstName
                )

                onboardingField(
                    title: "Last name",
                    placeholder: "Your last name",
                    text: $onboardingData.lastName,
                    keyboard: .default,
                    field: .lastName
                )

                onboardingField(
                    title: "Email",
                    placeholder: "you@example.com",
                    text: $onboardingData.email,
                    keyboard: .emailAddress,
                    field: .email
                )
            }
        }
    }

    // MARK: - Step 2

    private var stepTwo: some View {

        VStack(spacing: 0) {

            // Mascot + speech bubble

            VStack(spacing: 4) {

                MascotSpeechBubble(
                    text: currentMascotComment
                )
                .id(currentMascotComment)

                if onboardingData.selectedAvatar.isEmpty {

                    OnboardingMascotView(
                        expression: .hello
                    )
                    .frame(height: 145)

                } else {

                    Image(
                        onboardingData.selectedAvatar
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 145,
                        height: 145
                    )
                }
            }
            .animation(
                .spring(
                    response: 0.45,
                    dampingFraction: 0.85
                ),
                value: currentMascotComment
            )
            .padding(.top, 8)

            Text("Choose your mascot")
                .font(
                    .system(
                        size: 30,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .multilineTextAlignment(.center)

            Text(
                "Pick the personality that feels most like you."
            )
            .font(.system(size: 16))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.top, 6)
            .padding(.bottom, 26)

            // Avatar selector

            Button {

                showingAvatarPicker = true

            } label: {

                HStack(spacing: 16) {

                    if !onboardingData.selectedAvatar.isEmpty {

                        Image(
                            onboardingData.selectedAvatar
                        )
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: 65,
                            height: 65
                        )

                    } else {

                        Image(
                            systemName:
                                "person.crop.circle"
                        )
                        .font(.system(size: 42))
                        .foregroundStyle(.secondary)
                    }

                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {

                        Text(avatarName)
                            .font(
                                .system(
                                    size: 18,
                                    weight: .semibold
                                )
                            )

                        Text(
                            "Tap to browse all 24 expressions"
                        )
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(
                        systemName: "chevron.right"
                    )
                    .font(
                        .system(
                            size: 14,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(.secondary)
                }
                .padding(18)
                .background(
                    Color.secondary.opacity(0.07)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 22
                    )
                )
                .overlay(
                    RoundedRectangle(
                        cornerRadius: 22
                    )
                    .stroke(
                        onboardingData.selectedAvatar.isEmpty
                        ? Color.clear
                        : Color(
                            red: 1.0,
                            green: 0.45,
                            blue: 0.35
                        ),
                        lineWidth: 2
                    )
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Field

    private func onboardingField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType,
        field: Field
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 7
        ) {

            Text(title)
                .font(
                    .system(
                        size: 14,
                        weight: .semibold
                    )
                )
                .foregroundStyle(.secondary)

            TextField(
                placeholder,
                text: text
            )
            .font(
                .system(
                    size: 17,
                    weight: .medium
                )
            )
            .keyboardType(keyboard)
            .textInputAutocapitalization(
                keyboard == .emailAddress
                ? .never
                : .words
            )
            .autocorrectionDisabled()
            .focused(
                $focusedField,
                equals: field
            )
            .padding(.horizontal, 17)
            .padding(.vertical, 16)
            .background(
                Color.secondary.opacity(0.07)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 17
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 17
                )
                .stroke(
                    focusedField == field
                    ? Color(
                        red: 1.0,
                        green: 0.45,
                        blue: 0.35
                    )
                    : Color.secondary.opacity(0.10),
                    lineWidth:
                        focusedField == field
                        ? 2
                        : 1
                )
            )
        }
    }

    // MARK: - Send magic link

    private func sendMagicLink() {

        isSendingLink = true
        authError = nil

        Task {

            do {

                try await supabase.auth.signInWithOTP(
                    email: onboardingData.email,
                    redirectTo: URL(
                        string:
                            "days84://auth-callback"
                    )
                )

                print("✅ Magic link sent")

                withAnimation(
                    .spring(
                        response: 0.45,
                        dampingFraction: 0.8
                    )
                ) {
                    emailSent = true
                }

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
