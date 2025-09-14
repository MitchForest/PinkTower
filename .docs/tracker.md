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



#### Session 2 — Student Page (2025-09-14)

##### Plan and scope

- Goal: A fast student-centric workspace to capture observations, manage habits, lessons, and tasks, plus generate/share AI summaries. Minimal clicks, show only essentials; tap to reveal details.
- Navigation:
  - From `HomeroomView` and `SearchView`, tapping a student opens `StudentPageView(student:)`.
  - Keep `Settings > Students > StudentDetailView` for admin editing.
- Data models (SwiftData):
  - `Observation`: `id`, `primaryStudentId`, `taggedStudentIds: [UUID]`, `content`, `createdAt`, `createdByGuideId`, `subjectTag?`, `materialTag?`, `appTag?`, `attachments: [String]?`
  - `Habit`: `id`, `studentId`, `name`, `cadence` (enum: `.daily`, `.weekly`, `.monthly`), `createdAt`, `createdByGuideId`
  - `HabitLog`: `id`, `habitId`, `date` (day granularity), `isDone`, `createdByGuideId`, `createdAt`
  - `Lesson`: `id`, `studentId`, `title`, `details?`, `createdAt`, `createdByGuideId`, `scheduledFor?`, `completedAt?`, `completedByGuideId?`
  - `Task`: `id`, `studentId`, `title`, `details?`, `createdAt`, `createdByGuideId`, `scheduledFor?`, `completedAt?`, `completedByGuideId?`
  - `ParentContact`: `id`, `studentId`, `fullName`, `email?`, `phone?`
- Services:
  - `ObservationService`, `HabitService` (with `toggleToday`), `LessonService`, `TaskService`, `SharingService` (build shareable text), `AIService` (OpenAI: Whisper for STT; GPT for insights/summary).
- AI key management:
  - Use an app-wide secret (bundled `Secrets.plist` entry like `OPENAI_API_KEY`), read via `ConfigService`.
  - Allow override/storage in Keychain (key `openai_api_key`) from a new `AISettingsView` in Settings.
- ViewModel:
  - `StudentPageViewModel` orchestrates sections, loads student-scoped data, applies filters, and calls services.
- Views (MVP):
  - `StudentPageView`
    - Quick Capture (Observation/Lesson/Task): multiline field, mic button to record → transcribe → append; Save with auto metadata.
    - Habits: list of habits with one-tap check for today; Manage sheet to add/edit (name + cadence).
    - Observations: search, sort (Newest/Oldest), filters (time range, tags, tagged students). Cards show content + creator + time.
    - Lessons: rows with completion checkbox, optional schedule; expand for details.
    - Tasks: same as Lessons.
    - AI: timeframe segmented (Today/Week/Month) with buttons for Insights (suggest lessons/tasks; Accept creates) and Summary (editable; Share to parents).
- Permissions: Respect `PermissionService` for mutations; disable UI when disallowed.
- Stretch (defer if needed): photo attachments, weekly/monthly habit overview, persistent taxonomies for Subjects/Materials/Apps, Parent contacts management UI.
- Defaults: Whisper `whisper-1` for STT; GPT `gpt-4o-mini` for text; store API key in Secrets/Keychain; no backend required in this session.

##### Checklist (Session 2)

- [x] Document Session 2 plan in `.docs/tracker.md`
- [x] Wire navigation from Homeroom/Search to `StudentPageView`
- [x] Add SwiftData models: Observation, Habit, HabitLog, Lesson, Task, ParentContact
- [x] Implement services: ObservationService, HabitService, LessonService, TaskService, SharingService
- [x] Add AIService and ConfigService; app-wide OpenAI key via `Secrets.plist` + Keychain override; `AISettingsView`
- [x] Implement `StudentPageViewModel`
- [x] Build `StudentPageView` sections: Quick Capture (with voice), Habits, Observations (search/sort/filter), Lessons, Tasks, AI (insights + summary + share)
- [x] Apply permission gating across Student features

Progress notes:
- Added `StudentPageView` with Quick Capture, Habits (toggle), Observations (search/sort/filter), Lessons/Tasks (completion), and AI UI placeholders.
- Introduced SwiftData models for Student artifacts and corresponding Services.
- Added `AISettingsView` and `ConfigService` to manage an app-wide OpenAI key via Secrets.plist with Keychain override.
- Implemented audio recording service and plumbing for future transcription; AI calls are stubbed pending API integration.


#### Session 2 — Multi‑tenancy Addendum (Orgs/Schools + Invites) (2025-09-14)

