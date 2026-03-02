import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/task_provider.dart';
import '../../domain/entities/task.dart';
import '../widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    final taskProvider = context.read<TaskProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar Tareas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Estado:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Todos'),
                  selected: taskProvider.filterEstado == null,
                  onSelected: (_) {
                    taskProvider.setFilterEstado(null);
                    Navigator.pop(context);
                  },
                ),
                ...TaskState.values.map((estado) => FilterChip(
                      label: Text(estado.value),
                      selected: taskProvider.filterEstado == estado,
                      onSelected: (_) {
                        taskProvider.setFilterEstado(estado);
                        Navigator.pop(context);
                      },
                    )),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Prioridad:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Todas'),
                  selected: taskProvider.filterPrioridad == null,
                  onSelected: (_) {
                    taskProvider.setFilterPrioridad(null);
                    Navigator.pop(context);
                  },
                ),
                ...TaskPriority.values.map((prioridad) => FilterChip(
                      label: Text(prioridad.value),
                      selected: taskProvider.filterPrioridad == prioridad,
                      onSelected: (_) {
                        taskProvider.setFilterPrioridad(prioridad);
                        Navigator.pop(context);
                      },
                    )),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              taskProvider.clearFilters();
              Navigator.pop(context);
            },
            child: const Text('Limpiar Filtros'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar tareas...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<TaskProvider>().setSearchQuery(null);
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                context.read<TaskProvider>().setSearchQuery(
                      value.isEmpty ? null : value,
                    );
              },
            ),
          ),

          // Active filters
          Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              final hasFilters = taskProvider.filterEstado != null ||
                  taskProvider.filterPrioridad != null ||
                  taskProvider.searchQuery != null;

              if (!hasFilters) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (taskProvider.filterEstado != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(
                              'Estado: ${taskProvider.filterEstado!.value}'),
                          onDeleted: () => taskProvider.setFilterEstado(null),
                        ),
                      ),
                    if (taskProvider.filterPrioridad != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(
                              'Prioridad: ${taskProvider.filterPrioridad!.value}'),
                          onDeleted: () =>
                              taskProvider.setFilterPrioridad(null),
                        ),
                      ),
                    if (taskProvider.searchQuery != null)
                      Chip(
                        label: Text('Buscar: "${taskProvider.searchQuery}"'),
                        onDeleted: () {
                          _searchController.clear();
                          taskProvider.setSearchQuery(null);
                        },
                      ),
                  ],
                ),
              );
            },
          ),

          // Task list
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                if (taskProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (taskProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(taskProvider.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => taskProvider.loadTasks(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (taskProvider.tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No hay tareas',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text('Crea una nueva tarea para comenzar'),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => taskProvider.loadTasks(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: taskProvider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = taskProvider.tasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/tasks/detail',
                            arguments: task,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/tasks/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
