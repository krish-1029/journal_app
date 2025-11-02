# Quick Journal - Backend (Actionhero.js)

This is the backend API server for the Quick Journal learning project. It uses:
- **Actionhero.js** - Node.js API framework
- **MongoDB** - NoSQL database (native driver)
- **GraphQL** - API query language (will be set up in next step)
- **TypeScript** - Type-safe JavaScript

## What's Been Set Up So Far

### ✅ Step 1 Complete: Project Initialization

1. **Actionhero.js project structure** - Generated using Actionhero CLI
2. **MongoDB connection** - Initializer that connects to MongoDB on server start
   - Located in: `src/initializers/mongodb.ts`
   - Connection stored at `api.mongo.db` for use in actions
   - Uses environment variables: `MONGODB_URL` (default: `mongodb://localhost:27017`) and `MONGODB_DB_NAME` (default: `journal_db`)
3. **Dependencies installed**:
   - `actionhero` - Framework
   - `mongodb` - MongoDB native driver
   - `@apollo/server` - GraphQL server (modern version)
   - `graphql` - GraphQL core library
   - `jsonwebtoken` - For JWT authentication (will use in next steps)
   - `bcryptjs` - For password hashing (will use in next steps)

## Project Structure

```
backend/
├── src/
│   ├── actions/          # API endpoints (we'll add GraphQL action here)
│   ├── config/            # Actionhero configuration
│   ├── initializers/      # Code that runs on server startup
│   │   └── mongodb.ts     # MongoDB connection (✅ set up)
│   ├── servers/           # Custom servers (GraphQL server placeholder)
│   ├── tasks/             # Background jobs
│   └── server.ts          # Server entry point
├── package.json
└── README.md
```

### ✅ Step 2 Complete: GraphQL Schema & Setup

