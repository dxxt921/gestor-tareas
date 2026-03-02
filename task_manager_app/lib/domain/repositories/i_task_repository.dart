import '../entities/task.dart';

abstract class ITaskRepository {
  Future<List<Task>> getTasks(
      {TaskState? estado, TaskPriority? prioridad, String? search});
  Future<Task> getTaskById(int id);
  Future<Task> createTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(int id);
}
