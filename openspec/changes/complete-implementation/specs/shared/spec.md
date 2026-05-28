# Design System Specification

## Purpose
Shared theme, design system, and components for Flutter mobile app.

## Requirements

### Requirement: Color Palette
The app MUST use consistent color definitions.

#### Scenario: Dark Theme Colors
- GIVEN app in dark mode
- THEN uses darkBackground (#0A0A0F), darkSurface (#141420), darkBorder (#2D2D44)

#### Scenario: Light Theme Colors
- GIVEN app in light mode
- THEN uses lightBackground (#F8F8FF), lightSurface (#FFFFFF), lightBorder (#E0E0E0)

#### Scenario: Accent Colors
- GIVEN accent colors needed
- THEN uses accentPrimary (#6C63FF), accentSecondary (#00D4FF), accentTertiary (#FF6B9D)
- AND accentGreen (#00E676) for success, accentOrange (#FF9800) for warning
- AND accentRed (#FF5252) for error

### Requirement: Typography
The app MUST use consistent text styles.

#### Scenario: Display Text
- GIVEN displayLarge needed
- THEN uses 32px, weight 800, letter-spacing -1.0

#### Scenario: Headlines
- GIVEN headlineMedium needed
- THEN uses 24px, weight 700, letter-spacing -0.5

#### Scenario: Body Text
- GIVEN bodyMedium needed
- THEN uses 14px, weight 400, height 1.5

#### Scenario: Labels
- GIVEN labelSmall needed
- THEN uses 11px, weight 500, letter-spacing 0.5

### Requirement: Gradients
The app MUST provide predefined gradient styles.

#### Scenario: Primary Gradient
- GIVEN primary gradient needed
- THEN uses LinearGradient from accentPrimary to accentSecondary

#### Scenario: AI Gradient
- GIVEN AI-themed gradient needed
- THEN uses LinearGradient from accentPrimary to accentTertiary

#### Scenario: Success Gradient
- GIVEN success gradient needed
- THEN uses LinearGradient from accentGreen to accentSecondary

### Requirement: Component Theme
The app MUST apply consistent Material Design theming.

#### Scenario: Card Theme
- GIVEN cards rendered
- THEN uses darkSurface color, radius 16px, border color darkBorder

#### Scenario: Input Theme
- GIVEN text inputs rendered
- THEN uses filled style with darkSurfaceAlt background
- AND focused border uses accentPrimary with 2px width

#### Scenario: Button Theme
- GIVEN buttons rendered
- THEN uses accentPrimary background, radius 12px, weight 600

#### Scenario: Bottom Navigation
- GIVEN bottom nav rendered
- THEN uses darkSurface background, selected accentPrimary, unselected textMuted

### Requirement: Spacing System
The app MUST use consistent spacing values.

#### Scenario: Standard Spacing
- GIVEN spacing needed
- THEN uses 4px, 8px, 12px, 16px, 24px, 32px, 48px increments

#### Scenario: Screen Padding
- GIVEN screen content needs padding
- THEN uses horizontal 16px, vertical 24px

#### Scenario: Card Padding
- GIVEN card content needs padding
- THEN uses 16px all sides

### Requirement: Border Radius
The app MUST use consistent border radius values.

#### Scenario: Small Elements
- GIVEN chips, badges
- THEN uses 8px radius

#### Scenario: Cards
- GIVEN cards, containers
- THEN uses 16px radius

#### Scenario: Buttons
- GIVEN buttons, inputs
- THEN uses 12px radius

#### Scenario: Large Containers
- GIVEN modals, sheets
- THEN uses 24px radius

### Requirement: Icons
The app MUST use consistent icon set.

#### Scenario: Navigation Icons
- GIVEN bottom navigation
- THEN uses Material Icons (home, task_alt, check_circle, flag, account_balance_wallet, chat_bubble, person)

#### Scenario: Action Icons
- GIVEN FAB, actions
- THEN uses Icons.add, Icons.edit, Icons.delete, Icons.check

#### Scenario: Status Icons
- GIVEN status indicators
- THEN uses Icons.circle (colored), Icons.check_circle, Icons.error

### Requirement: Animations
The app MUST provide consistent animations.

#### Scenario: Page Transitions
- GIVEN navigation between screens
- THEN uses fade transitions, 300ms duration

#### Scenario: Progress Animations
- GIVEN progress bar updates
- THEN animates with 500ms ease-out curve

#### Scenario: Micro-interactions
- GIVEN button taps, toggles
- THEN uses 200ms duration with ease-in-out

## Design Tokens Summary

| Token | Dark | Light |
|-------|------|-------|
| background | #0A0A0F | #F8F8FF |
| surface | #141420 | #FFFFFF |
| surfaceAlt | #1E1E2E | #F0F0FF |
| border | #2D2D44 | #E0E0E0 |
| textPrimary | #FFFFFF | #000000 |
| textSecondary | #8E8EAD | #666666 |
| textMuted | #4A4A6A | #999999 |
| primary | #6C63FF | #6C63FF |
| secondary | #00D4FF | #00D4FF |
| success | #00E676 | #00E676 |
| warning | #FF9800 | #FF9800 |
| error | #FF5252 | #FF5252 |