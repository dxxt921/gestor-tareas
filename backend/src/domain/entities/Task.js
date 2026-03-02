class Task {
    constructor({ id, user_id, titulo, descripcion, prioridad, estado, fecha_creacion, created_at, fecha_limite }) {
        this.id = id;
        this.user_id = user_id;
        this.titulo = titulo;
        this.descripcion = descripcion;
        this.prioridad = prioridad;
        this.estado = estado;
        // Soporta tanto el nombre de DB (created_at) como el de dominio (fecha_creacion)
        this.fecha_creacion = fecha_creacion || created_at;
        this.fecha_limite = fecha_limite;
    }
}

module.exports = Task;
