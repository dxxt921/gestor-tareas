const Task = require('../../../domain/entities/Task');

class CreateTask {
    constructor(taskRepository) {
        this.taskRepository = taskRepository;
    }

    async execute(userId, taskData) {
        const { titulo, descripcion, prioridad, estado, fecha_limite } = taskData;

        if (!titulo) {
            throw new Error('El título es requerido');
        }

        const validPriorities = ['alta', 'media', 'baja'];
        const validStates = ['pendiente', 'en progreso', 'hecha'];

        if (prioridad && !validPriorities.includes(prioridad)) {
            throw new Error('Prioridad inválida. Debe ser: alta, media o baja');
        }

        if (estado && !validStates.includes(estado)) {
            throw new Error('Estado inválido. Debe ser: pendiente, en progreso o hecha');
        }

        const task = new Task({
            user_id: userId,
            titulo,
            descripcion,
            prioridad,
            estado,
            fecha_limite
        });

        return await this.taskRepository.save(task);
    }
}

module.exports = CreateTask;
