const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../../../domain/entities/User');

class RegisterUser {
    constructor(userRepository) {
        this.userRepository = userRepository;
    }

    async execute({ nombre, email, password }) {
        if (!nombre || !email || !password) {
            throw new Error('Todos los campos son requeridos');
        }

        if (password.length < 6) {
            throw new Error('La contraseña debe tener al menos 6 caracteres');
        }

        const existingUser = await this.userRepository.findByEmail(email);

        if (existingUser) {
            throw new Error('El email ya está registrado');
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const userToSave = new User({
            nombre,
            email,
            password: hashedPassword
        });

        const savedUser = await this.userRepository.save(userToSave);

        const token = jwt.sign(
            { userId: savedUser.id, email: savedUser.email },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
        );

        return {
            token,
            user: {
                id: savedUser.id,
                nombre: savedUser.nombre,
                email: savedUser.email
            }
        };
    }
}

module.exports = RegisterUser;
