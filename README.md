# Quick Journal API

> A production-ready journaling API built with modern Node.js technologies and microservices architecture.

[![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=flat&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)
[![GraphQL](https://img.shields.io/badge/GraphQL-E10098?style=flat&logo=graphql&logoColor=white)](https://graphql.org/)
[![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=flat&logo=mongodb&logoColor=white)](https://www.mongodb.com/)

## 🚀 Features

- **GraphQL API** - Efficient data querying with Apollo Server
- **JWT Authentication** - Secure token-based user authentication  
- **Docker Compose** - Full containerized development environment
- **MongoDB** - NoSQL database with flexible schema
- **Redis** - In-memory caching for high performance
- **TypeScript** - Type-safe development
- **Actionhero.js** - Production-grade Node.js framework

## 🛠 Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Actionhero.js |
| **API** | GraphQL (Apollo Server) |
| **Database** | MongoDB |
| **Cache** | Redis |
| **Language** | TypeScript |
| **Auth** | JWT + bcrypt |
| **Container** | Docker & Docker Compose |
| **Frontend** | Flutter (Web/iOS/Android) |

## 🏗 Architecture

```
┌─────────────┐
│   Client    │
│  (Flutter)  │
└──────┬──────┘
       │ HTTP/GraphQL
       │ JWT Auth
┌──────▼──────────────────┐
│   API (Actionhero)      │
│   - GraphQL Endpoint    │
│   - JWT Validation      │
│   - Business Logic      │
│   Port: 8080            │
└──────┬────────┬─────────┘
       │        │
   ┌───▼───┐ ┌─▼─────┐
   │MongoDB│ │ Redis │
   │ Users │ │ Cache │
   │Entries│ │ Tasks │
   │:27017 │ │ :6379 │
   └───────┘ └───────┘
```

## 🎯 API Examples

### Register a New User
```bash
curl -X POST http://localhost:8080/api/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { register(email: \"user@example.com\", password: \"securepass\", name: \"John Doe\") { token user { id email name } } }"
  }'
```

### Login
```bash
curl -X POST http://localhost:8080/api/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { login(email: \"user@example.com\", password: \"securepass\") { token user { id email } } }"
  }'
```

### Create Journal Entry (Authenticated)
```bash
curl -X POST http://localhost:8080/api/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "query": "mutation { createEntry(title: \"My Day\", content: \"Today was productive!\") { id title content createdAt } }"
  }'
```

### Get My Entries
```bash
curl -X POST http://localhost:8080/api/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "query": "{ myEntries { id title content createdAt updatedAt } }"
  }'
```

## Project Structure

```
journal_inet/
├── backend/            # Actionhero.js API server
│   ├── src/
│   │   ├── actions/    # GraphQL endpoint
│   │   ├── graphql/    # Schema & resolvers
│   │   ├── models/     # User & Entry models
│   │   └── services/   # Auth & database services
│   ├── Dockerfile
│   └── package.json
├── frontend/           # Flutter mobile/web app
│   ├── lib/
│   │   ├── config/     # API configuration
│   │   ├── models/     # Data models
│   │   ├── providers/  # State management
│   │   ├── screens/    # UI screens
│   │   ├── services/   # GraphQL client
│   │   └── main.dart   # App entry point
│   └── pubspec.yaml
├── docker-compose.yml  # Orchestrates backend services
└── README.md
```

## 🚀 Quick Start - Run the Complete Stack

### Prerequisites

- **Docker Desktop** - [Download here](https://www.docker.com/products/docker-desktop/)
- **Flutter SDK** - [Install instructions](https://docs.flutter.dev/get-started/install)

### Backend Setup

1. **Set up environment variables** (optional):
   ```bash
   cp .env.example .env
   # Edit .env and set JWT_SECRET (or use default)
   ```

2. **Start backend services**:
   ```bash
   docker compose up -d
   ```

   This starts:
   - **MongoDB** (port 27017) - Database
   - **Redis** (port 6379) - Cache
   - **API** (port 8080) - GraphQL server

3. **Verify backend is running**:
   ```bash
   curl http://localhost:8080/api/status
   ```

### Frontend Setup

1. **Install Flutter dependencies**:
   ```bash
   cd frontend
   flutter pub get
   ```

2. **Run the Flutter app**:

   **For Web** (fastest for development):
   ```bash
   flutter run -d chrome
   ```

   **For iOS Simulator** (macOS only):
   ```bash
   flutter run -d "iPhone 15 Pro"
   ```

   **For Android Emulator**:
   ```bash
   flutter run
   ```

3. **Test the app**:
   - Register a new account
   - Create journal entries
   - Edit and delete entries
   - Logout and login again

### Stop Everything

```bash
# Stop backend services
docker compose down

# Stop backend and delete data
docker compose down -v
```

## Development

### Running Backend Locally (without Docker)

If you want to run just the API locally:

1. **Start MongoDB** (using Docker):
   ```bash
   docker run -d -p 27017:27017 --name mongodb mongo:7.0
   ```

2. **Run API**:
   ```bash
   cd backend
   npm install
   npm run dev
   ```

### GraphQL Testing

You can test GraphQL queries using:

- **GraphQL Playground** (if we add it)
- **curl** or **Postman**
- **Flutter app** (coming soon)

Example query:
```bash
curl -X POST http://localhost:8080/api/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "query { me { id email name } }"}'
```

## 📋 API Capabilities

### Implemented ✅

- **User Management**
  - User registration with email validation
  - Secure login with JWT token generation
  - Password hashing with bcrypt
  
- **Journal Entries**
  - Create, read, update, and delete entries
  - User-specific entry ownership
  - Timestamp tracking (created/updated)

- **GraphQL API**
  - Type-safe schema definitions
  - Authenticated queries and mutations
  - Context-based authorization

- **Infrastructure**
  - Dockerized microservices (API, MongoDB, Redis)
  - Health checks for all services
  - Volume persistence for database

### Planned 🔄

- Entry search and filtering
- Entry tags and categories
- User profile customization
- Rich text editor for entries
- Dark mode
- Entry export (PDF/JSON)

## 📚 Documentation

- **Backend API**: See [`backend/README.md`](backend/README.md) for detailed backend documentation
- **Flutter App**: See [`frontend/README.md`](frontend/README.md) for Flutter app documentation and architecture

