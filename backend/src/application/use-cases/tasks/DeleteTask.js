class DeleteTask {
    constructor(taskRepository) {
        this.taskRepository = taskRepository;
    }

    async execute(id, userId) {
        const existingTask = await this.taskRepository.findById(id, userId);

        if (!existingTask) {
            throw new Error('Tarea no encontrada');
        }

        await this.taskRepository.delete(id, userId);
        return true;
    }
}

module.exports = DeleteTask;
