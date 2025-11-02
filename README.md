# Quick Journal - Learning Project

A full-stack journaling app built to learn modern web development frameworks.

## Tech Stack

- **Backend**: Actionhero.js (Node.js/TypeScript) with GraphQL
- **Database**: MongoDB
- **Frontend**: Flutter (coming soon)
- **Infrastructure**: Docker & Docker Compose

## Project Structure

```
journal_inet/
├── backend/          # Actionhero.js API server
├── frontend/         # Flutter mobile app (coming soon)
├── docker-compose.yml # Orchestrates API + MongoDB
└── README.md
```

## Quick Start with Docker

### Prerequisites

- Docker Desktop installed ([Download here](https://www.docker.com/products/docker-desktop/))

### Steps

1. **Set up environment variables** (optional):
   ```bash
   cp .env.example .env
   # Edit .env and set JWT_SECRET (or use default)
   ```

2. **Start everything**:
   ```bash
   docker-compose up
   ```

   This will:
   - Build the API Docker image
   - Start MongoDB container
   - Start API container
   - Connect them together

3. **Verify it's working**:
   - API: http://localhost:8080/api/status
   - GraphQL: http://localhost:8080/api/graphql

4. **Stop everything**:
   ```bash
   docker-compose down
   ```

   To also delete data:
   ```bash
   docker-compose down -v
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

## Learning Progress

- ✅ Step 1: Initialize Actionhero.js project
- ✅ Step 2: Define GraphQL schema
- ✅ Step 3: Create MongoDB models with validation
- ✅ Step 4: Set up Docker & Docker Compose
- ⏳ Step 5: Initialize Flutter project (next)
- ⏳ Step 6: Build Flutter UI screens
- ⏳ Step 7: Connect Flutter to GraphQL API
- ⏳ Step 8: End-to-end testing
- ⏳ Step 9: Documentation

## Documentation

See `backend/README.md` for detailed backend documentation.

