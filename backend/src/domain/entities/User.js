class User {
    constructor({ id, nombre, email, password, created_at, fecha_registro }) {
        this.id = id;
        this.nombre = nombre;
        this.email = email;
        this.password = password;
        // Soporta tanto el nombre de DB (created_at) como el de dominio (fecha_registro)
        this.fecha_registro = fecha_registro || created_at;
    }
}

module.exports = User;
