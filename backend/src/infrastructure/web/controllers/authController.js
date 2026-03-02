const register = (registerUserUseCase) => async (req, res) => {
    try {
        const { nombre, email, password } = req.body;

        const result = await registerUserUseCase.execute({ nombre, email, password });

        res.status(201).json({
            success: true,
            message: 'Usuario registrado exitosamente',
            data: result
        });
    } catch (error) {
        if (error.message.includes('requeridos') || error.message.includes('caracteres') || error.message.includes('registrado')) {
            return res.status(400).json({
                success: false,
                message: error.message
            });
        }
        console.error('Error en register:', error);
        res.status(500).json({
            success: false,
            message: 'Error al registrar usuario'
        });
    }
};

const login = (loginUserUseCase) => async (req, res) => {
    try {
        const { email, password } = req.body;

        const result = await loginUserUseCase.execute({ email, password });

        res.json({
            success: true,
            message: 'Login exitoso',
            data: result
        });
    } catch (error) {
        if (error.message.includes('requeridos') || error.message.includes('inválidas')) {
            const status = error.message.includes('inválidas') ? 401 : 400;
            return res.status(status).json({
                success: false,
                message: error.message
            });
        }
        console.error('Error en login:', error);
        res.status(500).json({
            success: false,
            message: 'Error al iniciar sesión'
        });
    }
};

module.exports = { register, login };
