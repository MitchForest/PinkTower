## PinkTower Build Tracker

### Must Follow (applies to all sessions)

- **Platform**: iOS 17+ only.
- **Architecture**: MVVM + Services. Views render UI; ViewModels own state and business logic; Services encapsulate I/O (data, network, system). Use dependency inversion via protocols and dependency injection. Maintain strict separation of concerns.
- **Design system**: Build a beautiful, minimal, Montessori aesthetic design system over time. No hard‑coded styles; use design tokens (color, typography, spacing, radius, motion). All UI must consume the design system for consistency. Support Light/Dark and Dynamic Type.
- **Process**: Implement only what the user explicitly approves. Propose changes first; do not proceed without approval.
- **Quality**: Favor clarity over cleverness. No premature optimization or “performance theater”; measure before optimizing.
- **Consistency & maintainability**: Small, cohesive modules; testable ViewModels/Services; avoid singletons unless justified.
- **Separation of concerns**: Keep boundaries clean between View, ViewModel, and Services across the codebase.

### Session log

#### Session 1 — Kickoff (2025-09-14)

- Created this tracker.
- Established the "Must Follow" guardrails for the project.

##### Plan and scope

- Deliver in Session 1: Login (Sign in with Apple), app shell (top nav + bottom tabs), Homeroom listing, Settings CRUD for Classrooms/Students/Guides (role-gated), basic Search, Notifications placeholder, Design System v0.
- Constraints: iOS 17+, MVVM + Services, SwiftUI native, no hard-coded styles, design system-first, separation of concerns, only user-approved scope, no premature optimization.

##### Architecture

- Views (SwiftUI) → ViewModels (state + orchestration) → Services (I/O via protocols). Dependency inversion + DI. SwiftData for persistence.

##### Data model (v1)

- GuideRole: `.superAdmin`, `.admin`, `.guide`
- Guide: `id`, `fullName`, `email?`, `role`, `defaultClassroomId?`, `avatarURL?`
- Classroom: `id`, `name`, `imageURL?`, `guideIds: [UUID]`, `studentIds: [UUID]`, `createdAt`
- Student: `id`, `firstName`, `lastName`, `displayName`, `imageURL?`, `createdAt`, `notes?`

##### Services

- AuthService (Sign in with Apple + Keychain), SessionService (current guide + selected/default classroom), Persistence (SwiftData), ClassroomService, StudentService, GuideService, ImageService (placeholder), PermissionService.

##### Navigation & tabs

- Root routing: SignIn → CreateClassroomPrompt (if no default) → MainTabView.
- Top toolbar: Title (left), Notifications (right), Avatar menu (right).
- Tabs: Homeroom | My Day | Settings | Search.

##### Screens

- SignInView: H1 “Pink Tower”, subtitle, native Sign in with Apple button.
- CreateClassroomPromptView → CreateClassroomView (name + image placeholder).
- HomeroomView: List/grid of students for selected classroom.
- SettingsView: CRUD Classrooms/Students/Guides (role-gated).
- SearchView: Search students by name.
- Notifications: placeholder.

##### Design system v0

- Tokens: Colors, Typography, Spacing, Radius; components: PTButton, PTAvatar, PTSectionHeader.

##### Permissions

- Super Admin: CRUD Guides + all.
- Admin: CRUD Students + manage Classrooms.
- Guide: view Homeroom, limited actions (later).

##### Implementation order

1) Enable Sign in with Apple capability; scaffold DS tokens and components. 2) SwiftData models. 3) Auth + Session services. 4) App shell and routing. 5) Domain services. 6) Screens (Create classroom, Homeroom, Settings CRUD, Search). 7) Polishing (avatar menu, notifications). 8) Tests (selected ViewModels/Services).

##### Checklist (Session 1)

- [x] Document full Session 1 plan in `.docs/tracker.md`
- [x] Scaffold design system tokens and components
- [x] Define domain models (SwiftData): GuideRole, Guide, Classroom, Student
- [x] Update app schema and root routing
- [x] Implement AuthService (Sign in with Apple + Keychain)
- [x] Implement SessionService (current guide, default classroom)
- [x] Build SignInView with Apple button
- [x] CreateClassroomPromptView + CreateClassroomView flow
- [x] Build MainTabView with top nav and bottom tabs
- [x] Implement HomeroomView (students list)
- [x] Implement SettingsView CRUD (Classrooms/Students/Guides) with permissions
- [x] Implement SearchView (students)
- [x] Add PermissionService and gate actions
- [x] Add Notifications placeholder and Avatar menu
- [ ] Record progress checkpoints and check off tasks
  
Progress notes:
- Implemented Classroom/Student/Guide services and role-based Settings CRUD screens. Notifications placeholder wired from toolbar. Homeroom list and Search in place. Next: continued UI polish and additional actions per roles in future sessions.


