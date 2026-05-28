/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = function(knex) {
  return knex.schema
    // Users table
    .createTable('users', (table) => {
      table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      table.string('email', 255).unique().notNullable();
      table.string('password_hash', 255).notNullable();
      table.string('full_name', 255).notNullable();
      table.text('avatar_url');
      table.string('language', 10).defaultTo('es');
      table.string('theme', 20).defaultTo('dark');
      table.string('timezone', 50).defaultTo('UTC');
      table.boolean('onboarding_completed').defaultTo(false);
      table.timestamp('created_at').defaultTo(knex.fn.now());
      table.timestamp('updated_at').defaultTo(knex.fn.now());
    })
    
    // Refresh tokens table
    .createTable('refresh_tokens', (table) => {
      table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      table.uuid('user_id').references('id').inTable('users').onDelete('CASCADE');
      table.text('token').unique().notNullable();
      table.timestamp('expires_at').notNullable();
      table.timestamp('created_at').defaultTo(knex.fn.now());
    })
    
    // Tasks table
    .createTable('tasks', (table) => {
      table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      table.uuid('user_id').references('id').inTable('users').onDelete('CASCADE');
      table.string('title', 500).notNullable();
      table.text('description');
      table.string('status', 20).defaultTo('pending');
      table.string('priority', 10).defaultTo('medium');
      table.timestamp('due_date');
      table.specificType('tags', 'TEXT[]');
      table.integer('position').defaultTo(0);
      table.timestamp('created_at').defaultTo(knex.fn.now());
      table.timestamp('updated_at').defaultTo(knex.fn.now());
      table.timestamp('completed_at');
    })
    
    // Habits table
    .createTable('habits', (table) => {
      table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      table.uuid('user_id').references('id').inTable('users').onDelete('CASCADE');
      table.string('title', 255).notNullable();
      table.text('description');
      table.string('icon', 100);
      table.string('color', 20);
      table.string('frequency', 20).defaultTo('daily');
      table.specificType('frequency_days', 'INTEGER[]');
      table.integer('target_count').defaultTo(1);
      table.time('reminder_time');
      table.boolean('is_active').defaultTo(true);
      table.integer('streak_current').defaultTo(0);
      table.integer('streak_best').defaultTo(0);
      table.timestamp('created_at').defaultTo(knex.fn.now());
      table.timestamp('updated_at').defaultTo(knex.fn.now());
    })
    
    // Habit logs table
    .createTable('habit_logs', (table) => {
      table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      table.uuid('habit_id').references('id').inTable('habits').onDelete('CASCADE');
      table.uuid('user_id').references('id').inTable('users').onDelete('CASCADE');
      table.date('logged_at').notNullable().defaultTo(knex.fn.now());
      table.integer('count').defaultTo(1);
      table.text('notes');
      table.timestamp('created_at').defaultTo(knex.fn.now());
      table.unique(['habit_id', 'logged_at']);
    })
    
    // Goals table
    .createTable('goals', (table) => {
      table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      table.uuid('user_id').references('id').inTable('users').onDelete('CASCADE');
      table.string('title', 500).notNullable();
      table.text('description');
      table.string('category', 50);
      table.decimal('target_value', 10, 2);
      table.decimal('current_value', 10, 2).defaultTo(0);
      table.string('unit', 50);
      table.string('status', 20).defaultTo('active');
      table.date('start_date').defaultTo(knex.fn.now());
      table.date('target_date');
      table.decimal('progress', 5, 2).defaultTo(0);
      table.jsonb('milestones').defaultTo('[]');
      table.timestamp('created_at').defaultTo(knex.fn.now());
      table.timestamp('updated_at').defaultTo(knex.fn.now());
    })
    
    // Expenses table
    .createTable('expenses', (table) => {
      table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      table.uuid('user_id').references('id').inTable('users').onDelete('CASCADE');
      table.decimal('amount', 12, 2).notNullable();
      table.string('currency', 3).defaultTo('USD');
      table.string('category', 50).notNullable();
      table.string('description', 500);
      table.date('date').defaultTo(knex.fn.now());
      table.string('type', 10).defaultTo('expense');
      table.boolean('is_recurring').defaultTo(false);
      table.string('recurrence', 20);
      table.specificType('tags', 'TEXT[]');
      table.timestamp('created_at').defaultTo(knex.fn.now());
      table.timestamp('updated_at').defaultTo(knex.fn.now());
    })
    
    // Budgets table
    .createTable('budgets', (table) => {
      table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      table.uuid('user_id').references('id').inTable('users').onDelete('CASCADE');
      table.string('category', 50).notNullable();
      table.decimal('amount', 12, 2).notNullable();
      table.string('period', 20).defaultTo('monthly');
      table.timestamp('created_at').defaultTo(knex.fn.now());
      table.timestamp('updated_at').defaultTo(knex.fn.now());
      table.unique(['user_id', 'category', 'period']);
    })
    
    // AI Conversations table
    .createTable('ai_conversations', (table) => {
      table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      table.uuid('user_id').references('id').inTable('users').onDelete('CASCADE');
      table.string('title', 255);
      table.timestamp('created_at').defaultTo(knex.fn.now());
      table.timestamp('updated_at').defaultTo(knex.fn.now());
    })
    
    // AI Messages table
    .createTable('ai_messages', (table) => {
      table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      table.uuid('conversation_id').references('id').inTable('ai_conversations').onDelete('CASCADE');
      table.uuid('user_id').references('id').inTable('users').onDelete('CASCADE');
      table.string('role', 20).notNullable();
      table.text('content').notNullable();
      table.jsonb('metadata').defaultTo('{}');
      table.timestamp('created_at').defaultTo(knex.fn.now());
    })
    
    // User Settings table
    .createTable('user_settings', (table) => {
      table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      table.uuid('user_id').unique().references('id').inTable('users').onDelete('CASCADE');
      table.decimal('monthly_budget', 12, 2);
      table.boolean('notifications_enabled').defaultTo(true);
      table.boolean('ai_context_enabled').defaultTo(true);
      table.string('currency', 3).defaultTo('USD');
      table.string('week_start', 10).defaultTo('monday');
      table.timestamp('created_at').defaultTo(knex.fn.now());
      table.timestamp('updated_at').defaultTo(knex.fn.now());
    });
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = function(knex) {
  return knex.schema
    .dropTableIfExists('user_settings')
    .dropTableIfExists('ai_messages')
    .dropTableIfExists('ai_conversations')
    .dropTableIfExists('budgets')
    .dropTableIfExists('expenses')
    .dropTableIfExists('goals')
    .dropTableIfExists('habit_logs')
    .dropTableIfExists('habits')
    .dropTableIfExists('tasks')
    .dropTableIfExists('refresh_tokens')
    .dropTableIfExists('users');
};