1. **GraphQL Schema** (`src/graphql/schema.ts`)
   - User type (id, email, name, createdAt)
   - Entry type (id, userId, title, content, createdAt, updatedAt)
   - AuthPayload type (for login/register responses)
   - Queries: `me` (get current user), `myEntries` (get user's entries)
   - Mutations: `register`, `login`, `createEntry`, `updateEntry`, `deleteEntry`

2. **GraphQL Resolvers** (`src/graphql/resolvers.ts`)
   - All query and mutation logic implemented
   - MongoDB integration for all operations
   - Password hashing with bcrypt
   - JWT token generation for authentication

3. **GraphQL Action** (`src/actions/graphql.ts`)
   - Apollo Server integration
   - JWT token extraction and validation
   - User context injection for resolvers
   - Route configured at `/api/graphql`

### ✅ Step 3 Complete: MongoDB Models & Validation

1. **TypeScript Interfaces** (`src/models/`)
   - `User.ts` - User document types and validation
   - `Entry.ts` - Entry document types and validation
   - Type-safe definitions for MongoDB documents
   - Conversion helpers (MongoDB → GraphQL format)

2. **Data Validation**
   - Email format validation
   - Password strength validation (min 6 characters)
   - Entry title/content length validation
   - Input sanitization (trimming whitespace)

3. **Model Helpers**
   - `userDocumentToUser()` - Converts MongoDB user to GraphQL format (removes password)
   - `entryDocumentToEntry()` - Converts MongoDB entry to GraphQL format
   - `validateCreateUserInput()` - Validates user registration
   - `validateCreateEntryInput()` - Validates entry creation
   - `validateUpdateEntryInput()` - Validates entry updates

4. **Updated Resolvers**
   - All resolvers now use the models for type safety
   - Validation applied before database operations
   - Better error messages for invalid input

### ✅ Step 4 Complete: Docker & Docker Compose Setup

1. **Dockerfile** (`backend/Dockerfile`)
   - Node.js 20 Alpine base image
   - Multi-stage build (installs all deps, builds TypeScript, then removes dev deps)
   - Optimized for caching

2. **Docker Compose** (`docker-compose.yml`)
   - MongoDB service (port 27017)
   - API service (port 8080)
   - Health checks for both services
   - Persistent data volumes
   - Environment variable configuration

3. **Development setup** (`docker-compose.dev.yml`)
   - Development-friendly configuration
   - Separate volume for dev data

4. **.dockerignore**
   - Excludes unnecessary files from Docker builds
   - Keeps images small and fast

## Next Steps

The next todo will:
- Initialize Flutter project
- Set up Flutter dependencies (GraphQL client, state management)
- Create project structure

## Running the Server

### Option 1: Docker Compose (Recommended)

```bash
# From project root
docker-compose up

# API will be available at http://localhost:8080
# MongoDB will be available at localhost:27017
```

### Option 2: Local Development (MongoDB via Docker)

```bash
# Start MongoDB in Docker
docker run -d -p 27017:27017 --name mongodb mongo:7.0

# Run API locally
cd backend
npm install
npm run dev

# The server will start on http://localhost:8080
```

### Default Endpoints:
- GET `/api/status` - Server health check
- POST `/api/graphql` - GraphQL endpoint
- MongoDB connects automatically on startup

## Environment Variables

Create a `.env` file (optional, defaults shown):

```env
MONGODB_URL=mongodb://localhost:27017
MONGODB_DB_NAME=journal_db
PORT=8080
```

## Learning Notes

### Actionhero Concepts

1. **Actions** - Like route handlers in Express. Each action handles HTTP requests.
2. **Initializers** - Code that runs when the server starts. We use one to connect to MongoDB.
3. **Config** - Configuration files in `src/config/` customize Actionhero behavior.
4. **API Object** - The `api` global object stores connections and shared state (like `api.mongo.db`).

### MongoDB Connection

The MongoDB initializer:
- Connects when the server starts
- Stores the connection at `api.mongo.db`
- Can be accessed from any action: `const db = api.mongo.db;`
- Automatically closes when the server stops

---

## GraphQL Endpoint

The GraphQL API is available at:
- **URL**: `POST http://localhost:8080/api/graphql`
- **Headers**: `Content-Type: application/json`
- **Optional Auth**: `Authorization: Bearer <jwt-token>`

### Example Queries

**Register a new user:**
```graphql
mutation {
  register(email: "test@example.com", password: "password123", name: "Test User") {
    token
    user {
      id
      email
      name
    }
  }
}
```

**Login:**
```graphql
mutation {
  login(email: "test@example.com", password: "password123") {
    token
    user {
      id
      email
    }
  }
}
```

**Get current user (requires auth token):**
```graphql
query {
  me {
    id
    email
    name
  }
}
```

**Get journal entries (requires auth token):**
```graphql
query {
  myEntries {
    id
    title
    content
    createdAt
  }
}
```

**Create entry (requires auth token):**
```graphql
mutation {
  createEntry(title: "My Day", content: "Today was great!") {
    id
    title
    createdAt
  }
}
```

---

## Models & Type Safety

Even though we're using the native MongoDB driver (not Mongoose), we've created TypeScript interfaces to provide:

- **Type Safety**: TypeScript catches errors at compile time
- **Documentation**: Clear definition of data structures
- **Validation**: Input validation before saving to database
- **Consistency**: Helper functions ensure data format is consistent

**Files:**
- `src/models/User.ts` - User types and validation
- `src/models/Entry.ts` - Entry types and validation
- `src/models/index.ts` - Central export point

---

## Docker Commands Reference

```bash
# Start services
docker-compose up

# Start in background
docker-compose up -d

# View logs
docker-compose logs -f api
docker-compose logs -f db

# Stop services
docker-compose down

# Stop and remove volumes (deletes data)
docker-compose down -v

# Rebuild after code changes
docker-compose up --build

# Check running containers
docker ps
```

---

**Status**: Step 4 of 10 complete ✅
