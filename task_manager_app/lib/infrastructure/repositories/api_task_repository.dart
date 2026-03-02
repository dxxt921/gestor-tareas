import '../../domain/entities/task.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../../utils/constants.dart';
import '../network/api_client.dart';

class ApiTaskRepository implements ITaskRepository {
  @override
  Future<List<Task>> getTasks(
      {TaskState? estado, TaskPriority? prioridad, String? search}) async {
    String endpoint = AppConstants.tasksEndpoint;
    final params = <String>[];

    if (estado != null) {
      params.add('estado=${Uri.encodeComponent(estado.value)}');
    }
    if (prioridad != null) {
      params.add('prioridad=${Uri.encodeComponent(prioridad.value)}');
    }
    if (search != null && search.isNotEmpty) {
      params.add('search=${Uri.encodeComponent(search)}');
    }

    if (params.isNotEmpty) {
      endpoint += '?${params.join('&')}';
    }

    final response = await ApiService.get(endpoint);
    if (response['success'] == true) {
      final data = response['data'] as List;
      return data
          .map((json) => Task.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response['message'] ?? 'Error al obtener tareas');
    }
  }

  @override
  Future<Task> getTaskById(int id) async {
    final response = await ApiService.get('${AppConstants.tasksEndpoint}/$id');
    if (response['success'] == true) {
      return Task.fromJson(response['data'] as Map<String, dynamic>);
    } else {
      throw Exception(response['message'] ?? 'Error al obtener tarea');
    }
  }

  @override
  Future<Task> createTask(Task task) async {
    final response = await ApiService.post(
      AppConstants.tasksEndpoint,
      task.toJson(),
    );
    if (response['success'] == true) {
      return Task.fromJson(response['data'] as Map<String, dynamic>);
    } else {
      throw Exception(response['message'] ?? 'Error al crear tarea');
    }
  }

  @override
  Future<Task> updateTask(Task task) async {
    // Si la API usa el id en la URL:
    final response = await ApiService.put(
      '${AppConstants.tasksEndpoint}/${task.id}',
      task.toJson(),
    );
    if (response['success'] == true) {
      return Task.fromJson(response['data'] as Map<String, dynamic>);
    } else {
      throw Exception(response['message'] ?? 'Error al actualizar tarea');
    }
  }

  @override
  Future<void> deleteTask(int id) async {
    final response =
        await ApiService.delete('${AppConstants.tasksEndpoint}/$id');
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Error al eliminar tarea');
    }
  }
}
