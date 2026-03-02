const { query } = require('../config/db');

// Obtener todas las tareas del usuario (con filtros opcionales)
const getTasks = async (req, res) => {
    try {
        const userId = req.userId;
        const { estado, prioridad, search } = req.query;

        let sql = 'SELECT * FROM tasks WHERE user_id = ?';
        const params = [userId];

        // Aplicar filtros si existen
        if (estado) {
            sql += ' AND estado = ?';
            params.push(estado);
        }

        if (prioridad) {
            sql += ' AND prioridad = ?';
            params.push(prioridad);
        }

        if (search) {
            sql += ' AND (titulo LIKE ? OR descripcion LIKE ?)';
            params.push(`%${search}%`, `%${search}%`);
        }

        sql += ' ORDER BY fecha_creacion DESC';

        const tasks = await query(sql, params);

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

// Obtener una tarea específica
const getTaskById = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.userId;

        const tasks = await query(
            'SELECT * FROM tasks WHERE id = ? AND user_id = ?',
            [id, userId]
        );

        if (tasks.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Tarea no encontrada'
            });
        }

        res.json({
            success: true,
            data: tasks[0]
        });
    } catch (error) {
        console.error('Error en getTaskById:', error);
        res.status(500).json({
            success: false,
            message: 'Error al obtener tarea'
        });
    }
};

// Crear nueva tarea
const createTask = async (req, res) => {
    try {
        const userId = req.userId;
        const { titulo, descripcion, prioridad, estado, fecha_limite } = req.body;

        // Validaciones
        if (!titulo) {
            return res.status(400).json({
                success: false,
                message: 'El título es requerido'
            });
        }

        const validPriorities = ['alta', 'media', 'baja'];
        const validStates = ['pendiente', 'en progreso', 'hecha'];

        if (prioridad && !validPriorities.includes(prioridad)) {
            return res.status(400).json({
                success: false,
                message: 'Prioridad inválida. Debe ser: alta, media o baja'
            });
        }

        if (estado && !validStates.includes(estado)) {
            return res.status(400).json({
                success: false,
                message: 'Estado inválido. Debe ser: pendiente, en progreso o hecha'
            });
        }

        const result = await query(
            'INSERT INTO tasks (user_id, titulo, descripcion, prioridad, estado, fecha_limite) VALUES (?, ?, ?, ?, ?, ?)',
            [
                userId,
                titulo,
                descripcion || null,
                prioridad || 'media',
                estado || 'pendiente',
                fecha_limite || null
            ]
        );

        // Obtener la tarea recién creada
        const newTask = await query(
            'SELECT * FROM tasks WHERE id = ?',
            [result.insertId]
        );

        res.status(201).json({
            success: true,
            message: 'Tarea creada exitosamente',
            data: newTask[0]
        });
    } catch (error) {
        console.error('Error en createTask:', error);
        res.status(500).json({
            success: false,
            message: 'Error al crear tarea'
        });
    }
};

// Actualizar tarea
const updateTask = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.userId;
        const { titulo, descripcion, prioridad, estado, fecha_limite } = req.body;

        // Verificar que la tarea existe y pertenece al usuario
        const existingTask = await query(
            'SELECT * FROM tasks WHERE id = ? AND user_id = ?',
            [id, userId]
        );

        if (existingTask.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Tarea no encontrada'
            });
        }

        // Validaciones
        const validPriorities = ['alta', 'media', 'baja'];
        const validStates = ['pendiente', 'en progreso', 'hecha'];

        if (prioridad && !validPriorities.includes(prioridad)) {
            return res.status(400).json({
                success: false,
                message: 'Prioridad inválida. Debe ser: alta, media o baja'
            });
        }

        if (estado && !validStates.includes(estado)) {
            return res.status(400).json({
                success: false,
                message: 'Estado inválido. Debe ser: pendiente, en progreso o hecha'
            });
        }

        // Actualizar solo los campos proporcionados
        const updates = [];
        const params = [];

        if (titulo !== undefined) {
            updates.push('titulo = ?');
            params.push(titulo);
        }
        if (descripcion !== undefined) {
            updates.push('descripcion = ?');
            params.push(descripcion);
        }
        if (prioridad !== undefined) {
            updates.push('prioridad = ?');
            params.push(prioridad);
        }
        if (estado !== undefined) {
            updates.push('estado = ?');
            params.push(estado);
        }
        if (fecha_limite !== undefined) {
            updates.push('fecha_limite = ?');
            params.push(fecha_limite);
        }

        if (updates.length === 0) {
            return res.status(400).json({
                success: false,
                message: 'No se proporcionaron campos para actualizar'
            });
        }

        params.push(id, userId);

        await query(
            `UPDATE tasks SET ${updates.join(', ')} WHERE id = ? AND user_id = ?`,
            params
        );

        // Obtener la tarea actualizada
        const updatedTask = await query(
            'SELECT * FROM tasks WHERE id = ?',
            [id]
        );

        res.json({
            success: true,
            message: 'Tarea actualizada exitosamente',
            data: updatedTask[0]
        });
    } catch (error) {
        console.error('Error en updateTask:', error);
        res.status(500).json({
            success: false,
            message: 'Error al actualizar tarea'
        });
    }
};

// Eliminar tarea
const deleteTask = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.userId;

        // Verificar que la tarea existe y pertenece al usuario
        const existingTask = await query(
            'SELECT * FROM tasks WHERE id = ? AND user_id = ?',
            [id, userId]
        );

        if (existingTask.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Tarea no encontrada'
            });
        }

        await query(
            'DELETE FROM tasks WHERE id = ? AND user_id = ?',
            [id, userId]
        );

        res.json({
            success: true,
            message: 'Tarea eliminada exitosamente'
        });
    } catch (error) {
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
