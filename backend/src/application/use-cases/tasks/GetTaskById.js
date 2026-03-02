class GetTaskById {
    constructor(taskRepository) {
        this.taskRepository = taskRepository;
    }

    async execute(id, userId) {
        const task = await this.taskRepository.findById(id, userId);

        if (!task) {
            throw new Error('Tarea no encontrada');
        }

        return task;
    }
}

module.exports = GetTaskById;
