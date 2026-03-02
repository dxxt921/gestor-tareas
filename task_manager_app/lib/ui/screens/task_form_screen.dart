import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../presentation/providers/task_provider.dart';
import '../../domain/entities/task.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TaskPriority _prioridad;
  late TaskState _estado;
  DateTime? _fechaLimite;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.task?.titulo ?? '');
    _descripcionController =
        TextEditingController(text: widget.task?.descripcion ?? '');
    _prioridad = widget.task?.prioridad ?? TaskPriority.media;
    _estado = widget.task?.estado ?? TaskState.pendiente;
    _fechaLimite = widget.task?.fechaLimite;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaLimite ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _fechaLimite = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: widget.task?.id,
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        prioridad: _prioridad,
        estado: _estado,
        fechaLimite: _fechaLimite,
      );

      final taskProvider = context.read<TaskProvider>();
      bool success;

      if (isEditing) {
        success = await taskProvider.updateTask(widget.task!.id!, task);
      } else {
        success = await taskProvider.createTask(task);
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? 'Tarea actualizada' : 'Tarea creada',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(taskProvider.error ?? 'Error al guardar tarea'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Tarea' : 'Nueva Tarea'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Título
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El título es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Descripción
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            // Prioridad
            DropdownButtonFormField<TaskPriority>(
              value: _prioridad,
              decoration: const InputDecoration(
                labelText: 'Prioridad',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              items: TaskPriority.values.map((prioridad) {
                return DropdownMenuItem(
                  value: prioridad,
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: _getPriorityColor(prioridad),
                      ),
                      const SizedBox(width: 8),
                      Text(prioridad.value),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _prioridad = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Estado
            DropdownButtonFormField<TaskState>(
              value: _estado,
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.track_changes),
              ),
              items: TaskState.values.map((estado) {
                return DropdownMenuItem(
                  value: estado,
                  child: Text(estado.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _estado = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Fecha límite
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha Límite',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _fechaLimite != null
                          ? DateFormat('dd/MM/yyyy').format(_fechaLimite!)
                          : 'Seleccionar fecha',
                      style: TextStyle(
                        color: _fechaLimite != null ? null : Colors.grey,
                      ),
                    ),
                    if (_fechaLimite != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _fechaLimite = null;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Botón guardar
            Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                return ElevatedButton(
                  onPressed: taskProvider.isLoading ? null : _saveTask,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: taskProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isEditing ? 'Actualizar Tarea' : 'Crear Tarea',
                          style: const TextStyle(fontSize: 16),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
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
}
