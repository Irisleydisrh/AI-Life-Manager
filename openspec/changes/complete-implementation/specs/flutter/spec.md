# Flutter App Specification

## Purpose
Complete Flutter mobile app with BLoC pattern for AI Life Manager.

## Requirements

### Requirement: Authentication Flow
The app MUST provide registration, login, and token management.

#### Scenario: New User Registration
- GIVEN user enters email, password, full_name
- WHEN taps "Registrarse" button
- THEN shows loading, calls API, stores tokens, navigates to onboarding

#### Scenario: User Login
- GIVEN user enters email and password
- WHEN taps "Iniciar Sesion" button
- THEN validates input, calls API, stores access/refresh tokens, navigates to home

#### Scenario: Token Refresh
- GIVEN access token expired
- WHEN making API call
- THEN automatically refreshes using refresh token, retries original request

#### Scenario: Logout
- GIVEN authenticated user taps logout
- THEN clears tokens, navigates to login

### Requirement: Onboarding Flow
The app MUST guide new users through initial setup.

#### Scenario: Complete Onboarding
- GIVEN new user sees 3-4 onboarding screens
- WHEN swipes through and taps "Comenzar"
- THEN onboarding_completed set to true, navigates to home

### Requirement: Home Dashboard
The app MUST display overview of all modules.

#### Scenario: View Dashboard
- GIVEN authenticated user on home tab
- THEN shows greeting header, quick stats (tasks pending, active habits, goals progress, balance)
- AND shows recent tasks preview, quick action buttons

### Requirement: Tasks Module
The app MUST provide full task management.

#### Scenario: View Task List
- GIVEN user on tasks tab
- THEN shows grouped tasks (today, upcoming, completed)
- AND filter chips (all, pending, completed)
- AND FAB to add new task

#### Scenario: Create Task
- GIVEN user taps FAB
- WHEN enters title, optional description, priority (low/medium/high), due date
- THEN task created, appears in list

#### Scenario: Complete Task
- GIVEN user taps checkbox on task
- THEN task marked completed, moves to completed section
- AND shows completion animation

#### Scenario: Edit Task
- GIVEN user taps task to open details
- WHEN modifies fields and saves
- THEN task updated

#### Scenario: Delete Task
- GIVEN user swipes task left
- WHEN confirms delete
- THEN task removed

#### Scenario: Reorder Tasks
- GIVEN user long-presses and drags task
- WHEN task dropped in new position
- THEN order saved

### Requirement: Habits Module
The app MUST provide habit tracking with streaks.

#### Scenario: View Habits
- GIVEN user on habits tab
- THEN shows habit cards with streak counter, progress ring
- AND today section with habits to complete

#### Scenario: Create Habit
- GIVEN user taps FAB
- WHEN enters title, icon picker, frequency (daily/weekly), reminder time
- THEN habit created

#### Scenario: Log Habit
- GIVEN user taps checkmark on habit card
- THEN shows streak animation, increments counter
- AND logs entry for today

#### Scenario: View Streak Details
- GIVEN user taps on habit card
- WHEN views habit detail
- THEN shows calendar view with completed days, streak history

### Requirement: Goals Module
The app MUST provide goal tracking with milestones.

#### Scenario: View Goals
- GIVEN user on goals tab
- THEN shows goal cards with progress bar
- AND category filter tabs (all, health, career, finance, personal)

#### Scenario: Create Goal
- GIVEN user taps FAB
- WHEN enters title, description, target value, target date, milestones
- THEN goal created with initial progress 0%

#### Scenario: Update Progress
- GIVEN user taps progress indicator on goal
- WHEN enters new current value
- THEN progress percentage recalculates, milestones update status

#### Scenario: Complete Goal
- GIVEN goal reaches 100%
- THEN shows completion celebration animation

### Requirement: Finance Module
The app MUST provide expense tracking and budgets.

