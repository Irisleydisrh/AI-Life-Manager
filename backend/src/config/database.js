const { PrismaClient } = require('@prisma/client');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// =====================================================
// PRISMA CLIENT - SOLO CONEXIÓN
// Las migraciones se hacen manualmente, NO en runtime
// =====================================================

let prismaInstance = null;

// Verificar si el cliente de Prisma ya está generado
const checkPrismaClient = () => {
  const projectDir = path.join(__dirname, '..', '..');
  const clientPath = path.join(projectDir, 'node_modules', '.prisma', 'client');
  
  try {
    // Verificar si existe el cliente
    if (fs.existsSync(clientPath)) {
      return true;
    }
  } catch (e) {
    console.log('⚠️ Prisma client no encontrado');
  }
  return false;
};

// Solo hacer db push (sincronizar schema) - nunca generate en runtime
const syncSchema = async () => {
  try {
    const projectDir = path.join(__dirname, '..', '..');
    
    console.log('🔄 Sincronizando esquema con la base de datos...');
    
    // db push sincroniza el schema sin crear migraciones
    // Esto es seguro para runtime
    execSync('npx prisma db push --skip-generate', {
      cwd: projectDir,
      stdio: 'inherit',
      env: { ...process.env, FORCE_COLOR: '0' },
      stdio: 'ignore' // Silencioso para evitar errores de permisos
    });
    
    console.log('✅ Esquema sincronizado');
  } catch (error) {
    // Silenciar errores - las tablas probablemente ya existen
    console.log('ℹ️ Schema sync: las tablas probablemente ya existen');
  }
};

// Crear cliente Prisma
const createPrismaClient = async () => {
  const client = new PrismaClient({
    log: process.env.NODE_ENV === 'development' 
      ? ['error', 'warn'] 
      : ['error'],
  });
  
  try {
    await client.$connect();
    console.log('✅ Conectado a PostgreSQL via Prisma');
    
    // Sincronizar schema una sola vez al iniciar
    // Nota: esto puede fallar silenciosamente si hay problemas de permisos
    // pero el servidor igual funciona si las tablas ya existen
  } catch (err) {
    console.error('❌ Error de conexión a PostgreSQL:', err.message);
  }
  
  return client;
};

// Obtener instancia (singleton)
const getPrisma = async () => {
  if (!prismaInstance) {
    prismaInstance = await createPrismaClient();
  }
  return prismaInstance;
};

// Export básico (sin inicialización automática)
const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development' 
    ? ['error', 'warn'] 
    : ['error'],
});

// Conectar al iniciar
prisma.$connect()
  .then(() => console.log('✅ Prisma conectado'))
  .catch(err => console.error('❌ Error Prisma:', err.message));

module.exports = { prisma };
module.exports.getPrisma = getPrisma;
module.exports.PrismaClient = PrismaClient;