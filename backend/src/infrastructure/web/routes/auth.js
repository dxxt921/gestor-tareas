const express = require('express');
const { register, login } = require('../controllers/authController');

module.exports = (registerUserUseCase, loginUserUseCase) => {
    const router = express.Router();

    // POST /auth/register - Registrar nuevo usuario
    router.post('/register', register(registerUserUseCase));

    // POST /auth/login - Iniciar sesión
    router.post('/login', login(loginUserUseCase));

    return router;
};
