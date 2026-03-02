import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: título y prioridad
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.titulo,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildPriorityBadge(),
                ],
              ),

              // Descripción (si existe)
              if (task.descripcion != null && task.descripcion!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.descripcion!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Footer: estado y fecha
              Row(
                children: [
                  _buildStateBadge(),
                  const Spacer(),
                  if (task.fechaLimite != null)
                    Row(
                      children: [
                        Icon(
                          Icons.event,
                          size: 16,
                          color: _isOverdue() ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(task.fechaLimite!),
                          style: TextStyle(
                            fontSize: 12,
                            color: _isOverdue() ? Colors.red : Colors.grey[600],
                            fontWeight: _isOverdue()
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge() {
    Color color;
    switch (task.prioridad) {
      case TaskPriority.alta:
        color = Colors.red;
        break;
      case TaskPriority.media:
        color = Colors.orange;
        break;
      case TaskPriority.baja:
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            task.prioridad.value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateBadge() {
    Color color;
    IconData icon;

    switch (task.estado) {
      case TaskState.pendiente:
        color = Colors.orange;
        icon = Icons.pending_actions;
        break;
      case TaskState.enProgreso:
        color = Colors.purple;
        icon = Icons.refresh;
        break;
      case TaskState.hecha:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            task.estado.value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _isOverdue() {
    if (task.fechaLimite == null) return false;
    return task.fechaLimite!.isBefore(DateTime.now()) &&
        task.estado != TaskState.hecha;
  }
}
