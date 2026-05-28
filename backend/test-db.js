const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'postgres',
  password: 'admin123',
  port: 5432,
});

async function setupDatabase() {
  let client;
  try {
    console.log('🔌 Conectando a PostgreSQL como postgres...');
    client = await pool.connect();
    console.log('✅ Conectado!');

    // Check existing users
    console.log('\n📋 Usuarios existentes:');
    const users = await client.query('SELECT usename, usecreatedb FROM pg_user');
    users.rows.forEach(u => console.log(`  - ${u.usename} (createdb: ${u.usecreatedb})`));

    // Check if our database exists
    console.log('\n📋 Bases de datos:');
    const dbs = await client.query("SELECT datname FROM pg_database WHERE datname IN ('AI_Life_Manager_db', 'postgres')");
    dbs.rows.forEach(db => console.log(`  - ${db.datname}`));

    // Create database if not exists
    const dbExists = dbs.rows.find(r => r.datname === 'AI_Life_Manager_db');
    if (!dbExists) {
      console.log('\n📦 Creando base de datos AI_Life_Manager_db...');
      // Need to disconnect first to create database
      client.release();
      await pool.end();

      const createPool = new Pool({
        user: 'postgres',
        host: 'localhost',
        database: 'postgres',
        password: 'admin123',
        port: 5432,
      });
      const createClient = await createPool.connect();
      await createClient.query('CREATE DATABASE "AI_Life_Manager_db"');
      console.log('✅ Base de datos creada!');
      createClient.release();
      await createPool.end();
    } else {
      console.log('\nℹ️ La base de datos ya existe');
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    if (client) client.release();
    await pool.end();
  }
}

setupDatabase();