##### Plan and scope

- Goal: Make the app multi‑tenant. All data is partitioned by Organization (aka School). A signed‑in guide must belong to an Organization to use classroom features. If they have no org, they must create one. The first guide becomes `superAdmin`. Super/Admins can invite other guides (default role: `guide`) and manage roles.
- Non‑backend constraint (for this session): Implement local, code‑based invites (code/QR) and manual redemption on the invitee’s device. A future session will move invites to a backend for secure, real email links.

##### Data model (SwiftData) changes

- Organization: `id`, `name`, `createdAt`
- Membership: `id`, `orgId`, `guideId`, `role` (enum: `.superAdmin`, `.admin`, `.guide`), `createdAt`
- Invite: `id`, `orgId`, `code` (UUID string), `role`, `createdByGuideId`, `createdAt`, `expiresAt?`, `redeemedAt?`
- Classroom: add `orgId`
- Student: add `orgId`
- Note: Student artifacts (Observation, Habit, HabitLog, Lesson, TaskItem, ParentContact) are scoped by student; they inherit org via the student. No direct `orgId` needed for them in this session.

##### Services

- OrgService: `create(name)`, `rename`, `listFor(guide)`, `setActive(orgId)`, `delete (later)`
- MembershipService: `membersOf(orgId)`, `role(of guide,in org)`, `add(guide, role, org)`, `remove(guide, org)`, `updateRole(guide, role, org)`
- InviteService: `create(orgId, role) -> Invite`, `revoke(invite)`, `list(orgId)`, `redeem(code, by guide) -> Membership`
- SessionService (update):
  - On sign‑in: if guide has no memberships → route `.promptCreateOrganization`.
  - If guide has memberships but no active org → pick last used or prompt selection.
  - Persist `activeOrgId` (per guide/device) and scope queries by it.

##### Permissions (org‑scoped)

- Resolve effective role from `Membership` for `activeOrgId`.
- `superAdmin`: manage org (rename, delete later), manage members (add/remove, change roles), manage classrooms/students/guides.
- `admin`: manage classrooms/students, view members, create invites.
- `guide`: view and contribute student content per classroom assignment.

##### Routing & UX

- Sign‑in flow:
  - If no memberships → `CreateOrganizationView` (name) → create org + membership `.superAdmin` → proceed to `CreateClassroomPromptView`.
  - If memberships exist but no active org → `SelectOrganizationView` (switcher, searchable list) → pick active org → proceed.
- Settings > Organization (new section):
  - Organization profile: name (rename), active org switcher (if >1).
  - Members: list members (name, email, role); change role; remove member.
  - Invites: list pending; create invite (role); share via code/QR; revoke invite.
  - Join organization: enter invite code → redeem → add membership.
- Classrooms/Students/Guides: automatically filtered by `activeOrgId`; create/edit/delete gated by role.

##### Migration (dev)

- On first run after this change: if existing local data lacks an Organization:
  - Create a default Organization named “My School”, add current guide as `.superAdmin`, set it active.
  - Backfill `orgId` into existing `Classroom` and `Student` rows.
  - For dev devices, uninstalling the app also resets the store (fast path if needed).

##### Non‑goals (defer)

- Real email invites with secure tokens (requires backend)
- Cross‑device acceptance tracking and audit logs
- Org deletion and data export

##### Checklist (Multi‑tenancy Addendum)

- [ ] Add models: Organization, Membership, Invite; add `orgId` to Classroom and Student
- [ ] Update `ModelContainer` schema
- [ ] Update `SessionService` for org bootstrap and active org
- [ ] Add `CreateOrganizationView` + `SelectOrganizationView`
- [ ] Add Organization section in Settings: Profile, Members (role management), Invites (create/revoke), Join (redeem code)
- [ ] Update `PermissionService` to resolve role via Membership
- [ ] Scope queries by `activeOrgId` across views/services
- [ ] Dev migration/backfill for existing local data
- [ ] UX polish (empty states, toasts)


#### Session 3 — UI/UX Overhaul and Onboarding (2025-09-14)

Goal: Craft a Montessori‑inspired, minimal, highly intentional experience. Reduce cognitive load and clicks, always center the primary action, and follow Apple native patterns. This session is solely visual/UX: routing, empty states, onboarding, components, motion, and feedback. No backend changes.

Design tenets
- Calm, Montessori vibe: warm neutrals, gentle contrast, rounded organic shapes, generous whitespace.
- Only show what’s needed for the next step. Everything else is one tap away or hidden.
- Actions centered on full‑page steps; lists are quiet; creation is obvious.
- Use Apple patterns first (sheet detents, context menus, swipe actions, toolbars), then custom components.
- Micro‑feedback after every create/complete action (haptics + checkmark burst).

