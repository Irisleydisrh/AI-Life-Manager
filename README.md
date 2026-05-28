# AI Life Manager - Monorepo

## Estructura

```
ai-life-manager/
├── mobile/           # Flutter App
├── backend/          # Express.js API
├── docker-compose.yml
└── .env.example
```

## Desarrollo

```bash
# Iniciar todo con Docker
docker-compose up -d

# Backend
cd backend && npm run dev

# Mobile
cd mobile && flutter run
```

## Variables de Entorno

Ver `.env.example` para配置