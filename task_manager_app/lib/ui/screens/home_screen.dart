import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/task_provider.dart';
import '../../domain/entities/weather.dart';
import '../../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Weather? _weather;
  bool _loadingWeather = false;
  String? _weatherError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Cargar tareas
    context.read<TaskProvider>().loadTasks();

    // Cargar clima
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _loadingWeather = true;
      _weatherError = null;
    });

    try {
      final weather = await WeatherService.getWeatherByCity('Mexico City');
      setState(() {
        _weather = weather;
        _loadingWeather = false;
      });
    } catch (e) {
      setState(() {
        _weatherError = 'No se pudo cargar el clima';
        _loadingWeather = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final stats = taskProvider.statistics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bienvenida
              Text(
                '¡Hola, ${authProvider.user?.nombre ?? 'Usuario'}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aquí está tu resumen de tareas',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),

              // Clima Widget
              _buildWeatherCard(),
              const SizedBox(height: 24),

              // Estadísticas de tareas
              Text(
                'Mis Tareas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total',
                      stats['total']!,
                      Colors.blue,
                      Icons.task,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Pendientes',
                      stats['pendiente']!,
                      Colors.orange,
                      Icons.pending_actions,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'En Progreso',
                      stats['enProgreso']!,
                      Colors.purple,
                      Icons.refresh,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Completadas',
                      stats['hecha']!,
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildStatCard(
                'Alta Prioridad',
                stats['alta']!,
                Colors.red,
                Icons.priority_high,
              ),
              const SizedBox(height: 24),

              // Botón para ver todas las tareas
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/tasks');
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('Ver Todas las Tareas'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/tasks/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wb_sunny, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Clima Actual',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loadingWeather)
              const Center(child: CircularProgressIndicator())
            else if (_weatherError != null)
              Column(
                children: [
                  Text(_weatherError!,
                      style: const TextStyle(color: Colors.red)),
                  TextButton(
                    onPressed: _loadWeather,
                    child: const Text('Reintentar'),
                  ),
                ],
              )
            else if (_weather != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _weather!.city,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _weather!.description,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_weather!.temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Sensación: ${_weather!.feelsLike.toStringAsFixed(1)}°C',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Image.network(
                        _weather!.iconUrl,
                        width: 64,
                        height: 64,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.wb_cloudy, size: 64);
                        },
                      ),
                      Text('Humedad: ${_weather!.humidity}%'),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
