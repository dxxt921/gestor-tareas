class UpdateTask {
    constructor(taskRepository) {
        this.taskRepository = taskRepository;
    }

    async execute(id, userId, taskData) {
        // Verificar que la tarea existe y pertenece al usuario
        const existingTask = await this.taskRepository.findById(id, userId);

        if (!existingTask) {
            throw new Error('Tarea no encontrada');
        }

        const validPriorities = ['alta', 'media', 'baja'];
        const validStates = ['pendiente', 'en progreso', 'hecha'];

        if (taskData.prioridad && !validPriorities.includes(taskData.prioridad)) {
            throw new Error('Prioridad inválida. Debe ser: alta, media o baja');
        }

        if (taskData.estado && !validStates.includes(taskData.estado)) {
            throw new Error('Estado inválido. Debe ser: pendiente, en progreso o hecha');
        }

        // Verificar que haya al menos un campo a actualizar
        const hasUpdates = Object.values(taskData).some(val => val !== undefined);
        if (!hasUpdates) {
            throw new Error('No se proporcionaron campos para actualizar');
        }

        return await this.taskRepository.update(id, userId, taskData);
    }
}

module.exports = UpdateTask;
