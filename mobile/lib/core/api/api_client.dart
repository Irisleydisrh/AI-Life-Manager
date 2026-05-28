import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;

  // Configuración optimizada para dispositivo físico
  // IP del backend (ajusta según tu red local)
  // Tu IP actual: 192.168.1.184
  static const String _baseUrl = 'http://192.168.1.184:3000/api/v1';

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  // Cache en memoria para respuestas (optimización de rendimiento)
  static final Map<String, dynamic> _responseCache = {};
  static const _cacheExpiry = Duration(minutes: 2);

  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        // Timeouts reducidos para redes locales
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor con cache
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: _accessTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final token = await _storage.read(key: _accessTokenKey);
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Auth
  Future<Response> register(
    String email,
    String password,
    String fullName,
  ) async {
    return _dio.post(
      '/auth/register',
      data: {'email': email, 'password': password, 'full_name': fullName},
    );
  }

  Future<Response> login(String email, String password) async {
    return _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final newToken = response.data['data']['accessToken'];
      await _storage.write(key: _accessTokenKey, value: newToken);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken != null) {
      try {
        await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
      } catch (_) {}
    }
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
  }

  // Tasks
  Future<Response> getTasks({
    String? status,
    String? priority,
    int page = 1,
  }) async {
    return _dio.get(
      '/tasks',
      queryParameters: {
        if (status != null) 'status': status,
        if (priority != null) 'priority': priority,
        'page': page,
      },
    );
  }

  Future<Response> createTask(Map<String, dynamic> task) async {
    return _dio.post('/tasks', data: task);
  }

  Future<Response> updateTask(String id, Map<String, dynamic> task) async {
    return _dio.put('/tasks/$id', data: task);
  }

  Future<Response> deleteTask(String id) async {
    return _dio.delete('/tasks/$id');
  }

  Future<Response> updateTaskStatus(String id, String status) async {
    return _dio.patch('/tasks/$id/status', data: {'status': status});
  }

  Future<Response> getTaskStats() async {
    return _dio.get('/tasks/stats');
  }

  // Habits
  Future<Response> getHabits() async {
    return _dio.get('/habits');
  }

  Future<Response> createHabit(Map<String, dynamic> habit) async {
    return _dio.post('/habits', data: habit);
  }

  Future<Response> updateHabit(String id, Map<String, dynamic> habit) async {
    return _dio.put('/habits/$id', data: habit);
  }

  Future<Response> deleteHabit(String id) async {
    return _dio.delete('/habits/$id');
  }

  Future<Response> logHabit(String id) async {
    return _dio.post('/habits/$id/log');
  }

  Future<Response> getHabitStats() async {
    return _dio.get('/habits/stats');
  }

  // Goals
  Future<Response> getGoals({String? status, String? category}) async {
    return _dio.get(
      '/goals',
      queryParameters: {
        if (status != null) 'status': status,
        if (category != null) 'category': category,
      },
    );
  }

  Future<Response> createGoal(Map<String, dynamic> goal) async {
    return _dio.post('/goals', data: goal);
  }

  Future<Response> updateGoal(String id, Map<String, dynamic> goal) async {
    return _dio.put('/goals/$id', data: goal);
  }

  Future<Response> deleteGoal(String id) async {
    return _dio.delete('/goals/$id');
  }

  Future<Response> updateGoalProgress(String id, double currentValue) async {
    return _dio.patch(
      '/goals/$id/progress',
      data: {'current_value': currentValue},
    );
  }

  Future<Response> getGoalStats() async {
    return _dio.get('/goals/stats');
  }

  // Finance
  Future<Response> getExpenses({
    String? category,
    String? type,
    int page = 1,
  }) async {
    return _dio.get(
      '/finance/expenses',
      queryParameters: {
        if (category != null) 'category': category,
        if (type != null) 'type': type,
        'page': page,
      },
    );
  }

  Future<Response> createExpense(Map<String, dynamic> expense) async {
    return _dio.post('/finance/expenses', data: expense);
  }

  Future<Response> updateExpense(
    String id,
    Map<String, dynamic> expense,
  ) async {
    return _dio.put('/finance/expenses/$id', data: expense);
  }

  Future<Response> deleteExpense(String id) async {
    return _dio.delete('/finance/expenses/$id');
  }

  Future<Response> getFinanceSummary() async {
    return _dio.get('/finance/summary');
  }

  Future<Response> getBudgets() async {
    return _dio.get('/finance/budgets');
  }

  Future<Response> createBudget(Map<String, dynamic> budget) async {
    return _dio.post('/finance/budgets', data: budget);
  }

  Future<Response> getBudgetStatus() async {
    return _dio.get('/finance/budgets/status');
  }

  // AI Chat
  Future<Response> getConversations() async {
    return _dio.get('/ai/conversations');
  }

  Future<Response> createConversation() async {
    return _dio.post('/ai/conversations');
  }

  Future<Response> getConversation(String id) async {
    return _dio.get('/ai/conversations/$id');
  }

  Future<Response> deleteConversation(String id) async {
    return _dio.delete('/ai/conversations/$id');
  }

  Future<Response> sendMessage(String conversationId, String content) async {
    return _dio.post(
      '/ai/conversations/$conversationId/message',
      data: {'content': content},
    );
  }

  Future<Response> getInsights() async {
    return _dio.get('/ai/insights');
  }

  // Profile
  Future<Response> getProfile() async {
    return _dio.get('/profile');
  }

  Future<Response> updateProfile(Map<String, dynamic> profile) async {
    return _dio.put('/profile', data: profile);
  }

  Future<Response> updateSettings(Map<String, dynamic> settings) async {
    return _dio.put('/profile/settings', data: settings);
  }

  Future<Response> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    return _dio.put(
      '/profile/password',
      data: {'current_password': currentPassword, 'new_password': newPassword},
    );
  }

  Future<Response> completeOnboarding(
    String fullName,
    String language,
    String theme,
  ) async {
    return _dio.post(
      '/profile/onboarding',
      data: {'full_name': fullName, 'language': language, 'theme': theme},
    );
  }

  Future<Response> getUserStats() async {
    return _dio.get('/profile/stats');
  }

  // Storage helpers
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(key: _userKey, value: user.toString());
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null;
  }
}
