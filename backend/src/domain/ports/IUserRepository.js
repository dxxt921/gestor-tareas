/**
 * Interfaz (Puerto) para el Repositorio de Usuarios.
 */
class IUserRepository {
    async findByEmail(email) { throw new Error('Not implemented'); }
    async save(user) { throw new Error('Not implemented'); }
}

module.exports = IUserRepository;
