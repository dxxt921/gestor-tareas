const express = require('express');
const cors = require('cors');
require('dotenv').config();

// Configuración de BD
const { testConnection, query } = require('./infrastructure/database/config');

// Repositorios (Adaptadores de Infraestructura)
const MySQLUserRepository = require('./infrastructure/repositories/MySQLUserRepository');
const MySQLTaskRepository = require('./infrastructure/repositories/MySQLTaskRepository');

// Casos de Uso (Aplicación)
const RegisterUser = require('./application/use-cases/auth/RegisterUser');
const LoginUser = require('./application/use-cases/auth/LoginUser');
const CreateTask = require('./application/use-cases/tasks/CreateTask');
const GetTasks = require('./application/use-cases/tasks/GetTasks');
const GetTaskById = require('./application/use-cases/tasks/GetTaskById');
const UpdateTask = require('./application/use-cases/tasks/UpdateTask');
const DeleteTask = require('./application/use-cases/tasks/DeleteTask');

// Routers
const authRoutes = require('./infrastructure/web/routes/auth');
const taskRoutes = require('./infrastructure/web/routes/tasks');

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging middleware
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    next();
});

// ==========================================
// INYECCIÓN DE DEPENDENCIAS (Dependency Injection)
// ==========================================

// 1. Instanciar Repositorios inyectándoles la conexión a BD
const userRepository = new MySQLUserRepository(query);
const taskRepository = new MySQLTaskRepository(query);

// 2. Instanciar Casos de Uso inyectándoles los Repositorios
const registerUserUseCase = new RegisterUser(userRepository);
const loginUserUseCase = new LoginUser(userRepository);

const createTaskUseCase = new CreateTask(taskRepository);
const getTasksUseCase = new GetTasks(taskRepository);
const getTaskByIdUseCase = new GetTaskById(taskRepository);
const updateTaskUseCase = new UpdateTask(taskRepository);
const deleteTaskUseCase = new DeleteTask(taskRepository);

// 3. Pasar Casos de Uso a los Routers
const authRouter = authRoutes(registerUserUseCase, loginUserUseCase);
const taskRouter = taskRoutes(
    getTasksUseCase,
    getTaskByIdUseCase,
    createTaskUseCase,
    updateTaskUseCase,
    deleteTaskUseCase
);

// ==========================================
// RUTAS
// ==========================================

app.get('/', (req, res) => {
    res.json({
        success: true,
        message: 'Task Manager API (Clean Architecture) - v1.1',
        endpoints: {
            auth: {
                register: 'POST /auth/register',
                login: 'POST /auth/login'
            },
            tasks: {
                list: 'GET /tasks',
                create: 'POST /tasks',
                get: 'GET /tasks/:id',
                update: 'PUT /tasks/:id',
                delete: 'DELETE /tasks/:id'
            }
        }
    });
});

app.use('/auth', authRouter);
app.use('/tasks', taskRouter);

// Manejo de rutas no encontradas
app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: 'Ruta no encontrada'
    });
});

// Manejo de errores global
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(err.status || 500).json({
        success: false,
        message: err.message || 'Error interno del servidor'
    });
});

// Iniciar servidor
const startServer = async () => {
    try {
        // Verificar conexión a la base de datos
        await testConnection();

        app.listen(PORT, () => {
            console.log(`\n🚀 Servidor corriendo en http://localhost:${PORT}`);
            console.log(`📝 Documentación API disponible en http://localhost:${PORT}\n`);
        });
    } catch (error) {
        console.error('Error al iniciar el servidor:', error);
        process.exit(1);
    }
};

startServer();
