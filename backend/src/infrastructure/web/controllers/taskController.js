const getTasks = (getTasksUseCase) => async (req, res) => {
    try {
        const userId = req.userId;
        const { estado, prioridad, search } = req.query;

        const tasks = await getTasksUseCase.execute({ userId, estado, prioridad, search });

        res.json({
            success: true,
            data: tasks
        });
    } catch (error) {
        console.error('Error en getTasks:', error);
        res.status(500).json({
            success: false,
            message: 'Error al obtener tareas'
        });
    }
};

const getTaskById = (getTaskByIdUseCase) => async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.userId;

        const task = await getTaskByIdUseCase.execute(id, userId);

        res.json({
            success: true,
            data: task
        });
    } catch (error) {
        if (error.message === 'Tarea no encontrada') {
            return res.status(404).json({
                success: false,
                message: error.message
            });
        }
        console.error('Error en getTaskById:', error);
        res.status(500).json({
            success: false,
            message: 'Error al obtener tarea'
        });
    }
};

const createTask = (createTaskUseCase) => async (req, res) => {
    try {
        const userId = req.userId;
        const taskData = req.body;

        const newTask = await createTaskUseCase.execute(userId, taskData);

        res.status(201).json({
            success: true,
            message: 'Tarea creada exitosamente',
            data: newTask
        });
    } catch (error) {
        if (error.message.includes('requerido') || error.message.includes('inválido') || error.message.includes('inválida')) {
            return res.status(400).json({
                success: false,
                message: error.message
            });
        }
        console.error('Error en createTask:', error);
        res.status(500).json({
            success: false,
            message: 'Error al crear tarea'
        });
    }
};

const updateTask = (updateTaskUseCase) => async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.userId;
        const taskData = req.body;

        const updatedTask = await updateTaskUseCase.execute(id, userId, taskData);

        res.json({
            success: true,
            message: 'Tarea actualizada exitosamente',
            data: updatedTask
        });
    } catch (error) {
        if (error.message === 'Tarea no encontrada') {
            return res.status(404).json({
                success: false,
                message: error.message
            });
        }
        if (error.message.includes('proporcionaron') || error.message.includes('inválido') || error.message.includes('inválida')) {
            return res.status(400).json({
                success: false,
                message: error.message
            });
        }
        console.error('Error en updateTask:', error);
        res.status(500).json({
            success: false,
            message: 'Error al actualizar tarea'
        });
    }
};

const deleteTask = (deleteTaskUseCase) => async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.userId;

        await deleteTaskUseCase.execute(id, userId);

        res.json({
            success: true,
            message: 'Tarea eliminada exitosamente'
        });
    } catch (error) {
        if (error.message === 'Tarea no encontrada') {
            return res.status(404).json({
                success: false,
                message: error.message
            });
        }
        console.error('Error en deleteTask:', error);
        res.status(500).json({
            success: false,
            message: 'Error al eliminar tarea'
        });
    }
};

module.exports = {
    getTasks,
    getTaskById,
    createTask,
    updateTask,
    deleteTask
};
