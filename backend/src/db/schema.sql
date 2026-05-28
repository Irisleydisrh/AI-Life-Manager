-- =====================================================
-- AI Life Manager - PostgreSQL Schema
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- USERS TABLE
-- =====================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    language VARCHAR(10) DEFAULT 'es',
    theme VARCHAR(20) DEFAULT 'dark',
    timezone VARCHAR(50) DEFAULT 'UTC',
    onboarding_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);

-- =====================================================
-- REFRESH TOKENS TABLE
-- =====================================================
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token TEXT NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_token ON refresh_tokens(token);

-- =====================================================
-- TASKS TABLE
-- =====================================================
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    priority VARCHAR(10) DEFAULT 'medium',
    due_date TIMESTAMPTZ,
    tags TEXT[],
    position INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

CREATE INDEX idx_tasks_user_id ON tasks(user_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);

-- =====================================================
-- HABITS TABLE
-- =====================================================
CREATE TABLE habits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(100),
    color VARCHAR(20),
    frequency VARCHAR(20) DEFAULT 'daily',
    frequency_days INTEGER[],
    target_count INTEGER DEFAULT 1,
    reminder_time TIME,
    is_active BOOLEAN DEFAULT TRUE,
    streak_current INTEGER DEFAULT 0,
    streak_best INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_habits_user_id ON habits(user_id);
CREATE INDEX idx_habits_is_active ON habits(is_active);

-- =====================================================
-- HABIT LOGS TABLE
-- =====================================================
CREATE TABLE habit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    habit_id UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    logged_at DATE NOT NULL DEFAULT CURRENT_DATE,
    count INTEGER DEFAULT 1,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(habit_id, logged_at)
);

CREATE INDEX idx_habit_logs_habit_id ON habit_logs(habit_id);
CREATE INDEX idx_habit_logs_user_id ON habit_logs(user_id);
CREATE INDEX idx_habit_logs_logged_at ON habit_logs(logged_at);

-- =====================================================
-- GOALS TABLE
-- =====================================================
CREATE TABLE goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    target_value DECIMAL(10,2),
    current_value DECIMAL(10,2) DEFAULT 0,
    unit VARCHAR(50),
    status VARCHAR(20) DEFAULT 'active',
    start_date DATE DEFAULT CURRENT_DATE,
    target_date DATE,
    progress DECIMAL(5,2) DEFAULT 0,
    milestones JSONB DEFAULT '[]',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_goals_user_id ON goals(user_id);
CREATE INDEX idx_goals_status ON goals(status);
CREATE INDEX idx_goals_category ON goals(category);

-- =====================================================
-- EXPENSES TABLE
-- =====================================================
CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(12,2) NOT NULL,
    currency CHAR(3) DEFAULT 'USD',
    category VARCHAR(50) NOT NULL,
    description VARCHAR(500),
    date DATE DEFAULT CURRENT_DATE,
    type VARCHAR(10) DEFAULT 'expense',
    is_recurring BOOLEAN DEFAULT FALSE,
    recurrence VARCHAR(20),
    tags TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_expenses_user_id ON expenses(user_id);
CREATE INDEX idx_expenses_date ON expenses(date);
CREATE INDEX idx_expenses_category ON expenses(category);
CREATE INDEX idx_expenses_type ON expenses(type);

-- =====================================================
-- BUDGETS TABLE
-- =====================================================
CREATE TABLE budgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category VARCHAR(50) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    period VARCHAR(20) DEFAULT 'monthly',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, category, period)
);

CREATE INDEX idx_budgets_user_id ON budgets(user_id);

-- =====================================================
-- AI CONVERSATIONS TABLE
-- =====================================================
CREATE TABLE ai_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ai_conversations_user_id ON ai_conversations(user_id);

-- =====================================================
-- AI MESSAGES TABLE
-- =====================================================
CREATE TABLE ai_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES ai_conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL,
    content TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ai_messages_conversation_id ON ai_messages(conversation_id);
CREATE INDEX idx_ai_messages_user_id ON ai_messages(user_id);

-- =====================================================
-- USER SETTINGS TABLE
-- =====================================================
CREATE TABLE user_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    monthly_budget DECIMAL(12,2),
    notifications_enabled BOOLEAN DEFAULT TRUE,
    ai_context_enabled BOOLEAN DEFAULT TRUE,
    currency CHAR(3) DEFAULT 'USD',
    week_start VARCHAR(10) DEFAULT 'monday',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_user_settings_user_id ON user_settings(user_id);

