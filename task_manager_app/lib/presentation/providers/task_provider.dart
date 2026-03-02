import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import '../../application/usecases/task_usecases.dart';

class TaskProvider with ChangeNotifier {
  final GetTasksUseCase getTasksUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;

  TaskProvider({
    required this.getTasksUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
  });

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  TaskState? _filterEstado;
  TaskPriority? _filterPrioridad;
  String? _searchQuery;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TaskState? get filterEstado => _filterEstado;
  TaskPriority? get filterPrioridad => _filterPrioridad;
  String? get searchQuery => _searchQuery;

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _tasks = await getTasksUseCase.execute(
        estado: _filterEstado,
        prioridad: _filterPrioridad,
        search: _searchQuery,
      );
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTask(Task task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newTask = await createTaskUseCase.execute(task);
      _tasks.insert(0, newTask);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(int id, Task task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updatedTask = await updateTaskUseCase.execute(task);
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      await deleteTaskUseCase.execute(id);
      _tasks.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void setFilterEstado(TaskState? estado) {
    _filterEstado = estado;
    loadTasks();
  }

  void setFilterPrioridad(TaskPriority? prioridad) {
    _filterPrioridad = prioridad;
    loadTasks();
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    loadTasks();
  }

  void clearFilters() {
    _filterEstado = null;
    _filterPrioridad = null;
    _searchQuery = null;
    loadTasks();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Map<String, int> get statistics {
    return {
      'total': _tasks.length,
      'pendiente': _tasks.where((t) => t.estado == TaskState.pendiente).length,
      'enProgreso':
          _tasks.where((t) => t.estado == TaskState.enProgreso).length,
      'hecha': _tasks.where((t) => t.estado == TaskState.hecha).length,
      'alta': _tasks.where((t) => t.prioridad == TaskPriority.alta).length,
    };
  }
}
