const express = require('express');
const authMiddleware = require('../middleware/auth');
const {
    getTasks,
    getTaskById,
    createTask,
    updateTask,
    deleteTask
} = require('../controllers/taskController');

module.exports = (
    getTasksUseCase,
    getTaskByIdUseCase,
    createTaskUseCase,
    updateTaskUseCase,
    deleteTaskUseCase
) => {
    const router = express.Router();

    // Todas las rutas requieren autenticación
    router.use(authMiddleware);

    // GET /tasks - Obtener todas las tareas (con filtros opcionales)
    router.get('/', getTasks(getTasksUseCase));

    // POST /tasks - Crear nueva tarea
    router.post('/', createTask(createTaskUseCase));

    // GET /tasks/:id - Obtener tarea específica
    router.get('/:id', getTaskById(getTaskByIdUseCase));

    // PUT /tasks/:id - Actualizar tarea
    router.put('/:id', updateTask(updateTaskUseCase));

    // DELETE /tasks/:id - Eliminar tarea
    router.delete('/:id', deleteTask(deleteTaskUseCase));

    return router;
}
