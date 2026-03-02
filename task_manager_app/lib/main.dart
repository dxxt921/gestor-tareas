import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importaciones de Clean Architecture
import 'infrastructure/repositories/api_auth_repository.dart';
import 'infrastructure/repositories/api_task_repository.dart';
import 'application/usecases/auth_usecases.dart';
import 'application/usecases/task_usecases.dart';

import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/task_provider.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/register_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/task_list_screen.dart';
import 'ui/screens/task_form_screen.dart';
import 'ui/screens/task_detail_screen.dart';
import 'domain/entities/task.dart';

void main() {
  // 1. Instanciar Repositorios (Infraestructura)
  final authRepository = ApiAuthRepository();
  final taskRepository = ApiTaskRepository();

  // 2. Instanciar Casos de Uso (Aplicación)
  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);
  final checkAuthUseCase = CheckAuthUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);

  final getTasksUseCase = GetTasksUseCase(taskRepository);
  final createTaskUseCase = CreateTaskUseCase(taskRepository);
  final updateTaskUseCase = UpdateTaskUseCase(taskRepository);
  final deleteTaskUseCase = DeleteTaskUseCase(taskRepository);

  runApp(MyApp(
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
    checkAuthUseCase: checkAuthUseCase,
    logoutUseCase: logoutUseCase,
    getTasksUseCase: getTasksUseCase,
    createTaskUseCase: createTaskUseCase,
    updateTaskUseCase: updateTaskUseCase,
    deleteTaskUseCase: deleteTaskUseCase,
  ));
}

class MyApp extends StatelessWidget {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final CheckAuthUseCase checkAuthUseCase;
  final LogoutUseCase logoutUseCase;
  final GetTasksUseCase getTasksUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;

  const MyApp({
    super.key,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.checkAuthUseCase,
    required this.logoutUseCase,
    required this.getTasksUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider(
                  loginUseCase: loginUseCase,
                  registerUseCase: registerUseCase,
                  checkAuthUseCase: checkAuthUseCase,
                  logoutUseCase: logoutUseCase,
                )),
        ChangeNotifierProvider(
            create: (_) => TaskProvider(
                  getTasksUseCase: getTasksUseCase,
                  createTaskUseCase: createTaskUseCase,
                  updateTaskUseCase: updateTaskUseCase,
                  deleteTaskUseCase: deleteTaskUseCase,
                )),
      ],
      child: MaterialApp(
        title: 'Task Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/tasks': (context) => const TaskListScreen(),
        },
        onGenerateRoute: (settings) {
          // Ruta para crear tarea
          if (settings.name == '/tasks/create') {
            return MaterialPageRoute(
              builder: (context) => const TaskFormScreen(),
            );
          }

          // Ruta para editar tarea
          if (settings.name == '/tasks/edit') {
            final task = settings.arguments as Task;
            return MaterialPageRoute(
              builder: (context) => TaskFormScreen(task: task),
            );
          }

          // Ruta para detalle de tarea
          if (settings.name == '/tasks/detail') {
            final task = settings.arguments as Task;
            return MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task),
            );
          }

          return null;
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1)); // Simular splash

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.checkAuth();

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.task_alt,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              'Task Manager',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
