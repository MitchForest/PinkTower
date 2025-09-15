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

#### Session 4 — Classroom, Students UI/UX Systemization (2025-09-15)

Goal: Establish a consistent, reusable UI system for the classroom list, students grid/sheet, add-student flow, and global top navigation. Unify dialogs/sheets/dropdowns/inputs to the design system for 100% consistency (light, minimal, rounded, native-first), improve scalability for small/large classrooms, and clarify primary actions.

Key decisions
- Top navigation: remove opaque background; use a lightweight layout with larger touch targets. Title centered shows current classroom name with a down arrow. Tap opens native menu: switch classrooms and "Add classroom".
- Leading icons: hamburger (future nav) then a large Search icon. Trailing: large Notifications and Avatar.
- Students presentation: adaptive grid that scales avatar+name size with classroom size. 2–3 rows with large tiles for small classes; compact tiles for large (e.g., 48 students). Dynamic Type-aware.
- Student interaction: tap opens a full-width native sheet (drawer) via `PTBottomSheet` with `.fraction(0.95)` and `.large` detents. This is quick-access; not a modal dialog.
- Student sheet header: avatar, name, classroom, age; link to full profile screen.
- Student sheet quick capture: prominent input with mic button and quick toggles for Observation/Lesson/Task.
- Section stacks in sheet: Observations (last 3–5, newest first) with “See all”; Lessons; Tasks; Habits (large one-tap buttons to complete). Each has a link to the dedicated list in the full student page.
- Consistency: All sheets, dropdowns, inputs, buttons, toasts use PT design system tokens/components. No ad-hoc styles.

Design system updates
- PTTopBarCapsule v2 → `PTNavBar`:
  - No background fill by default (transparent) but supports an optional capsule style on scroll.
  - Center title with caret; leading: hamburger, search; trailing: notifications, avatar. All icons 24–28pt tappable areas ≥44×44.
  - Title tap shows native `Menu` with: classroom list (radio), "Add classroom".
- PTBottomSheet: add `.fraction(0.95)` default; consistent grabber; keyboard-safe padding; optional header slot.
- PTAvatar: responsive typography inside; sizes: xs=28, s=40, m=56, l=72, xl=96.
- New: `PTGridTile` for student tiles (avatar + name) with size presets: `.large`, `.medium`, `.compact`.
- New: `PTMenu` wrappers for native menus with DS styling hooks (icons, roles, separators).
- Inputs/buttons: ensure `PTTextFieldStyle` and `PTButtonStyle` variants: primary, secondary, quiet. Use throughout.

Screens and flows
- Classroom switcher
  - From the top center title: native `Menu` with list of classrooms and an "Add classroom" action.
  - When only one classroom exists, still show name and caret; menu shows disabled “Only one classroom” + Add classroom.
- ClassroomsView
  - Keep list rows using `PTListCell`. Primary action: `PTFloatingActionButton` “+ Classroom”.
  - Add top nav per `PTNavBar`. Selecting a classroom routes to Students tab.
- Students (HomeroomView)
  - Adaptive grid using `PTGridTile` with responsive sizing:
    - 1–8 students: large tiles (avatar ~72–96, name title font)
    - 9–24 students: medium tiles (avatar ~56–72)
    - 25–60+ students: compact tiles (avatar ~40–56, two lines max)
  - Tap → full-width sheet with `StudentPageView(student)`.
  - Long-press context menu: Edit, Remove from class, Delete (role gated).
  - Primary action: `PTFloatingActionButton` “+ Student”. Add-student uses consistent sheet layout.
- Student Sheet (Quick workspace)
  - Header: avatar, name, classroom, age, link to full profile.
  - Quick Capture: segmented control Observation/Lesson/Task; multi-line input; mic circle; Save. One-tap after transcription.
  - Sections: Observations (3–5 newest with See All), Lessons (3–5), Tasks (3–5), Habits (large buttons to mark today complete). Each has a link to the dedicated list in the full student page.
  - Bottom safe inset; dismiss via swipe or grabber.
