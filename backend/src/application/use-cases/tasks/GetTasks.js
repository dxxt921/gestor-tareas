class GetTasks {
    constructor(taskRepository) {
        this.taskRepository = taskRepository;
    }

    async execute(filters) {
        // validations optional over filters
        return await this.taskRepository.findAll(filters);
    }
}

module.exports = GetTasks;
