# Tasks: Implementación Completa AI Life Manager

## Fase 1: Infraestructura y Base de Datos

- [ ] 1.1 Crear `docker-compose.yml` con PostgreSQL, Redis, backend y Adminer
- [ ] 1.2 Crear `backend/Dockerfile` con multi-stage build para Node.js
- [ ] 1.3 Configurar `backend/knexfile.js` para PostgreSQL con variables de entorno
- [ ] 1.4 Crear migración `backend/src/db/migrations/20240101000000_initial_schema.js` con 11 tablas: users, refresh_tokens, tasks, habits, habit_logs, goals, expenses, budgets, ai_conversations, ai_messages, user_settings
- [ ] 1.5 Ejecutar migración y verificar esquema en base de datos

## Fase 2: Backend Core

- [ ] 2.1 Instalar dependencias de `backend/package.json` (express, knex, pg, redis, jsonwebtoken, bcryptjs, openai, winston, etc.)
- [ ] 2.2 Configurar `backend/src/config/database.js` con conexión Knex
- [ ] 2.3 Configurar `backend/src/config/redis.js` con cliente Redis
- [ ] 2.4 Crear `backend/src/utils/logger.js` con Winston
- [ ] 2.5 Crear `backend/src/middleware/auth.middleware.js` con validación JWT
- [ ] 2.6 Crear `backend/src/app.js` con Express, CORS, Helmet, Morgan y rate limiting
- [ ] 2.7 Crear `backend/src/index.js` como punto de entrada con servidor HTTP

## Fase 3: Backend API Routes

- [ ] 3.1 Implementar `backend/src/api/v1/routes/auth.routes.js` con register, login, refresh, logout
- [ ] 3.2 Implementar `backend/src/api/v1/routes/tasks.routes.js` con CRUD completo y reorder
- [ ] 3.3 Implementar `backend/src/api/v1/routes/habits.routes.js` con CRUD y logging de rachas
- [ ] 3.4 Implementar `backend/src/api/v1/routes/goals.routes.js` con CRUD, hitos y progreso
- [ ] 3.5 Implementar `backend/src/api/v1/routes/finance.routes.js` con expenses y budgets
- [ ] 3.6 Implementar `backend/src/api/v1/routes/ai.routes.js` con chat y conversaciones
- [ ] 3.7 Implementar `backend/src/api/v1/routes/profile.routes.js` con perfil y settings
- [ ] 3.8 Crear `backend/src/api/v1/services/ai.service.js` con integración OpenAI y contexto de usuario

## Fase 4: Flutter - Configuración Base

- [ ] 4.1 Crear `mobile/pubspec.yaml` con flutter_bloc, dio, go_router, shared_preferences, fl_chart, intl
- [ ] 4.2 Crear `mobile/lib/main.dart` con WidgetsFlutterBinding y app initialization
- [ ] 4.3 Crear `mobile/lib/app.dart` con GoRouter, theme y BLoC providers
- [ ] 4.4 Implementar `mobile/lib/core/theme/app_theme.dart` con dark/light themes según spec
- [ ] 4.5 Crear `mobile/lib/core/constants/app_colors.dart` y `mobile/lib/core/constants/app_spacing.dart`

## Fase 5: Flutter - Servicios y Estado

- [ ] 5.1 Implementar `mobile/lib/data/api/api_client.dart` con Dio, interceptors y token refresh
- [ ] 5.2 Crear `mobile/lib/data/repositories/auth_repository.dart` con login, register, logout
- [ ] 5.3 Crear `mobile/lib/data/repositories/tasks_repository.dart`, `habits_repository.dart`, `goals_repository.dart`, `finance_repository.dart`, `ai_repository.dart`, `profile_repository.dart`
- [ ] 5.4 Implementar `mobile/lib/bloc/auth/auth_bloc.dart` con eventos Login, Register, Logout, TokenRefresh
- [ ] 5.5 Crear BLoCs para tasks, habits, goals, finance, ai_chat, profile

## Fase 6: Flutter - UI Pages

- [ ] 6.1 Crear `mobile/lib/pages/splash/splash_page.dart` con initialization logic
- [ ] 6.2 Crear `mobile/lib/pages/auth/login_page.dart` y `register_page.dart` con validación
- [ ] 6.3 Crear `mobile/lib/pages/onboarding/onboarding_page.dart` con intro screens
- [ ] 6.4 Crear `mobile/lib/pages/home/home_page.dart` con dashboard y quick stats
- [ ] 6.5 Crear `mobile/lib/pages/tasks/tasks_page.dart` con list, filters, create/edit dialogs
- [ ] 6.6 Crear `mobile/lib/pages/habits/habits_page.dart` con streak tracking y calendar view
- [ ] 6.7 Crear `mobile/lib/pages/goals/goals_page.dart` con progress bars y milestones
- [ ] 6.8 Crear `mobile/lib/pages/finance/finance_page.dart` con charts y budget management
- [ ] 6.9 Crear `mobile/lib/pages/ai_chat/ai_chat_page.dart` con chat UI y conversation history
- [ ] 6.10 Crear `mobile/lib/pages/profile/profile_page.dart` con settings y preferences

## Fase 7: Flutter - Componentes Compartidos

- [ ] 7.1 Crear `mobile/lib/shared/widgets/gradient_card.dart` con gradient border
- [ ] 7.2 Crear `mobile/lib/shared/widgets/animated_progress_bar.dart` con animación
- [ ] 7.3 Crear `mobile/lib/shared/widgets/status_badge.dart` para indicadores
- [ ] 7.4 Crear `mobile/lib/shared/widgets/empty_state.dart` para listas vacías
- [ ] 7.5 Crear `mobile/lib/shared/widgets/loading_indicator.dart` con spinner custom
- [ ] 7.6 Crear `mobile/lib/shared/widgets/confirm_dialog.dart` para confirmaciones
- [ ] 7.7 Crear `mobile/lib/shared/widgets/filter_chip.dart` y `icon_picker.dart`

## Fase 8: Integración y Verificación

- [ ] 8.1 Verificar que Docker Compose levanta todos los servicios sin errores
- [ ] 8.2 Probar endpoints de API con Postman/curl (auth, tasks, habits, goals, finance, ai, profile)
- [ ] 8.3 Compilar Flutter app con `flutter build apk --debug`
- [ ] 8.4 Verificar navegación entre todas las páginas
- [ ] 8.5 Testear autenticación JWT completa (register, login, logout, token refresh)
- [ ] 8.6 Verificar integración AI chat con OpenAI

## Fase 9: Limpieza y Documentación

- [ ] 9.1 Agregar comentarios JSDoc en routes y servicios del backend
- [ ] 9.2 Documentar variables de entorno requeridas en `.env.example`
- [ ] 9.3 Limpiar código temporal y logs de debug
- [ ] 9.4 Verificar que no hay console warnings en Flutter