Visual language (Design System v1.1)
- Colors: expand `PTColors` with natural palette (Sand, Clay, Leaf, Sky, Berry) and supporting semantic roles (surfaceAlt, outlineSubtle, successMuted, warningMuted). Maintain dark mode.
- Typography: keep current scales; add Display weight for hero titles; ensure Dynamic Type AA+.
- Spacing/Radius: keep tokens; add `xxxl` spacing, and `pill` radius for capsule bars.
- Motion: add timing tokens (easeOutSoft 280ms, springMedium 0.6/0.8/0). Define reusable transitions (fadeUp, scaleIn, checkPop).

New reusable components (SwiftUI)
- `PTTopBarCapsule`: Rounded capsule bar (not full width) with centered title, trailing icons: notifications, search, avatar menu, hamburger for overflow. Auto adjusts width by device size classes.
- `PTScreen`: Safe‑area aware background with soft shape insets for the Montessori feel; hosts optional hero/empty illustration.
- `PTFloatingActionButton`: Elevated circular button (primary color), shadow subtle; supports plus and contextual icons; keyboard‑aware.
- `PTBottomSheet`: Wrapper of native sheet with `.presentationDetents([.fraction(0.9), .large])`, grabber enabled, scroll edge behavior consistent. Hosts any content; integrates dismissal haptics.
- `PTEmptyState`: Centered card with title, tip text, and a single primary action; optional secondary “I have a code” link pattern.
- `PTCheckmarkBurst`: success animation (shape morph + confetti speckles) and `Haptics.success()`.
- `PTListCell`: Comfortable list row with `PTAvatar`, title/subtitle, trailing affordances; supports `.contextMenu` and `.swipeActions`.
- `PTAttendancePill`: One‑tap attendance indicator (Present/Absent) with subtle color ring and haptic tap.
- `PTToast`: transient bottom toast for confirmations when a full success animation isn’t appropriate.

Routing & onboarding (full‑page, centered actions)
- After Sign‑In: Detect first‑time + no memberships.
  - `OnboardingWizardView` (three steps, centered):
    1) School name + avatar
    2) Classroom name + avatar
    3) Students (first, last, avatar) with Add Another and Finish
    Back/Next/Finish at bottom; users can go back and edit school/classroom until they finish.
  - `JoinOrganizationView` (conditional): If an invite code is redeemed, continue into `OnboardingWizardView` at the classroom step.
- Next login: Skip onboarding. If exactly 1 classroom in active org → land on Students tab. If multiple → open `ClassroomsView` list first.

Empty states (non‑distracting, centered form)
- No classrooms in org → `CreateClassroomView` full page, centered (Name, optional cover). Success → checkmark → show empty Students page next.
- No students in classroom → `CreateStudentView` full page, centered (First, Last, optional photo). After creating first, stay in the form with “Add another” and “Done”.

Classrooms page
- Layout: Quiet list/grid of classrooms using `PTListCell`. Each row: name, small student count.
- Primary action: `PTFloatingActionButton` bottom‑right “+ Classroom”.
- Interactions: tap opens Students page; long‑press `.contextMenu` with Edit, Rename, Delete; swipe actions for Delete/Rename (role‑gated).

Students page (for selected classroom)
- Layout: List of students with avatar, display name, optional status dot; right‑aligned `PTAttendancePill` for one‑tap attendance.
- Primary action: `PTFloatingActionButton` “+ Student”.
- Tap behavior: opens `PTBottomSheet` covering ~90% with `StudentPageView(student)` so the user maintains context. Pull to dismiss returns to list state.
- Long‑press: `.contextMenu` Edit, Remove from class, Delete (role‑gated).

Student page (within bottom sheet and as standalone)
- Keep current sections (Quick Capture, Habits, Observations, Lessons, Tasks, AI).
- Add floating quick‑add: `PTFloatingActionButton` that fans out to: Add Observation, Add Lesson, Add Task, Record (mic), Insights, Summary. Use spring reveal.
- Emphasize Today actions; defer filters behind a disclosure.

Top bar
- Replace existing full‑width toolbar with `PTTopBarCapsule` across major screens (Home/Students/Settings/Search). Middle title; trailing icons: Search, Notifications, Avatar menu; optional leading “hamburger” for future nav if needed.

