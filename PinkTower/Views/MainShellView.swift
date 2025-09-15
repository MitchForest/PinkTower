import SwiftUI
import SwiftData

enum MainScreen {
    case classrooms, students, search, notifications, myDay, settings
}

struct MainShellView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var current: MainScreen = .classrooms
    @State private var showMenu: Bool = false
    @State private var menuWidth: CGFloat = 0
    @State private var showSearchSheet: Bool = false
    @State private var showStudentSheet: Bool = false
    @State private var showClassroomSwitcherSheet: Bool = false
    @State private var showCreateClassroomSheet: Bool = false
    @State private var studentFromSearch: Student?
    @State private var isDetail: Bool = false
    @Namespace private var menuNamespace

    var body: some View {
        ZStack(alignment: .leading) {
            content
                .background(PTColors.surface)
                .offset(x: showMenu ? menuWidth : 0)
                .animation(PTMotion.springMedium, value: showMenu)

            // Tap-outside-to-close scrim (only covers area to the right of the menu)
            GeometryReader { proxy in
                if showMenu {
                    Color.black.opacity(0.001)
                        .frame(width: max(0, proxy.size.width - menuWidth), height: proxy.size.height)
                        .contentShape(Rectangle())
                        .position(x: (proxy.size.width - menuWidth) / 2 + menuWidth, y: proxy.size.height / 2)
                        .onTapGesture { withAnimation(PTMotion.springMedium) { showMenu = false } }
                        .transition(.opacity)
                        .zIndex(1)
                }
            }

            menuPanel
                .frame(width: menuWidth)
                .offset(x: showMenu ? 0 : -menuWidth)
                .animation(PTMotion.springMedium, value: showMenu)
        }
        .safeAreaInset(edge: .top) {
            PTNavBar(
                title: currentClassroomName() ?? "Pink Tower",
                showTitleMenu: false,
                showBackButton: isDetail,
                onTitleTap: { showClassroomSwitcherSheet = true },
                onBack: {
                    NotificationCenter.default.post(name: .init("PopStudentDetail"), object: nil)
                    withAnimation(PTMotion.springMedium) { isDetail = false }
                },
                onHamburger: { withAnimation(PTMotion.springMedium) { showMenu.toggle() } },
                onSearch: { NotificationCenter.default.post(name: .init("ShowGlobalSearch"), object: nil) },
                onNotifications: { current = .notifications },
                onAvatar: { current = .myDay }
            ) { EmptyView() }
            .accessibilityAddTraits(.isHeader)
            .offset(x: showMenu ? menuWidth : 0)
            .animation(PTMotion.springMedium, value: showMenu)
        }
        .onAppear { bootstrapCurrentScreen() }
        .onReceive(NotificationCenter.default.publisher(for: .init("ShowGlobalSearch"))) { _ in
            showSearchSheet = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("OpenStudentFromSearch"))) { note in
            if let s = note.object as? Student {
                studentFromSearch = s
                showStudentSheet = true
                current = .students
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("EnterDetail"))) { _ in
            withAnimation(PTMotion.springMedium) { isDetail = true }
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("ExitDetail"))) { _ in
            withAnimation(PTMotion.springMedium) { isDetail = false }
        }
        .ptBottomSheet(isPresented: $showSearchSheet) {
            NavigationStack { GlobalSearchSheet().environmentObject(appVM) }
        }
        .ptModal(isPresented: $showClassroomSwitcherSheet) {
            ClassroomSwitcherSheet(
                selectedId: appVM.selectedClassroomId,
                onSelect: { room in
                    appVM.selectedClassroomId = room.id
                    current = .students
                    showClassroomSwitcherSheet = false
                },
                onAdd: { showClassroomSwitcherSheet = false; showCreateClassroomSheet = true }
            )
        }
        .sheet(isPresented: $showCreateClassroomSheet) {
            CreateClassroomView(onCreated: { id in
                appVM.selectedClassroomId = id
                current = .students
            })
        }
        .ptBottomSheet(isPresented: $showStudentSheet) {
            NavigationStack {
                if let s = studentFromSearch {
                    StudentPageView(student: s, compact: true)
                } else {
                    EmptyView()
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch current {
        case .classrooms:
            ClassroomsView()
        case .students:
            HomeroomView()
        case .search:
            EmptyView()
        case .notifications:
            NotificationsView()
        case .myDay:
            MyDayView()
        case .settings:
            SettingsView()
        }
    }

    @ViewBuilder
    private var menuPanel: some View {
        GeometryReader { proxy in
            let w = min(max(proxy.size.width * 0.8, 260), 340)
            Color.clear.onAppear { menuWidth = w }
            VStack(alignment: .leading, spacing: PTSpacing.l.rawValue) {
                // Account header
                if let guide = appVM.currentGuide {
                    HStack(alignment: .center, spacing: PTSpacing.m.rawValue) {
                        PTAvatar(image: nil, preset: .s, initials: initials(for: guide.fullName))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(guide.fullName)
                                .font(PTTypography.subtitle)
                                .foregroundStyle(PTColors.textPrimary)
                                .lineLimit(1)
                            if let email = guide.email, !email.isEmpty {
                                Text(email)
                                    .font(PTTypography.caption)
                                    .foregroundStyle(PTColors.textSecondary)
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 24)
                } else {
                    Text("Menu")
                        .font(PTTypography.title)
                        .foregroundStyle(PTColors.textPrimary)
                        .padding(.top, 24)
                }
                Button(action: { withAnimation { current = .settings; showMenu = false } }) {
                    Label("Settings", systemImage: "gearshape")
                        .font(PTTypography.body)
                        .foregroundStyle(PTColors.textPrimary)
                }
                Button(action: { withAnimation { current = .classrooms; showMenu = false } }) {
                    Label("Classrooms", systemImage: "building.2")
                        .font(PTTypography.body)
                        .foregroundStyle(PTColors.textPrimary)
                }
                Spacer()
            }
            .padding(.horizontal, PTSpacing.l.rawValue)
            .frame(width: w, alignment: .leading)
            .frame(maxHeight: .infinity)
            .background(PTColors.surfaceSecondary)
            .overlay(Rectangle().frame(width: 1).foregroundStyle(PTColors.border), alignment: .trailing)
            .ignoresSafeArea(edges: .vertical)
        }
    }

    private func initials(for fullName: String) -> String {
        let parts = fullName.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.dropFirst().first?.prefix(1) ?? ""
        return String(first + last)
    }

    private func bootstrapCurrentScreen() {
        if appVM.selectedClassroomId != nil { current = .students } else { current = .classrooms }
    }

    private func currentClassroomName() -> String? {
        guard let id = appVM.selectedClassroomId else { return nil }
        var descriptor = FetchDescriptor<Classroom>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first?.name
    }
}

private struct ClassroomSwitcherSheet: View {
    @Query private var rooms: [Classroom]
    let selectedId: UUID?
    let onSelect: (Classroom) -> Void
    let onAdd: () -> Void

    init(selectedId: UUID?, onSelect: @escaping (Classroom) -> Void, onAdd: @escaping () -> Void) {
        self.selectedId = selectedId
        self.onSelect = onSelect
        self.onAdd = onAdd
        _rooms = Query()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PTSpacing.l.rawValue) {
            Text("Classrooms").font(PTTypography.title).foregroundStyle(PTColors.textPrimary)
            if rooms.isEmpty {
                Button("Add classroom", action: onAdd).ptPrimary()
            } else {
                ForEach(rooms) { room in
                    Button(action: { onSelect(room) }) {
                        HStack(spacing: PTSpacing.m.rawValue) {
                            if room.id == selectedId { Image(systemName: "checkmark").foregroundStyle(PTColors.accent) }
                            Text(room.name).foregroundStyle(PTColors.textPrimary)
                            Spacer()
                        }
                        .padding(.vertical, PTSpacing.s.rawValue)
                    }
                    .buttonStyle(.plain)
                }
                Divider()
                Button("Add classroom", action: onAdd).ptSecondary()
            }
        }
        .padding(PTSpacing.l.rawValue)
        .background(PTColors.surface)
    }
}

private struct ClassroomSwitcherMenuContent: View {
    @Query private var rooms: [Classroom]
    let selectedId: UUID?
    let onSelect: (Classroom) -> Void
    let onAdd: () -> Void

    init(selectedId: UUID?, onSelect: @escaping (Classroom) -> Void, onAdd: @escaping () -> Void) {
        self.selectedId = selectedId
        self.onSelect = onSelect
        self.onAdd = onAdd
        _rooms = Query()
    }

    var body: some View {
        if rooms.isEmpty {
            Button("Add classroom", action: onAdd)
        } else {
            ForEach(rooms) { room in
                Button(action: { onSelect(room) }) {
                    HStack {
                        if room.id == selectedId { Image(systemName: "checkmark") }
                        Text(room.name)
                    }
                }
            }
            Divider()
            Button("Add classroom", action: onAdd)
        }
    }
}


