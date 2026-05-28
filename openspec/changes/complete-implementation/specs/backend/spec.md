# Backend API Specification

## Purpose

Complete Express.js backend with 7 API modules for AI Life Manager mobile app.

## Requirements

### Requirement: Authentication Module (Auth)

The API MUST provide full authentication with JWT and refresh tokens.

#### Scenario: User Registration

- GIVEN valid email and password (min 8 chars)
- WHEN POST /api/v1/auth/register is called
- THEN returns 201 with user object and access/refresh tokens
- AND user record created in database

#### Scenario: User Login

- GIVEN correct email and password
- WHEN POST /api/v1/auth/login is called
- THEN returns 200 with access token (15min) and refresh token (7 days)

#### Scenario: Token Refresh

- GIVEN valid refresh token
- WHEN POST /api/v1/auth/refresh is called
- THEN returns new access and refresh tokens
- AND old refresh token is invalidated

#### Scenario: Logout

- GIVEN authenticated user
- WHEN POST /api/v1/auth/logout is called
- THEN refresh token is deleted from database

#### Scenario: Invalid Credentials

- GIVEN wrong password
- WHEN POST /api/v1/auth/login is called
- THEN returns 401 with error message

### Requirement: Tasks Module

The API MUST provide CRUD operations for user tasks.

#### Scenario: Create Task

- GIVEN authenticated user with title, optional description, priority, due_date
- WHEN POST /api/v1/tasks is called
- THEN returns 201 with created task

#### Scenario: List Tasks

- GIVEN authenticated user
- WHEN GET /api/v1/tasks is called with optional filters (status, priority, due_date)
- THEN returns 200 with paginated task list (20 per page default)

#### Scenario: Update Task

- GIVEN authenticated user owning the task
- WHEN PUT /api/v1/tasks/:id is called
- THEN returns 200 with updated task

#### Scenario: Delete Task

- GIVEN authenticated user owning the task
- WHEN DELETE /api/v1/tasks/:id is called
- THEN returns 204 and task is deleted

#### Scenario: Reorder Tasks

- GIVEN authenticated user with list of task IDs in new order
- WHEN PUT /api/v1/tasks/reorder is called
- THEN tasks positions are updated

### Requirement: Habits Module

The API MUST provide habit tracking with streaks.

#### Scenario: Create Habit

- GIVEN authenticated user with title, frequency (daily/weekly), optional reminder_time
- WHEN POST /api/v1/habits is called
- THEN returns 201 with created habit

#### Scenario: Log Habit Completion

- GIVEN authenticated user with habit_id
- WHEN POST /api/v1/habits/:id/log is called
- THEN returns 200 with updated streak
- AND habit_log entry created

#### Scenario: Get Habits with Streaks

- GIVEN authenticated user
- WHEN GET /api/v1/habits is called
- THEN returns list with current_streak and best_streak calculated

### Requirement: Goals Module

The API MUST provide goal tracking with milestones.

#### Scenario: Create Goal

- GIVEN authenticated user with title, target_value, target_date, milestones[]
- WHEN POST /api/v1/goals is called
- THEN returns 201 with goal including calculated progress percentage

#### Scenario: Update Goal Progress

- GIVEN authenticated user with goal_id and new current_value
- WHEN PUT /api/v1/goals/:id/progress is called
- THEN progress percentage is recalculated
- AND milestones status updated

#### Scenario: Complete Goal

- GIVEN authenticated user with completed goal
- WHEN PUT /api/v1/goals/:id/status with status=completed
- THEN returns goal with completed status and final progress

### Requirement: Finance Module

The API MUST provide expense tracking and budgets.

#### Scenario: Add Expense

- GIVEN authenticated user with amount, category, description, date
- WHEN POST /api/v1/expenses is called
- THEN returns 201 with created expense

#### Scenario: Get Expenses with Filters

- GIVEN authenticated user
- WHEN GET /api/v1/expenses?start_date=2024-01&end_date=2024-12&category=food
- THEN returns filtered expenses with total sum

#### Scenario: Create Budget

- GIVEN authenticated user with category, amount, period (monthly/weekly)
- WHEN POST /api/v1/budgets is called
- THEN returns 201 with budget

#### Scenario: Get Budget vs Actual

- GIVEN authenticated user with monthly period
- WHEN GET /api/v1/budgets/summary?period=2024-01
- THEN returns budget amounts vs actual spent per category

### Requirement: AI Chat Module

The API MUST provide OpenAI integration with user context.

#### Scenario: Send Message

- GIVEN authenticated user with conversation_id and message
- WHEN POST /api/v1/ai/chat is called
- THEN returns AI response with context from user's tasks/habits/goals

#### Scenario: Create New Conversation

- GIVEN authenticated user
- WHEN POST /api/v1/ai/conversations is called
- THEN returns new conversation with empty message history

#### Scenario: Get Conversation History

- GIVEN authenticated user with conversation_id
- WHEN GET /api/v1/ai/conversations/:id is called
- THEN returns conversation with all messages

### Requirement: Profile Module

The API MUST provide user settings and profile management.

#### Scenario: Get Profile

- GIVEN authenticated user
- WHEN GET /api/v1/profile is called
- THEN returns user object with settings

#### Scenario: Update Profile

- GIVEN authenticated user with full_name, avatar_url
- WHEN PUT /api/v1/profile is called
- THEN returns updated user object

#### Scenario: Update Settings

- GIVEN authenticated user with settings (language, theme, notifications, currency)
- WHEN PUT /api/v1/profile/settings is called
- THEN returns updated settings

### Requirement: API Security

All protected routes MUST enforce JWT authentication.

#### Scenario: Access Protected Route Without Token

- GIVEN no access token in Authorization header
- WHEN calling any protected endpoint
- THEN returns 401 with "Unauthorized"

#### Scenario: Access Protected Route With Invalid Token

- GIVEN expired or malformed access token
- WHEN calling protected endpoint
- THEN returns 401 with "Token expired" or "Invalid token"

## Endpoints Summary

| Module | Method | Endpoint | Auth |
|--------|--------|----------|------|
| Auth | POST | /api/v1/auth/register | No |
| Auth | POST | /api/v1/auth/login | No |
| Auth | POST | /api/v1/auth/refresh | No |
| Auth | POST | /api/v1/auth/logout | Yes |
| Tasks | GET/POST | /api/v1/tasks | Yes |
| Tasks | PUT/DELETE | /api/v1/tasks/:id | Yes |
| Habits | GET/POST | /api/v1/habits | Yes |
| Habits | POST | /api/v1/habits/:id/log | Yes |
| Goals | GET/POST | /api/v1/goals | Yes |
| Goals | PUT | /api/v1/goals/:id/progress | Yes |
| Finance | GET/POST | /api/v1/expenses | Yes |
| Finance | GET/POST | /api/v1/budgets | Yes |
| AI | POST | /api/v1/ai/chat | Yes |
| AI | GET/POST | /api/v1/ai/conversations | Yes |
| Profile | GET/PUT | /api/v1/profile | Yes |
| Profile | PUT | /api/v1/profile/settings | Yes |