-- =====================================================
-- SEED DATA (Optional - for testing)
-- =====================================================

-- Insert test user (password: test123)
-- INSERT INTO users (email, password_hash, full_name) 
-- VALUES ('test@example.com', crypt('test123', gen_salt('bf')), 'Test User');

-- =====================================================
-- VIEWS (Optional - for analytics)
-- =====================================================

-- View: Daily habit completion summary
CREATE OR REPLACE VIEW daily_habit_summary AS
SELECT 
    u.id as user_id,
    hl.logged_at as date,
    COUNT(h.id) as total_habits,
    COUNT(hl.id) as completed_habits,
    ROUND(COUNT(hl.id)::numeric / COUNT(h.id)::numeric * 100, 1) as completion_rate
FROM users u
CROSS JOIN LATERAL (
    SELECT id FROM habits 
    WHERE user_id = u.id AND is_active = true
) h
LEFT JOIN habit_logs hl ON hl.habit_id = h.id AND hl.logged_at = CURRENT_DATE
GROUP BY u.id, hl.logged_at;

-- View: Monthly expense summary
CREATE OR REPLACE VIEW monthly_expense_summary AS
SELECT 
    user_id,
    DATE_TRUNC('month', date) as month,
    type,
    category,
    SUM(amount) as total,
    COUNT(*) as count
FROM expenses
GROUP BY user_id, DATE_TRUNC('month', date), type, category;

-- View: Goals progress overview
CREATE OR REPLACE VIEW goals_progress_overview AS
SELECT 
    g.id,
    g.user_id,
    g.title,
    g.category,
    g.status,
    g.progress,
    g.target_value,
    g.current_value,
    g.target_date,
    CASE 
        WHEN g.target_date IS NULL THEN NULL
        WHEN g.target_date < CURRENT_DATE AND g.status = 'active' THEN 'overdue'
        WHEN g.progress >= 100 THEN 'completed'
        WHEN g.progress >= 75 THEN 'on_track'
        WHEN g.progress >= 50 THEN 'in_progress'
        ELSE 'at_risk'
    END as health_status
FROM goals g;

-- =====================================================
-- FUNCTIONS (Optional - for automation)
-- =====================================================

-- Function: Update goal progress automatically
CREATE OR REPLACE FUNCTION update_goal_progress()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.target_value > 0 THEN
        NEW.progress = LEAST(ROUND((NEW.current_value / NEW.target_value) * 100, 2), 100);
    END IF;
    
    IF NEW.progress >= 100 AND NEW.status = 'active' THEN
        NEW.status = 'completed';
    END IF;
    
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Auto-update goal progress
CREATE TRIGGER trigger_update_goal_progress
    BEFORE UPDATE ON goals
    FOR EACH ROW
    EXECUTE FUNCTION update_goal_progress();

-- Function: Calculate streak
CREATE OR REPLACE FUNCTION calculate_streak(p_habit_id UUID)
RETURNS INTEGER AS $$
DECLARE
    v_streak INTEGER := 0;
    v_date DATE := CURRENT_DATE;
BEGIN
    LOOP
        IF EXISTS (
            SELECT 1 FROM habit_logs 
            WHERE habit_id = p_habit_id AND logged_at = v_date
        ) THEN
            v_streak := v_streak + 1;
            v_date := v_date - 1;
        ELSE
            EXIT;
        END IF;
    END LOOP;
    
    RETURN v_streak;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMMENTS
-- =====================================================

COMMENT ON TABLE users IS 'Users table with authentication info';
COMMENT ON TABLE tasks IS 'User tasks with priority and status';
COMMENT ON TABLE habits IS 'Recurring habits with streak tracking';
COMMENT ON TABLE habit_logs IS 'Daily habit completion logs';
COMMENT ON TABLE goals IS 'Long-term goals with milestones';
COMMENT ON TABLE expenses IS 'Income and expense transactions';
COMMENT ON TABLE budgets IS 'Monthly budget limits by category';
COMMENT ON TABLE ai_conversations IS 'AI chat conversations';
COMMENT ON TABLE ai_messages IS 'Messages in AI conversations';
COMMENT ON TABLE user_settings IS 'User preferences and settings';