import { gql } from "graphql-tag";

/**
 * GraphQL Schema Definition
 * 
 * This file defines all the types, queries, and mutations for our Journal API.
 * 
 * GraphQL Schema Breakdown:
 * - Types: Define the shape of data (User, Entry)
 * - Queries: Operations to GET data (me, myEntries)
 * - Mutations: Operations to CHANGE data (login, register, createEntry, updateEntry, deleteEntry)
 * 
 * Think of it like TypeScript types/interfaces + REST endpoints combined into one definition.
 */

export const typeDefs = gql`
  # ========================================
  # Types - Define what our data looks like
  # ========================================
  
  type User {
    id: ID!
    email: String!
    name: String!
    createdAt: String!
  }
  
  type Entry {
    id: ID!
    userId: ID!
    title: String!
    content: String!
    createdAt: String!
    updatedAt: String!
  }
  
  # ========================================
  # Auth Response - What we return after login/register
  # ========================================
  
  type AuthPayload {
    token: String!
    user: User!
  }
  
  # ========================================
  # Queries - Getting data (like GET requests)
  # ========================================
  
  type Query {
    # Get the currently logged-in user's profile
    # Example: query { me { id, email, name } }
    me: User
    
    # Get all journal entries for the logged-in user
    # Example: query { myEntries { id, title, content, createdAt } }
    myEntries: [Entry!]!
  }
  
  # ========================================
  # Mutations - Changing data (like POST/PUT/DELETE)
  # ========================================
  
  type Mutation {
    # Register a new user
    # Example: mutation { register(email: "test@example.com", password: "secret", name: "Test User") { token, user { email } } }
    register(email: String!, password: String!, name: String!): AuthPayload!
    
    # Log in an existing user
    # Example: mutation { login(email: "test@example.com", password: "secret") { token, user { email } } }
    login(email: String!, password: String!): AuthPayload!
    
    # Create a new journal entry
    # Example: mutation { createEntry(title: "My Day", content: "Today was great...") { id, title, createdAt } }
    createEntry(title: String!, content: String!): Entry!
    
    # Update an existing journal entry
    # Example: mutation { updateEntry(id: "123", title: "Updated Title", content: "New content") { id, title, updatedAt } }
    updateEntry(id: ID!, title: String, content: String): Entry!
    
    # Delete a journal entry
    # Example: mutation { deleteEntry(id: "123") }
    deleteEntry(id: ID!): Boolean!
    
    # Change the current user's password
    # Example: mutation { changePassword(currentPassword: "old", newPassword: "new123") }
    changePassword(currentPassword: String!, newPassword: String!): Boolean!
  }
`;

