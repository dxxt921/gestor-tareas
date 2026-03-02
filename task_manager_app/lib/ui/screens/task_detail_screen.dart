import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../presentation/providers/task_provider.dart';
import '../../domain/entities/task.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Tarea'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.of(context).pushNamed(
                '/tasks/edit',
                arguments: task,
              );
              if (result == true && context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              task.titulo,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Estado
            _buildInfoCard(
              context,
              'Estado',
              task.estado.value,
              Icons.track_changes,
              _getStateColor(task.estado),
            ),
            const SizedBox(height: 12),

            // Prioridad
            _buildInfoCard(
              context,
              'Prioridad',
              task.prioridad.value,
              Icons.flag,
              _getPriorityColor(task.prioridad),
            ),
            const SizedBox(height: 12),

            // Fecha de creación
            if (task.fechaCreacion != null)
              _buildInfoCard(
                context,
                'Fecha de Creación',
                DateFormat('dd/MM/yyyy HH:mm').format(task.fechaCreacion!),
                Icons.calendar_today,
                Colors.blue,
              ),
            const SizedBox(height: 12),

            // Fecha límite
            if (task.fechaLimite != null)
              _buildInfoCard(
                context,
                'Fecha Límite',
                DateFormat('dd/MM/yyyy').format(task.fechaLimite!),
                Icons.event,
                _isOverdue(task.fechaLimite!) ? Colors.red : Colors.blue,
              ),
            const SizedBox(height: 24),

            // Descripción
            if (task.descripcion != null && task.descripcion!.isNotEmpty) ...[
              Text(
                'Descripción',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    task.descripcion!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color _getStateColor(TaskState estado) {
    switch (estado) {
      case TaskState.pendiente:
        return Colors.orange;
      case TaskState.enProgreso:
        return Colors.purple;
      case TaskState.hecha:
        return Colors.green;
    }
  }

  Color _getPriorityColor(TaskPriority prioridad) {
    switch (prioridad) {
      case TaskPriority.alta:
        return Colors.red;
      case TaskPriority.media:
        return Colors.orange;
      case TaskPriority.baja:
        return Colors.green;
    }
  }

  bool _isOverdue(DateTime fechaLimite) {
    return fechaLimite.isBefore(DateTime.now());
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tarea'),
        content: const Text('¿Estás seguro de que deseas eliminar esta tarea?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final taskProvider = context.read<TaskProvider>();
      final success = await taskProvider.deleteTask(task.id!);

      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarea eliminada'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(taskProvider.error ?? 'Error al eliminar tarea'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