#### Scenario: View Finance Overview
- GIVEN user on finance tab
- THEN shows balance summary, monthly spending chart
- AND recent transactions list

#### Scenario: Add Expense
- GIVEN user taps FAB
- WHEN enters amount, category (dropdown), description, date
- THEN expense added, balance updated

#### Scenario: Add Income
- GIVEN user taps "+" then "Ingreso"
- WHEN enters amount, category, description
- THEN income added, balance updated

#### Scenario: View Budgets
- GIVEN user taps budgets section
- THEN shows budget cards per category with spent/total progress

#### Scenario: Create Budget
- GIVEN user taps "Agregar Presupuesto"
- WHEN enters category, amount, period (monthly/weekly)
- THEN budget created

#### Scenario: View Spending by Category
- GIVEN user taps category in chart
- THEN shows filtered transactions for that category

### Requirement: AI Chat Module
The app MUST provide conversational AI assistance.

#### Scenario: Start New Conversation
- GIVEN user on AI tab
- THEN shows empty chat or previous conversations list

#### Scenario: Send Message
- GIVEN user types message and sends
- THEN shows typing indicator, returns AI response
- AND message added to conversation history

#### Scenario: View Conversation History
- GIVEN user taps existing conversation
- THEN shows full message history

#### Scenario: AI Context
- GIVEN user asks about their tasks/habits/goals
- THEN AI responds with relevant personalized data

### Requirement: Profile Module
The app MUST provide user settings and preferences.

#### Scenario: View Profile
- GIVEN user on profile tab
- THEN shows avatar, name, email
- AND settings sections (account, preferences, data)

#### Scenario: Edit Profile
- GIVEN user taps edit icon
- WHEN modifies name, avatar
- THEN profile updated

#### Scenario: Change Language
- GIVEN user in preferences
- WHEN selects language (es/en)
- THEN app updates immediately

#### Scenario: Change Theme
- GIVEN user in preferences
- WHEN toggles theme (dark/light)
- THEN app applies new theme

#### Scenario: Configure Notifications
- GIVEN user in preferences
- WHEN toggles notification settings
- THEN settings saved

#### Scenario: Manage Data
- GIVEN user in data section
- WHEN taps "Exportar Datos" or "Borrar Todo"
- THEN exports JSON or clears all user data

## Navigation Structure

| Route | Screen | Parent |
|-------|--------|--------|
| /splash | SplashPage | - |
| /onboarding | OnboardingPage | - |
| /auth/login | LoginPage | - |
| /auth/register | RegisterPage | - |
| /home | HomePage | MainShell |
| /tasks | TasksPage | MainShell |
| /habits | HabitsPage | MainShell |
| /goals | GoalsPage | MainShell |
| /finance | FinancePage | MainShell |
| /ai-chat | AIChatPage | MainShell |
| /profile | ProfilePage | MainShell |

## State Management

| Feature | BLoC | States |
|---------|------|--------|
| Auth | AuthBloc | initial, loading, authenticated, unauthenticated, error |
| Tasks | TasksBloc | initial, loading, loaded, error |
| Habits | HabitsBloc | initial, loading, loaded, error |
| Goals | GoalsBloc | initial, loading, loaded, error |
| Finance | FinanceBloc | initial, loading, loaded, error |
| AI Chat | AIChatBloc | initial, loading, loaded, error |
| Profile | ProfileBloc | initial, loading, loaded, error |

## Component Library

### Shared Components
- GradientCard: Card with gradient border/background
- AnimatedProgressBar: Progress bar with animation
- StatusBadge: Pill-shaped status indicator
- EmptyState: Placeholder for empty lists
- LoadingIndicator: Custom loading spinner
- ConfirmDialog: Reusable confirmation modal
- FilterChip: Selectable filter tags
- IconPicker: Grid of selectable icons
- DateTimePicker: Custom date/time picker
- AmountInput: Currency-formatted input