- Student Full Page
  - Remains `StudentPageView` standalone route with complete lists, filters, analytics, AI.

Component inventory to implement/update
- New: `PTNavBar` (replaces usage of `PTTopBarCapsule` where appropriate)
- Update: `PTBottomSheet` (detents, keyboard safe, header slot)
- New: `PTGridTile` (student tile)
- Update: `PTAvatar` sizing presets
- Update: `PTButtonStyle` variants (primary/secondary/quiet)
- Update: `PTTextFieldStyle` consistency for all inputs (including search)
- New: `PTMenu` helper for classroom switcher

Acceptance criteria
- Top bar shows classroom name centered with caret; tapping shows a native menu listing classrooms (with current checked) and an "Add classroom" item.
- Leading icons: hamburger and enlarged search; trailing icons: enlarged notifications and avatar. Tap targets ≥44×44.
- Students grid adapts tile sizes based on count thresholds; accommodates up to 60+ students without crowding.
- Tapping a student presents a full-width sheet at ~95% height with grabber; the sheet shows header, quick capture (with mic), then Observations/Lessons/Tasks/Habits sections, each with recent items and See All.
- All dialogs, sheets, dropdowns, inputs, and buttons use the design system tokens and components; visual style is light, minimal, and rounded.
- Add student uses a consistent sheet style (not alert-style modal).

Checklist
- [x] Create `PTNavBar` component with center title + classroom switcher menu and enlarged icons
- [x] Replace top bar usage on major screens (`MainTabView`) [note: `SettingsView`, `SearchView` keep native titles for now]
- [x] Enhance `PTBottomSheet` with `.fraction(0.95)`
- [x] Implement `PTGridTile` and integrate into `HomeroomView` with adaptive sizing
- [x] Add `PTAvatar` size presets and update usage across views
- [x] Standardize `PTButton` variants and apply across dialogs/sheets
- [x] Enforce `PTTextFieldStyle` across inputs (search/capture forms) where applicable
- [x] Implement classroom switcher menu (native `Menu`) from navbar title with "Add classroom"
- [x] Update add-student flow to use standardized sheet and inputs (kept as form sheet)
- [ ] QA for Dynamic Type, VoiceOver labels, and 44×44 tap targets

Notes
- Keep native-first where possible (Menu, sheets). Maintain separation: Views ↔ ViewModels ↔ Services.
- Use `PermissionService` for role-gated actions.
- Future: navbar scroll behavior (fade-in capsule), class cover image, attendance density controls, integrate `PTNavBar` into `SettingsView`/`SearchView` if we decide to unify all screens.

#### Session 5 — DS Defaults + UX Consistency Fixes (2025-09-15)

Goal: Enforce 100% design‑system defaults across the app (menus, sheets, forms, actions), fix navigation layering/spacing issues, align all create/edit flows with DS, and adopt a robust native drawer for student quick workspace. Zero “black” default UIs; everything uses our tokens and components.

User‑reported issues to address
- Students grid underlaps top bar: avatars appear beneath the navbar; magnifying glass overlaps tiles.
- Classroom switcher menu renders as black; “Add classroom” route goes to an all‑black screen.
- New student CTA presents an all‑black screen.
- Long‑press context menu (edit/delete) is black.
- Student tap should open a native iOS drawer; current behavior feels off.
- Student full profile shows a system back button under/overlapping the hamburger; back should be integrated into the top bar on the left.

Key decisions
- Navigation layering
  - Use a single global top bar (`PTNavBar`) for top‑level screens only. For detail screens (e.g., full student profile), swap to a `PTNavBar` variant with an integrated back button on the left (replaces hamburger) to avoid overlap with the system nav bar.
  - Introduce a simple “detail mode” flag in the shell to toggle the navbar variant and spacing.
- Safe‑area and spacing
  - Create `PTScreen` container to standardize background and safe‑area handling and to provide a consistent top content inset matching `PTNavBar` height. Adopt across screens to prevent underlap.
