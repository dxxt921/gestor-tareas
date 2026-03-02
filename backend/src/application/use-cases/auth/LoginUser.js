const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

class LoginUser {
    constructor(userRepository) {
        this.userRepository = userRepository;
    }

    async execute({ email, password }) {
        if (!email || !password) {
            throw new Error('Email y contraseña son requeridos');
        }

        const user = await this.userRepository.findByEmail(email);

        if (!user) {
            throw new Error('Credenciales inválidas');
        }

        const validPassword = await bcrypt.compare(password, user.password);

        if (!validPassword) {
            throw new Error('Credenciales inválidas');
        }

        const token = jwt.sign(
            { userId: user.id, email: user.email },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
        );

        return {
            token,
            user: {
                id: user.id,
                nombre: user.nombre,
                email: user.email
            }
        };
    }
}

module.exports = LoginUser;
