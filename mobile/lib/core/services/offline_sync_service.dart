import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Servicio de caché offline con sincronización a PostgreSQL
///
/// Este servicio:
///
/// 1. Cachea datos localmente cuando no hay internet
/// 2. Detecta cuando hay conexión
/// 3. Sincroniza los datos pendientes con el backend
class OfflineSyncService {
  static const String _tasksBox = 'offline_tasks';
  static const String _habitsBox = 'offline_habits';
  static const String _goalsBox = 'offline_goals';
  static const String _expensesBox = 'offline_expenses';
  static const String _syncQueueBox = 'sync_queue';

  late Box _tasksBoxInstance;
  late Box _habitsBoxInstance;
  late Box _goalsBoxInstance;
  late Box _expensesBoxInstance;
  late Box _syncQueueBoxInstance;

  bool _isInitialized = false;

  /// Inicializar el servicio de caché offline
  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    _tasksBoxInstance = await Hive.openBox(_tasksBox);
    _habitsBoxInstance = await Hive.openBox(_habitsBox);
    _goalsBoxInstance = await Hive.openBox(_goalsBox);
    _expensesBoxInstance = await Hive.openBox(_expensesBox);
    _syncQueueBoxInstance = await Hive.openBox(_syncQueueBox);

    _isInitialized = true;
    print('✅ Offline sync service initialized');
  }

  /// Verificar si hay conexión a internet
  Future<bool> hasConnection() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Escuchar cambios en la conectividad
  Stream<bool> get connectivityStream {
    return Connectivity()
        .onConnectivityChanged
        .map((result) => !result.contains(ConnectivityResult.none));
  }

  // ==================== TAREA ====================

  /// Guardar tarea offline
  Future<void> saveTaskOffline(Map<String, dynamic> task) async {
    final id = task['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    task['offline'] = true;
    task['createdAt'] = DateTime.now().toIso8601String();

    await _tasksBoxInstance.put(id, task);

    // Agregar a cola de sync
    await _addToSyncQueue('task', id, 'create');
  }

  /// Actualizar tarea offline
  Future<void> updateTaskOffline(String id, Map<String, dynamic> task) async {
    task['offline'] = true;
    task['updatedAt'] = DateTime.now().toIso8601String();

    await _tasksBoxInstance.put(id, task);

    await _addToSyncQueue('task', id, 'update');
  }

  /// Eliminar tarea offline
  Future<void> deleteTaskOffline(String id) async {
    await _tasksBoxInstance.delete(id);
    await _addToSyncQueue('task', id, 'delete');
  }

  /// Obtener tareas (incluye las offline)
  List<Map<String, dynamic>> getTasks() {
    final tasks = <Map<String, dynamic>>[];
    for (var key in _tasksBoxInstance.keys) {
      tasks.add(Map<String, dynamic>.from(_tasksBoxInstance.get(key)));
    }
    return tasks;
  }

  // ==================== HÁBITO ====================

  /// Guardar hábito offline
  Future<void> saveHabitOffline(Map<String, dynamic> habit) async {
    final id = habit['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    habit['offline'] = true;
    habit['createdAt'] = DateTime.now().toIso8601String();

    await _habitsBoxInstance.put(id, habit);
    await _addToSyncQueue('habit', id, 'create');
  }

  /// Loguear hábito offline
  Future<void> logHabitOffline(String habitId, Map<String, dynamic> log) async {
    log['habitId'] = habitId;
    log['loggedAt'] = DateTime.now().toIso8601String();
    log['offline'] = true;

    final habitLogBox = await Hive.openBox('habit_logs');
    final logId = DateTime.now().millisecondsSinceEpoch.toString();
    await habitLogBox.put(logId, log);

    await _addToSyncQueue('habit_log', logId, 'create');
  }

  /// Obtener hábitos
  List<Map<String, dynamic>> getHabits() {
    final habits = <Map<String, dynamic>>[];
    for (var key in _habitsBoxInstance.keys) {
      habits.add(Map<String, dynamic>.from(_habitsBoxInstance.get(key)));
    }
    return habits;
  }

  // ==================== META ====================

  /// Guardar meta offline
  Future<void> saveGoalOffline(Map<String, dynamic> goal) async {
    final id = goal['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    goal['offline'] = true;
    goal['createdAt'] = DateTime.now().toIso8601String();

    await _goalsBoxInstance.put(id, goal);
    await _addToSyncQueue('goal', id, 'create');
  }

  /// Actualizar progreso de meta offline
  Future<void> updateGoalProgressOffline(String id, double progress) async {
    final goal = _goalsBoxInstance.get(id);
    if (goal != null) {
      goal['currentValue'] = progress;
      goal['offline'] = true;
      goal['updatedAt'] = DateTime.now().toIso8601String();
      await _goalsBoxInstance.put(id, goal);
      await _addToSyncQueue('goal', id, 'update_progress');
    }
  }

  /// Obtener metas
  List<Map<String, dynamic>> getGoals() {
    final goals = <Map<String, dynamic>>[];
    for (var key in _goalsBoxInstance.keys) {
      goals.add(Map<String, dynamic>.from(_goalsBoxInstance.get(key)));
    }
    return goals;
  }

  // ==================== GASTO ====================

  /// Guardar gasto offline
  Future<void> saveExpenseOffline(Map<String, dynamic> expense) async {
    final id =
        expense['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    expense['offline'] = true;
    expense['createdAt'] = DateTime.now().toIso8601String();

    await _expensesBoxInstance.put(id, expense);
    await _addToSyncQueue('expense', id, 'create');
  }

  /// Obtener gastos
  List<Map<String, dynamic>> getExpenses() {
    final expenses = <Map<String, dynamic>>[];
    for (var key in _expensesBoxInstance.keys) {
      expenses.add(Map<String, dynamic>.from(_expensesBoxInstance.get(key)));
    }
    return expenses;
  }

  // ==================== SYNC ====================

  /// Agregar elemento a la cola de sincronización
  Future<void> _addToSyncQueue(
      String entity, String entityId, String action) async {
    final queueItem = {
      'entity': entity,
      'entityId': entityId,
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final key =
        '${entity}_${entityId}_${DateTime.now().millisecondsSinceEpoch}';
    await _syncQueueBoxInstance.put(key, queueItem);
  }

  /// Obtener cola de sincronización
  List<Map<String, dynamic>> getSyncQueue() {
    final queue = <Map<String, dynamic>>[];
    for (var key in _syncQueueBoxInstance.keys) {
      queue.add(Map<String, dynamic>.from(_syncQueueBoxInstance.get(key)));
    }
    // Ordenar por timestamp
    queue.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
    return queue;
  }

  /// Limpiar elemento de la cola después de sync exitoso
  Future<void> removeFromSyncQueue(String entity, String entityId) async {
    final keysToRemove = <String>[];

    for (var key in _syncQueueBoxInstance.keys) {
      final item = _syncQueueBoxInstance.get(key);
      if (item['entity'] == entity && item['entityId'] == entityId) {
        keysToRemove.add(key);
      }
    }

    for (var key in keysToRemove) {
      await _syncQueueBoxInstance.delete(key);
    }
  }

  /// Limpiar todos los datos offline (después de sync exitoso)
  Future<void> clearOfflineData() async {
    await _tasksBoxInstance.clear();
    await _habitsBoxInstance.clear();
    await _goalsBoxInstance.clear();
    await _expensesBoxInstance.clear();
    await _syncQueueBoxInstance.clear();
  }

  /// Obtener estadísticas del cache
  Map<String, int> getCacheStats() {
    return {
      'tasks': _tasksBoxInstance.length,
      'habits': _habitsBoxInstance.length,
      'goals': _goalsBoxInstance.length,
      'expenses': _expensesBoxInstance.length,
      'pendingSync': _syncQueueBoxInstance.length,
    };
  }
}

/// Instancia global del servicio
final offlineSyncService = OfflineSyncService();