- Menus and context actions
  - Replace `.contextMenu` long‑press with a DS‑styled action surface: either `PTMenu` (native `Menu` with DS hooks) or a `PTActionSheet` implemented via `PTBottomSheet` for full control. Prefer the sheet for destructive/primary actions.
  - Replace the classroom switcher `Menu` with a DS‑styled `PTMenu` or a small `PTBottomSheet` that lists classrooms with a radio control and “Add classroom”.
- Sheets and forms
  - Standardize sheets with `PTBottomSheet` (default `.fraction(0.95)` + `.large`) and a header slot. Ensure consistent backgrounds via the content view (no black defaults).
  - Introduce a form styling helper: hide default form backgrounds (`.scrollContentBackground(.hidden)`) and set `.background(PTColors.surface)`; ensure all form inputs use `PTTextFieldStyle` and buttons use `PTButton` styles.
- Student drawer
  - Use the item‑based `PTBottomSheet` for `StudentPageView` (compact mode) with a proper header (avatar, name, class) and keyboard‑safe padding. Ensure instant content readiness and consistent detents.
- Tokens and motion
  - Add `PTIconSize` tokens (e.g., small=18, medium=24, large=28) and replace inline icon sizes.
  - Add `PTMotion` tokens (easing + durations + springs) and replace inline springs.
- Cleanup
  - Remove `MainTabView` and `PTTopBarCapsule` to avoid drift.

Deliverables
- New/updated DS primitives: `PTScreen`, `PTMenu`, `PTActionSheet` (via `PTBottomSheet`), `PTMotion`, `PTIconSize`.
- Navbar variant with integrated back; shell support for detail mode.
- Classroom switcher implemented as DS menu/sheet.
- All create/edit forms (Add Classroom, New Student) shown in DS sheet with DS fields and buttons (no black background).
- Homeroom grid spacing fixed so content never underlaps the navbar.

Acceptance criteria
- Students grid shows below the top bar with adequate spacing; no overlap of icons over tiles.
- Classroom title tap opens a DS‑styled classroom switcher (menu or sheet) matching our colors/typography; background is not black.
- “Add classroom” and “New student” open DS‑styled sheets with `PTTextFieldStyle` inputs and `PTButton` actions; no black screens.
- Long‑press on a student shows DS‑consistent actions (sheet or styled menu), not a black context menu.
- Tapping a student opens a native bottom drawer (sheet at ~95% height) with a header and sections; no blank first render or layout jumps.
- Navigating to the full student profile presents a top bar with an integrated back button on the left (no overlapping with hamburger/system back).
- All forms and sheets have consistent background and spacing using `PTScreen` and DS tokens.

Checklist
- [ ] Implement `PTScreen` container and adopt on top‑level and detail screens.
- [ ] Add `PTMenu` and/or `PTActionSheet` and replace `.contextMenu` usages.
- [ ] Update classroom switcher to use DS menu/sheet with radio selection + “Add classroom”.
- [ ] Standardize forms: apply `.scrollContentBackground(.hidden)` and DS background; ensure `PTTextFieldStyle` across all form inputs.
- [ ] Convert Add Classroom and New Student to DS sheets using `PTBottomSheet` and DS components.
- [ ] Fix Homeroom content inset so tiles never underlaps the navbar (via `PTScreen`).
- [ ] Create `PTNavBar` back variant and integrate with shell detail mode.
- [ ] Introduce `PTIconSize` and `PTMotion`; replace inline icon sizes and springs.
- [ ] Remove `MainTabView` and `PTTopBarCapsule` (migrate remaining references if any).
- [ ] QA: light/dark, Dynamic Type, VoiceOver, 44×44 tap targets, and sheet/menu accessibility.

Notes
- We’ll keep native patterns (Menu, sheets) where they meet our visual goals; otherwise we’ll route actions through DS‑styled sheets for consistent backgrounds and spacing.
- No backend changes; all UX/style only. Ensure changes do not regress routing or permissions.
