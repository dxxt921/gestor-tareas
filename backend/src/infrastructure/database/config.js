const mysql = require('mysql2/promise');
require('dotenv').config();

// Crear pool de conexiones para mejor rendimiento
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'task_manager_db',
  port: process.env.DB_PORT || 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Función helper para ejecutar queries
const query = async (sql, params) => {
  try {
    const [results] = await pool.execute(sql, params);
    return results;
  } catch (error) {
    console.error('Database query error:', error);
    throw error;
  }
};

// Verificar conexión al iniciar
const testConnection = async () => {
  try {
    const connection = await pool.getConnection();
    console.log('✓ Conexión a MySQL establecida correctamente');
    connection.release();
  } catch (error) {
    console.error('✗ Error al conectar con MySQL:', error.message);
    process.exit(1);
  }
};

module.exports = { pool, query, testConnection };
