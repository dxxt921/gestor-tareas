const ITaskRepository = require('../../domain/ports/ITaskRepository');
const Task = require('../../domain/entities/Task');

class MySQLTaskRepository extends ITaskRepository {
    constructor(dbQuery) {
        super();
        this.query = dbQuery; // Inyectamos la función query de la BD
    }

    async findAll({ userId, estado, prioridad, search }) {
        let sql = 'SELECT * FROM tasks WHERE user_id = ?';
        const params = [userId];

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
        const rows = await this.query(sql, params);

        return rows.map(row => new Task(row));
    }

    async findById(id, userId) {
        const rows = await this.query(
            'SELECT * FROM tasks WHERE id = ? AND user_id = ?',
            [id, userId]
        );
        if (rows.length === 0) return null;
        return new Task(rows[0]);
    }

    async save(task) {
        const result = await this.query(
            'INSERT INTO tasks (user_id, titulo, descripcion, prioridad, estado, fecha_limite) VALUES (?, ?, ?, ?, ?, ?)',
            [
                task.user_id,
                task.titulo,
                task.descripcion || null,
                task.prioridad || 'media',
                task.estado || 'pendiente',
                task.fecha_limite || null
            ]
        );

        // Obtener y retornar la tarea recién creada
        const newRow = await this.query('SELECT * FROM tasks WHERE id = ?', [result.insertId]);
        return new Task(newRow[0]);
    }

    async update(id, userId, taskData) {
        const updates = [];
        const params = [];

        if (taskData.titulo !== undefined) {
            updates.push('titulo = ?');
            params.push(taskData.titulo);
        }
        if (taskData.descripcion !== undefined) {
            updates.push('descripcion = ?');
            params.push(taskData.descripcion);
        }
        if (taskData.prioridad !== undefined) {
            updates.push('prioridad = ?');
            params.push(taskData.prioridad);
        }
        if (taskData.estado !== undefined) {
            updates.push('estado = ?');
            params.push(taskData.estado);
        }
        if (taskData.fecha_limite !== undefined) {
            updates.push('fecha_limite = ?');
            params.push(taskData.fecha_limite);
        }

        if (updates.length > 0) {
            params.push(id, userId);
            await this.query(
                `UPDATE tasks SET ${updates.join(', ')} WHERE id = ? AND user_id = ?`,
                params
            );
        }

        const updatedRow = await this.query('SELECT * FROM tasks WHERE id = ?', [id]);
        return new Task(updatedRow[0]);
    }

    async delete(id, userId) {
        await this.query(
            'DELETE FROM tasks WHERE id = ? AND user_id = ?',
            [id, userId]
        );
    }
}

module.exports = MySQLTaskRepository;
