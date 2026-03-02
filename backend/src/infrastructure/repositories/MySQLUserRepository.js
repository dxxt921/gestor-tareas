const IUserRepository = require('../../domain/ports/IUserRepository');
const User = require('../../domain/entities/User');

class MySQLUserRepository extends IUserRepository {
    constructor(dbQuery) {
        super();
        this.query = dbQuery; // Inyectamos la función query de la BD
    }

    async findByEmail(email) {
        const rows = await this.query(
            'SELECT * FROM users WHERE email = ?',
            [email]
        );
        if (rows.length === 0) return null;
        return new User(rows[0]);
    }

    async save(user) {
        const result = await this.query(
            'INSERT INTO users (nombre, email, password) VALUES (?, ?, ?)',
            [user.nombre, user.email, user.password]
        );

        const newRow = await this.query('SELECT * FROM users WHERE id = ?', [result.insertId]);
        return new User(newRow[0]);
    }
}

module.exports = MySQLUserRepository;
