-- Crear base de datos
CREATE DATABASE IF NOT EXISTS task_manager_db;
USE task_manager_db;

-- Tabla de usuarios
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla de tareas
CREATE TABLE IF NOT EXISTS tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT,
    prioridad ENUM('alta', 'media', 'baja') DEFAULT 'media',
    estado ENUM('pendiente', 'en progreso', 'hecha') DEFAULT 'pendiente',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_limite DATE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_estado (estado),
    INDEX idx_prioridad (prioridad)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insertar usuario de prueba (password: test123)
INSERT INTO users (nombre, email, password) 
VALUES ('Usuario Test', 'test@test.com', '$2a$10$X8qZ9YqZ9YqZ9YqZ9YqZ9.rQJ3vW0vN0vN0vN0vN0vN0vN0vN0vNO');

-- Insertar algunas tareas de ejemplo
INSERT INTO tasks (user_id, titulo, descripcion, prioridad, estado, fecha_limite) 
VALUES 
    (1, 'Completar documentación del proyecto', 'Crear README completo con instrucciones de instalación y uso', 'alta', 'en progreso', DATE_ADD(CURDATE(), INTERVAL 5 DAY)),
    (1, 'Implementar autenticación JWT', 'Configurar middleware de autenticación con tokens JWT', 'alta', 'hecha', DATE_ADD(CURDATE(), INTERVAL -2 DAY)),
    (1, 'Diseñar interfaz de usuario', 'Crear mockups para todas las pantallas principales', 'media', 'pendiente', DATE_ADD(CURDATE(), INTERVAL 7 DAY)),
    (1, 'Configurar base de datos', 'Setup MySQL y crear esquema inicial', 'alta', 'hecha', DATE_ADD(CURDATE(), INTERVAL -5 DAY)),
    (1, 'Pruebas de integración', 'Escribir tests para endpoints principales', 'baja', 'pendiente', DATE_ADD(CURDATE(), INTERVAL 14 DAY));
