import SwiftUI
import SwiftData
import Combine

struct FocusView: View {

    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<TaskItem> { !$0.isComplete },
        sort: \TaskItem.createdAt,
        order: .reverse
    )
    private var tasks: [TaskItem]

    enum TimerMode {
        case focus
        case breakTime
    }

    // MARK: - Timer

    @State private var mode: TimerMode = .focus

    @State private var focusMinutes: Int = 25
    @State private var breakMinutes: Int = 5

    @State private var remainingSeconds: Int = 25 * 60

    @State private var isRunning = false
    @State private var hasStarted = false

    @State private var sessionStartDate: Date?
    @State private var phaseStartDate: Date?

    @State private var selectedTaskID: UUID?

    private let coral = Color(
        red: 0.996,
        green: 0.443,
        blue: 0.376
    )

    // MARK: - Computed Properties

    private var selectedMinutes: Int {
        mode == .focus
        ? focusMinutes
        : breakMinutes
    }

    private var totalSeconds: Int {
        selectedMinutes * 60
    }

    // Progress while timer is running
    private var progress: Double {
        guard totalSeconds > 0 else {
            return 0
        }

        return min(
            max(
                Double(remainingSeconds) /
                Double(totalSeconds),
                0
            ),
            1
        )
    }

    // Initial amount of the ring to fill.
    // 25 minutes = 20.8%
    // 60 minutes = 50%
    // 120 minutes = 100%
    private var selectedDurationProgress: Double {
        Double(selectedMinutes) / 120.0
    }

    // Both the ring AND handle use this.
    private var ringProgress: Double {
        hasStarted
        ? progress
        : selectedDurationProgress
    }

    private var ringAngle: Double {
        (ringProgress * 360) - 90
    }

    private var formattedTime: String {
        String(
            format: "%02d:%02d",
            remainingSeconds / 60,
            remainingSeconds % 60
        )
    }

    private var incompleteTasks: [TaskItem] {
        tasks.filter {
            !$0.isComplete
        }
    }

    private var selectedTask: TaskItem? {
        guard let selectedTaskID else {
            return nil
        }

        return incompleteTasks.first {
            $0.id == selectedTaskID
        }
    }

    // MARK: - Body

    var body: some View {

        ScrollView {

            VStack(spacing: 22) {

                header

                modeSelector

                timerCard

                taskSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(
            Color(.systemGroupedBackground)
        )
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            resetTimer()
        }
        .onReceive(
            Timer.publish(
                every: 1,
                on: .main,
                in: .common
            ).autoconnect()
        ) { _ in
            updateTimer()
        }
    }

    // MARK: - Header

    private var header: some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            Text("FOCUS")
                .font(
                    .system(
                        size: 14,
                        weight: .bold
                    )
                )
                .tracking(1.5)
                .foregroundStyle(coral)

            Text("Deep work.")
                .font(
                    .system(
                        size: 30,
                        weight: .bold
                    )
                )

            Text(
                "Set a timer, choose a task and get to work."
            )
            .font(.system(size: 15))
            .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    // MARK: - Mode Selector

    private var modeSelector: some View {

        HStack(spacing: 0) {

            modeButton(
                title: "Focus",
                icon: "brain.head.profile",
                mode: .focus
            )

            modeButton(
                title: "Break",
                icon: "cup.and.saucer.fill",
                mode: .breakTime
            )
        }
        .padding(5)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    private func modeButton(
        title: String,
        icon: String,
        mode buttonMode: TimerMode
    ) -> some View {

        Button {

            guard !hasStarted else {
                return
            }

            mode = buttonMode
            resetTimer()

        } label: {

            HStack(spacing: 8) {

                Image(systemName: icon)

                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundStyle(
                mode == buttonMode
                ? .primary
                : .secondary
            )
            .background {

                if mode == buttonMode {

                    RoundedRectangle(
                        cornerRadius: 12
                    )
                    .fill(
                        Color(.systemBackground)
                    )
                    .shadow(
                        color: .black.opacity(0.08),
                        radius: 4,
                        y: 2
                    )
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(hasStarted)
    }

    // MARK: - Timer Card

    private var timerCard: some View {

        VStack(spacing: 22) {

            GeometryReader { geometry in

                let size = min(
                    geometry.size.width,
                    geometry.size.height
                )

                let center = CGPoint(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 2
                )

                ZStack {

                    // Background ring
                    Circle()
                        .stroke(
                            Color(.tertiarySystemBackground),
                            lineWidth: 18
                        )

                    // Filled ring
                    Circle()
                        .trim(
                            from: 0,
                            to: ringProgress
                        )
                        .stroke(
                            mode == .focus
                            ? coral
                            : .green,
                            style: StrokeStyle(
                                lineWidth: 18,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(
                            .degrees(-90)
                        )

                    // Timer
                    VStack(spacing: 7) {

                        Text(formattedTime)
                            .font(
                                .system(
                                    size: 48,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .monospacedDigit()

                        Text(
                            mode == .focus
                            ? "FOCUS"
                            : "BREAK"
                        )
                        .font(
                            .system(
                                size: 12,
                                weight: .bold
                            )
                        )
                        .tracking(2)
                        .foregroundStyle(.secondary)
                    }

                    // Handle
                    if !hasStarted {

                        let angle = Angle(
                            degrees: ringAngle
                        )

                        // Exactly matches the centre
                        // of the ring stroke
                        let radius = (size / 2) - 9

                        Circle()
                            .fill(
                                mode == .focus
                                ? coral
                                : .green
                            )
                            .frame(
                                width: 28,
                                height: 28
                            )
                            .shadow(
                                color:
                                    .black.opacity(0.15),
                                radius: 5
                            )
                            .position(
                                x:
                                    center.x +
                                    cos(angle.radians) *
                                    radius,

                                y:
                                    center.y +
                                    sin(angle.radians) *
                                    radius
                            )
                    }
                }
                .frame(
                    width: size,
                    height: size
                )
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 2
                )
                .contentShape(Circle())
                .gesture(

                    DragGesture()

                        .onChanged { value in

                            guard !hasStarted else {
                                return
                            }

                            updateDuration(
                                from: value.location,
                                center: center
                            )
                        }
                )
            }
            .frame(height: 260)

            // Buttons
            HStack(spacing: 12) {

                Button {

                    resetTimer()

                } label: {

                    Image(
                        systemName:
                            "arrow.counterclockwise"
                    )
                    .font(
                        .system(
                            size: 17,
                            weight: .semibold
                        )
                    )
                    .frame(
                        width: 52,
                        height: 52
                    )
                    .background(
                        Color(
                            .secondarySystemBackground
                        ),
                        in: Circle()
                    )
                }
                .buttonStyle(.plain)

                Button {

                    toggleTimer()

                } label: {

                    HStack(spacing: 10) {

                        Image(
                            systemName:
                                isRunning
                                ? "pause.fill"
                                : "play.fill"
                        )

                        Text(
                            isRunning
                            ? "Pause"
                            : hasStarted
                            ? "Resume"
                            : "Start"
                        )
                        .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .foregroundStyle(.white)
                    .background(
                        mode == .focus
                        ? coral
                        : .green,
                        in: Capsule()
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(22)
        .background(
            Color(.systemBackground),
            in: RoundedRectangle(
                cornerRadius: 28
            )
        )
    }

    // MARK: - Task Section

    private var taskSection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            HStack {

                Text("FOCUS TASK")
                    .font(
                        .system(
                            size: 13,
                            weight: .bold
                        )
                    )
                    .tracking(1)

                Spacer()

                if selectedTask != nil {

                    Button("Clear") {

                        selectedTaskID = nil
                    }
                    .font(
                        .system(
                            size: 13,
                            weight: .semibold
                        )
                    )
                }
            }

            Menu {

                Button("No task") {

                    selectedTaskID = nil
                }

                if !incompleteTasks.isEmpty {

                    Divider()

                    ForEach(
                        incompleteTasks
                    ) { task in

                        Button {

                            selectedTaskID =
                                task.id

                        } label: {

                            Label(
                                task.name,
                                systemImage:
                                    task.icon
                            )
                        }
                    }
                }

            } label: {

                HStack(spacing: 12) {

                    Image(
                        systemName:
                            selectedTask?.icon
                            ?? "checkmark.circle"
                    )
                    .font(
                        .system(size: 20)
                    )
                    .foregroundStyle(
                        selectedTask == nil
                        ? .secondary
                        : coral
                    )

                    VStack(
                        alignment: .leading,
                        spacing: 3
                    ) {

                        Text(
                            selectedTask?.name
                            ?? "Choose a task"
                        )
                        .font(
                            .system(
                                size: 15,
                                weight: .semibold
                            )
                        )

                        if selectedTask == nil {

                            Text(
                                "What are you working on?"
                            )
                            .font(
                                .system(size: 13)
                            )
                            .foregroundStyle(
                                .secondary
                            )
                        }
                    }

                    Spacer()

                    Image(
                        systemName:
                            "chevron.up.chevron.down"
                    )
                    .font(
                        .system(
                            size: 12,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        .secondary
                    )
                }
                .padding(16)
                .background(
                    Color(
                        .secondarySystemBackground
                    ),
                    in: RoundedRectangle(
                        cornerRadius: 16
                    )
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Duration Adjustment

    private func updateDuration(
        from location: CGPoint,
        center: CGPoint
    ) {

        let dx =
            location.x - center.x

        let dy =
            location.y - center.y

        var degrees =
            atan2(dy, dx)
            * 180
            / .pi

        // 12 o'clock becomes 0
        degrees += 90

        if degrees < 0 {
            degrees += 360
        }

        let percentage =
            degrees / 360

        var minutes =
            Int(
                round(
                    percentage * 120
                )
            )

        minutes = max(
            1,
            min(minutes, 120)
        )

        if mode == .focus {

            focusMinutes = minutes

        } else {

            breakMinutes = minutes
        }

        remainingSeconds =
            minutes * 60
    }

    // MARK: - Timer Controls

    private func toggleTimer() {

        // Pause
        if isRunning {

            isRunning = false
            return
        }

        let now = Date()

        // Start
        if !hasStarted {

            hasStarted = true
            isRunning = true

            phaseStartDate = now

            if mode == .focus {

                sessionStartDate = now
            }

            return
        }

        // Resume
        let elapsed =
            totalSeconds -
            remainingSeconds

        phaseStartDate =
            Date(
                timeIntervalSinceNow:
                    -TimeInterval(elapsed)
            )

        isRunning = true
    }

    // MARK: - Reset

    private func resetTimer() {

        isRunning = false
        hasStarted = false

        sessionStartDate = nil
        phaseStartDate = nil

        remainingSeconds =
            selectedMinutes * 60
    }

    // MARK: - Timer Updates

    private func updateTimer() {

        guard
            isRunning,
            let phaseStartDate
        else {
            return
        }

        let elapsed =
            Int(
                Date().timeIntervalSince(
                    phaseStartDate
                )
            )

        let newRemaining =
            max(
                totalSeconds -
                elapsed,
                0
            )

        if newRemaining != remainingSeconds {

            remainingSeconds =
                newRemaining
        }

        if newRemaining <= 0 {

            finishCurrentPhase()
        }
    }

    // MARK: - Phase Completion

    private func finishCurrentPhase() {

        isRunning = false

        if mode == .focus {

            saveFocusSession()

            // Move to break
            mode = .breakTime

            hasStarted = false
            phaseStartDate = nil

            remainingSeconds =
                breakMinutes * 60

        } else {

            // Break finished
            // Return to focus
            mode = .focus

            hasStarted = false
            phaseStartDate = nil

            remainingSeconds =
                focusMinutes * 60
        }
    }

    // MARK: - Save Focus Session

    private func saveFocusSession() {

        guard let sessionStartDate else {
            return
        }

        let session =
            FocusSession(
                startDate:
                    sessionStartDate,

                duration:
                    TimeInterval(
                        focusMinutes * 60
                    ),

                breakTime:
                    TimeInterval(
                        breakMinutes * 60
                    ),

                completed: true,

                taskID:
                    selectedTaskID
            )

        modelContext.insert(session)

        do {

            try modelContext.save()

        } catch {

            print(
                "Failed to save focus session: \(error)"
            )
        }
    }
}

// MARK: - Preview

#Preview {

    NavigationStack {

        FocusView()
    }
}
