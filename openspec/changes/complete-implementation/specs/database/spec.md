# Database Specification

## Purpose
PostgreSQL database schema with 11 tables for AI Life Manager.

## Requirements

### Requirement: Users Table
The system MUST store user data with required fields.

#### Scenario: Create User
- GIVEN email, password_hash, full_name
- WHEN user registers
- THEN user record created with default values (language: es, theme: dark, onboarding_completed: false)

#### Scenario: Update User Profile
- GIVEN user_id with new full_name, avatar_url
- WHEN profile updated
- THEN user record updated with updated_at timestamp

### Requirement: Tasks Table
The system MUST store tasks linked to users.

#### Scenario: Create Task
- GIVEN user_id, title, description, priority, due_date, tags
- WHEN task created
- THEN task record created with status: pending, position: 0

#### Scenario: Complete Task
- GIVEN task_id with status changed to completed
- WHEN task completed
- THEN completed_at timestamp set to now

### Requirement: Habits Table
The system MUST store habits with streak tracking.

#### Scenario: Create Habit
- GIVEN user_id, title, frequency (daily/weekly), reminder_time
- WHEN habit created
- THEN habit created with streak_current: 0, streak_best: 0, is_active: true

#### Scenario: Update Streak
- GIVEN habit with consecutive days logged
- WHEN new log created
- THEN streak_current incremented, streak_best updated if exceeded

### Requirement: Goals Table
The system MUST store goals with milestone tracking.

#### Scenario: Create Goal
- GIVEN user_id, title, target_value, target_date, milestones[]
- WHEN goal created
- THEN goal created with current_value: 0, progress: 0, status: active

#### Scenario: Progress Update
- GIVEN goal_id with new current_value
- WHEN progress updated
- THEN progress calculated as (current_value / target_value) * 100

### Requirement: Expenses Table
The system MUST store financial transactions.

#### Scenario: Add Expense
- GIVEN user_id, amount, category, description, date
- WHEN expense created
- THEN expense record created with type: expense, is_recurring: false

#### Scenario: Add Income
- GIVEN user_id, amount, category, description, date, type: income
- WHEN income created
- THEN expense record created with type: income

### Requirement: Budgets Table
The system MUST store budget limits per category.

#### Scenario: Create Budget
- GIVEN user_id, category, amount, period (monthly/weekly)
- WHEN budget created
- THEN unique constraint on user_id + category + period enforced

### Requirement: AI Conversations
The system MUST store chat history with context.

#### Scenario: Create Conversation
- GIVEN user_id
- WHEN new chat started
- THEN conversation created with timestamp

#### Scenario: Add Message
- GIVEN conversation_id, user_id, role (user/assistant), content
- WHEN message sent
- THEN message stored with metadata {}

### Requirement: Data Integrity
The system MUST enforce referential integrity.

#### Scenario: Delete User
- GIVEN user deleted
- WHEN CASCADE delete triggered
- THEN all related records (tasks, habits, goals, expenses, conversations) deleted

#### Scenario: Delete Habit
- GIVEN habit deleted
- WHEN CASCADE delete triggered
- THEN all habit_logs for that habit deleted

## Table Schema Summary

| Table | Primary Key | Foreign Keys | Unique Constraints |
|-------|-------------|--------------|-------------------|
| users | id | - | email |
| refresh_tokens | id | user_id | token |
| tasks | id | user_id | - |
| habits | id | user_id | - |
| habit_logs | id | habit_id, user_id | (habit_id, logged_at) |
| goals | id | user_id | - |
| expenses | id | user_id | - |
| budgets | id | user_id | (user_id, category, period) |
| ai_conversations | id | user_id | - |
| ai_messages | id | conversation_id, user_id | - |
| user_settings | id | user_id | user_id |

## Indexes

| Table | Index | Columns | Purpose |
|-------|-------|---------|---------|
| tasks | idx_tasks_user_id | user_id | Query tasks by user |
| tasks | idx_tasks_status | status | Filter by status |
| tasks | idx_tasks_due_date | due_date | Sort by due date |
| habits | idx_habits_user_id | user_id | Query habits by user |
| habit_logs | idx_habit_logs_date | logged_at | Query logs by date |
| goals | idx_goals_user_id | user_id | Query goals by user |
| expenses | idx_expenses_user_id | user_id | Query expenses by user |
| expenses | idx_expenses_date | date | Filter by date range |
| expenses | idx_expenses_category | category | Filter by category |
| ai_messages | idx_ai_messages_conversation | conversation_id | Get conversation messages |