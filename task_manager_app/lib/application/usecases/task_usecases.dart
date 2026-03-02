import '../../domain/entities/task.dart';
import '../../domain/repositories/i_task_repository.dart';

class GetTasksUseCase {
  final ITaskRepository repository;
  GetTasksUseCase(this.repository);
  Future<List<Task>> execute(
          {TaskState? estado, TaskPriority? prioridad, String? search}) =>
      repository.getTasks(estado: estado, prioridad: prioridad, search: search);
}

class GetTaskByIdUseCase {
  final ITaskRepository repository;
  GetTaskByIdUseCase(this.repository);
  Future<Task> execute(int id) => repository.getTaskById(id);
}

class CreateTaskUseCase {
  final ITaskRepository repository;
  CreateTaskUseCase(this.repository);
  Future<Task> execute(Task task) => repository.createTask(task);
}

class UpdateTaskUseCase {
  final ITaskRepository repository;
  UpdateTaskUseCase(this.repository);
  Future<Task> execute(Task task) => repository.updateTask(task);
}

class DeleteTaskUseCase {
  final ITaskRepository repository;
  DeleteTaskUseCase(this.repository);
  Future<void> execute(int id) => repository.deleteTask(id);
}
