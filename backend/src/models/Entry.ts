import { ObjectId } from "mongodb";

/**
 * Entry Model
 * 
 * This defines the structure of Journal Entry documents in MongoDB.
 * 
 * Types:
 * - EntryDocument: Raw MongoDB document
 * - CreateEntryInput: Data for creating new entry
 * - UpdateEntryInput: Data for updating existing entry
 * - Entry: GraphQL format (returned to clients)
 */

/**
 * Entry document as stored in MongoDB
 */
export interface EntryDocument {
  _id: ObjectId;
  userId: string; // References User.id (string, not ObjectId)
  title: string;
  content: string;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Input for creating a new journal entry
 */
export interface CreateEntryInput {
  userId: string;
  title: string;
  content: string;
}

/**
 * Input for updating an existing journal entry
 * All fields are optional - only provided fields will be updated
 */
export interface UpdateEntryInput {
  title?: string;
  content?: string;
}

/**
 * Entry object returned to clients (GraphQL format)
 */
export interface Entry {
  id: string;
  userId: string;
  title: string;
  content: string;
  createdAt: string; // ISO date string
  updatedAt: string; // ISO date string
}

/**
 * Convert MongoDB EntryDocument to GraphQL Entry format
 */
export function entryDocumentToEntry(doc: EntryDocument): Entry {
  return {
    id: doc._id.toString(),
    userId: doc.userId,
    title: doc.title,
    content: doc.content,
    createdAt: doc.createdAt.toISOString(),
    updatedAt: doc.updatedAt.toISOString(),
  };
}

/**
 * Validate entry input when creating a new entry
 */
export function validateCreateEntryInput(input: CreateEntryInput): {
  isValid: boolean;
  errors: string[];
} {
  const errors: string[] = [];

  // UserId validation
  if (!input.userId || input.userId.trim().length === 0) {
    errors.push("User ID is required");
  }

  // Title validation
  if (!input.title || input.title.trim().length === 0) {
    errors.push("Title is required");
  } else if (input.title.trim().length > 200) {
    errors.push("Title must be less than 200 characters");
  }

  // Content validation (optional but has max length if provided)
  if (input.content && input.content.length > 50000) {
    errors.push("Content must be less than 50,000 characters");
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
}

/**
 * Validate entry input when updating an existing entry
 */
export function validateUpdateEntryInput(input: UpdateEntryInput): {
  isValid: boolean;
  errors: string[];
} {
  const errors: string[] = [];

  // If title is provided, validate it
  if (input.title !== undefined) {
    if (input.title.trim().length === 0) {
      errors.push("Title cannot be empty");
    } else if (input.title.trim().length > 200) {
      errors.push("Title must be less than 200 characters");
    }
  }

  // If content is provided, validate it
  if (input.content !== undefined && input.content.length > 50000) {
    errors.push("Content must be less than 50,000 characters");
  }

  // At least one field should be provided for update
  if (input.title === undefined && input.content === undefined) {
    errors.push("At least one field (title or content) must be provided for update");
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
}