Micro‑interactions & haptics
- `Haptics` utility: `success()`, `warning()`, `lightTap()`, `impact(.soft)`.
- Play `success()` + `PTCheckmarkBurst` after: create org, redeem invite, create classroom, create student, save observation/lesson/task, toggle habit/attendance.
- Toast confirmations where sheets dismiss quickly, otherwise rely on iconography and subtle animation.

Audit and improvements by screen/flow
- SignIn: Replace subtitle copy with concise benefit statement; center Apple button; soft illustration.
- CreateOrganization: Single field; defer advanced settings; success animation.
- JoinOrganization: Minimal code field + paste/scan; inline validation; success animation.
- GettingStarted: Bullet explainer with illustrations; one CTA.
- Classrooms: Calm list; FAB; empty state; context menu + swipe.
- Students: List with attendance pill; avatars; FAB; bottom sheet open on tap.
- StudentPage: Floating quick‑add; consistent section spacing; sheet detents; keyboard‑safe.
- Settings: Segment sections (Account, Organization, Members, Invites, AI settings). Use `PTTopBarCapsule`.
- Search: Search bar integrated into top bar; results list uses `PTListCell`.
- Notifications: Minimal list; unread dot; defer heavy UI.

Navigation changes (high level)
- Routes: `.promptCreateOrganization` and `.promptCreateClassroom` present `OnboardingWizardView`; `.promptJoinOrganization` presents `JoinOrganizationView`; `.main` is the tab shell.
- `SessionService.determineInitialRoute`: If first time and no memberships → `.promptCreateOrganization`; if memberships but no default classroom → `.promptCreateClassroom`; otherwise `.main`.
- Post‑login: If one classroom, select Students tab by default; if multiple, open `ClassroomsView` first.

Accessibility
- Support Dynamic Type up to XXL, VoiceOver labels for all buttons (including FAB and attendance pill), sufficient contrast (AA/AAA where possible), large hit targets (min 44×44pt).

Deliverables (this session)
- New DS tokens + components: `PTTopBarCapsule`, `PTScreen`, `PTFloatingActionButton`, `PTBottomSheet`, `PTEmptyState`, `PTCheckmarkBurst`, `PTToast`, `PTAttendancePill`, updated `PTListCell`.
- Onboarding: `OnboardingWizardView` (Org/Classroom/Students), `JoinOrganizationView` (optional).
- Empty‑state screens: `CreateClassroomView` (centered), `CreateStudentView` (centered, add‑another flow).
- Lists updated: Classrooms list with FAB; Students list with attendance and FAB; sheet presentation for StudentPage.
- Haptics utility integrated across flows.

Acceptance criteria
- After first sign‑in with no org: user completes the three‑step `OnboardingWizardView` (Org/Classroom/Students). They can go back to edit prior steps; student step supports adding multiple students. All actions are centered with visible placeholders.
- Next login: if 1 classroom, opens Students tab automatically; if >1, shows Classrooms list first.
- Empty org shows create‑classroom screen; empty classroom shows create‑student screen; both centered and distraction‑free.
- Tapping a student presents a bottom sheet covering ~90% with grabber; dismiss restores list scroll position.
- Long‑press on classroom/student shows native context menu; swipe actions available where appropriate.
- Visual style matches Montessori vibe; top bar is rounded capsule and not full width.
- Successful actions trigger haptics and a visible micro‑animation (checkmark burst or toast).

Checklist (UI/UX only)
- [ ] Update DS tokens (colors, motion) and add new components listed above
- [ ] Replace top bars with `PTTopBarCapsule`
- [ ] Implement `PTFloatingActionButton` and integrate on Classrooms/Students/StudentPage
- [ ] Implement `PTBottomSheet` wrapper and present `StudentPageView` at `.fraction(0.9)`
- [ ] Build `OnboardingWizardView` (Org/Classroom/Students) and `JoinOrganizationView` routing
- [ ] Implement empty states for Classrooms/Students with centered forms
- [ ] Add attendance pill and one‑tap toggle on Students list
- [ ] Add context menus and swipe actions to classroom and student rows
- [ ] Add haptics + checkmark burst/toast after key actions
- [ ] Accessibility pass (labels, contrast, Dynamic Type, hit areas)
- [ ] Copy review for all new screens and actions

Notes
- Keep session scope UI‑only; underlying Services already exist from Sessions 1–2 (Org/Memberships/Invites/Classrooms/Students). Minor routing changes will be needed but no data model changes.
- Visual inspiration: minimal, organic shapes; soft neutral backgrounds; friendly rounded buttons; calm micro‑motion.
