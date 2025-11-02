import { ObjectId } from "mongodb";

/**
 * User Model
 * 
 * This defines the structure of User documents in MongoDB.
 * Since we're using the native MongoDB driver (not Mongoose), we use
 * TypeScript interfaces to define our data structure.
 * 
 * This gives us:
 * - Type safety (TypeScript catches errors at compile time)
 * - Clear documentation of what data looks like
 * - Validation helpers
 */

/**
 * User document as stored in MongoDB
 * (includes _id from MongoDB and hashed password)
 */
export interface UserDocument {
  _id: ObjectId;
  email: string;
  name: string;
  password: string; // Hashed password - never return this to clients!
  createdAt: Date;
}

/**
 * User data for creating a new user
 * (excludes _id and createdAt - MongoDB generates these)
 */
export interface CreateUserInput {
  email: string;
  name: string;
  password: string; // Plain text password - will be hashed before saving
}

/**
 * User object returned to clients
 * (excludes password and MongoDB _id - uses string id instead)
 */
export interface User {
  id: string;
  email: string;
  name: string;
  createdAt: string; // ISO date string
}

/**
 * Convert MongoDB UserDocument to GraphQL User format
 * Removes sensitive fields (password) and converts _id to string id
 */
export function userDocumentToUser(doc: UserDocument): User {
  return {
    id: doc._id.toString(),
    email: doc.email,
    name: doc.name,
    createdAt: doc.createdAt.toISOString(),
  };
}

/**
 * Validate email format
 */
export function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

/**
 * Validate user input before creating a user
 */
export function validateCreateUserInput(input: CreateUserInput): {
  isValid: boolean;
  errors: string[];
} {
  const errors: string[] = [];

  // Email validation
  if (!input.email || input.email.trim().length === 0) {
    errors.push("Email is required");
  } else if (!isValidEmail(input.email)) {
    errors.push("Email format is invalid");
  }

  // Name validation
  if (!input.name || input.name.trim().length === 0) {
    errors.push("Name is required");
  } else if (input.name.trim().length < 2) {
    errors.push("Name must be at least 2 characters");
  } else if (input.name.trim().length > 100) {
    errors.push("Name must be less than 100 characters");
  }

  // Password validation
  if (!input.password || input.password.length === 0) {
    errors.push("Password is required");
  } else if (input.password.length < 6) {
    errors.push("Password must be at least 6 characters");
  } else if (input.password.length > 128) {
    errors.push("Password must be less than 128 characters");
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
}

