/**
 * Interfaz (Puerto) para el Repositorio de Tareas.
 * En JavaScript las interfaces no existen nativamente, 
 * pero documentamos los métodos que CUALQUIER adaptador de Base de Datos debe implementar.
 */
class ITaskRepository {
    async findAll({ userId, estado, prioridad, search }) { throw new Error('Not implemented'); }
    async findById(id, userId) { throw new Error('Not implemented'); }
    async save(task) { throw new Error('Not implemented'); }
    async update(id, userId, taskData) { throw new Error('Not implemented'); }
    async delete(id, userId) { throw new Error('Not implemented'); }
}

module.exports = ITaskRepository;
