import { ObjectId, Db } from "mongodb";
import * as bcrypt from "bcryptjs";
import * as jwt from "jsonwebtoken";
import { api } from "actionhero";
import {
  CreateUserInput,
  UserDocument,
  userDocumentToUser,
  validateCreateUserInput,
  validatePassword,
} from "../models/User";
import {
  CreateEntryInput,
  UpdateEntryInput,
  EntryDocument,
  entryDocumentToEntry,
  validateCreateEntryInput,
  validateUpdateEntryInput,
} from "../models/Entry";

/**
 * GraphQL Resolvers
 * 
 * Resolvers are functions that actually execute the queries and mutations.
 * Think of them as the "controller" functions - they contain the business logic.
 * 
 * Structure:
 * - Query resolvers: Fetch data from MongoDB
 * - Mutation resolvers: Create/update/delete data in MongoDB
 * 
 * Each resolver receives:
 * - parent: The parent object (usually null for root queries/mutations)
 * - args: The arguments passed to the query/mutation (like { email, password })
 * - context: Contains the authenticated user (from JWT token)
 */

// Helper function to get authenticated user from context
function getAuthenticatedUser(context: any) {
  if (!context.user) {
    throw new Error("Not authenticated. Please log in first.");
  }
  return context.user;
}

// Helper function to get MongoDB database
function getDb(): Db {
  return (api as any).mongo.db;
}

/**
 * QUERY RESOLVERS
 * These fetch data (like GET requests)
 */
export const resolvers = {
  Query: {
    // Get the current user's profile
    // Called when client sends: query { me { id, email, name } }
    me: async (_parent: any, _args: any, context: any) => {
      // context.user is set by our authentication middleware (we'll add that later)
      const user = getAuthenticatedUser(context);
      
      // Return the user from context (we'll populate it from the JWT token)
      return user;
    },

    // Get all journal entries for the logged-in user
    // Called when client sends: query { myEntries { id, title, content } }
    myEntries: async (_parent: any, _args: any, context: any) => {
      const user = getAuthenticatedUser(context);
      const db = getDb();

      // Find all entries where userId matches the logged-in user
      const entries = await db
        .collection("entries")
        .find({ userId: user.id })
        .sort({ createdAt: -1 }) // Most recent first
        .toArray();

      // Convert MongoDB documents to GraphQL Entry format using our model helper
      return entries.map((entry) => entryDocumentToEntry(entry as EntryDocument));
    },
  },

  /**
   * MUTATION RESOLVERS
   * These change data (like POST/PUT/DELETE requests)
   */
  Mutation: {
    // Register a new user
    // Called when client sends: mutation { register(email: "...", password: "...", name: "...") { token, user { email } } }
    register: async (
      _parent: any,
      args: { email: string; password: string; name: string },
      _context: any
    ) => {
      const db = getDb();
      
      // Create input object and validate it
      const input: CreateUserInput = {
        email: args.email.trim(),
        name: args.name.trim(),
        password: args.password,
      };

      const validation = validateCreateUserInput(input);
      if (!validation.isValid) {
        throw new Error(validation.errors.join(", "));
      }

      // Check if user already exists
      const existingUser = await db.collection("users").findOne({ email: input.email });
      if (existingUser) {
        throw new Error("User with this email already exists");
      }

      // Hash the password (never store plain text passwords!)
      const hashedPassword = await bcrypt.hash(input.password, 10);

      // Create new user document
      const newUser: Omit<UserDocument, "_id"> = {
        email: input.email,
        name: input.name,
        password: hashedPassword,
        createdAt: new Date(),
      };

      // Insert into MongoDB
      const result = await db.collection("users").insertOne(newUser);
      const userDoc = await db.collection("users").findOne({ _id: result.insertedId }) as UserDocument | null;
      
      if (!userDoc) {
        throw new Error("Failed to create user");
      }

      // Convert to GraphQL User format (removes password)
      const user = userDocumentToUser(userDoc);
      const userId = user.id;

      // Generate JWT token (we'll use JWT_SECRET from environment)
      const token = jwt.sign(
        { userId, email: user.email },
        process.env.JWT_SECRET || "default-secret-change-in-production",
        {
          expiresIn: "7d", // Token valid for 7 days
        }
      );

      return {
        token,
        user,
      };
    },

    // Log in an existing user
    // Called when client sends: mutation { login(email: "...", password: "...") { token, user { email } } }
    login: async (
      _parent: any,
      args: { email: string; password: string },
      _context: any
    ) => {
      const db = getDb();
      const { email, password } = args;

      // Find user by email
      const userDoc = (await db.collection("users").findOne({ email })) as UserDocument | null;
      if (!userDoc) {
        throw new Error("Invalid email or password");
      }

      // Verify password
      const isValidPassword = await bcrypt.compare(password, userDoc.password);
      if (!isValidPassword) {
        throw new Error("Invalid email or password");
      }

      // Convert to GraphQL User format (removes password)
      const user = userDocumentToUser(userDoc);

      // Generate JWT token
      const token = jwt.sign(
        { userId: user.id, email },
        process.env.JWT_SECRET || "default-secret-change-in-production",
        {
          expiresIn: "7d",
        }
      );

      return {
        token,
        user,
      };
    },

    // Create a new journal entry
    // Called when client sends: mutation { createEntry(title: "...", content: "...") { id, title, createdAt } }
    createEntry: async (
      _parent: any,
      args: { title: string; content: string },
      context: any
    ) => {
      const user = getAuthenticatedUser(context);
      const db = getDb();

      // Create input object and validate it
      const input: CreateEntryInput = {
        userId: user.id,
        title: args.title.trim(),
        content: args.content || "",
      };

      const validation = validateCreateEntryInput(input);
      if (!validation.isValid) {
        throw new Error(validation.errors.join(", "));
      }

      // Create new entry document
      const newEntry: Omit<EntryDocument, "_id"> = {
        userId: input.userId,
        title: input.title,
        content: input.content,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      // Insert into MongoDB
      const result = await db.collection("entries").insertOne(newEntry);
      
      // Fetch the created entry to return it
      const entryDoc = (await db.collection("entries").findOne({ _id: result.insertedId })) as EntryDocument | null;
      
      if (!entryDoc) {
        throw new Error("Failed to create entry");
      }

      // Convert to GraphQL Entry format
      return entryDocumentToEntry(entryDoc);
    },

    // Update an existing journal entry
    // Called when client sends: mutation { updateEntry(id: "123", title: "...", content: "...") { id, title, updatedAt } }
    updateEntry: async (
      _parent: any,
      args: { id: string; title?: string; content?: string },
      context: any
    ) => {
      const user = getAuthenticatedUser(context);
      const db = getDb();

      // Create input object and validate it
      const input: UpdateEntryInput = {};
      if (args.title !== undefined) input.title = args.title.trim();
      if (args.content !== undefined) input.content = args.content;

      const validation = validateUpdateEntryInput(input);
      if (!validation.isValid) {
        throw new Error(validation.errors.join(", "));
      }

      // Convert string ID to MongoDB ObjectId
      const entryId = new ObjectId(args.id);

      // Find the entry and verify it belongs to the user
      const entry = (await db.collection("entries").findOne({
        _id: entryId,
        userId: user.id,
      })) as EntryDocument | null;

      if (!entry) {
        throw new Error("Entry not found or you don't have permission to update it");
      }

      // Prepare update object (only update fields that are provided)
      const updateData: Partial<EntryDocument> = { updatedAt: new Date() };
      if (input.title !== undefined) updateData.title = input.title;
      if (input.content !== undefined) updateData.content = input.content;

      // Update the entry
      await db.collection("entries").updateOne(
        { _id: entryId },
        { $set: updateData }
      );

      // Fetch the updated entry
      const updatedEntry = (await db.collection("entries").findOne({ _id: entryId })) as EntryDocument | null;

      if (!updatedEntry) {
        throw new Error("Failed to update entry");
      }

      // Convert to GraphQL Entry format
      return entryDocumentToEntry(updatedEntry);
    },

    // Delete a journal entry
    // Called when client sends: mutation { deleteEntry(id: "123") }
    deleteEntry: async (
      _parent: any,
      args: { id: string },
      context: any
    ) => {
      const user = getAuthenticatedUser(context);
      const db = getDb();
      const { id } = args;

      // Convert string ID to MongoDB ObjectId
      const entryId = new ObjectId(id);

      // Find the entry and verify it belongs to the user
      const entry = (await db.collection("entries").findOne({
        _id: entryId,
        userId: user.id,
      })) as EntryDocument | null;

      if (!entry) {
        throw new Error("Entry not found or you don't have permission to delete it");
      }

      // Delete the entry
      await db.collection("entries").deleteOne({ _id: entryId });

      return true;
    },

    // Change user's password
    // Called when client sends: mutation { changePassword(currentPassword: "...", newPassword: "...") }
    changePassword: async (
      _parent: any,
      args: { currentPassword: string; newPassword: string },
      context: any
    ) => {
      const user = getAuthenticatedUser(context);
      const db = getDb();
      const { currentPassword, newPassword } = args;

      // Validate new password
      const validation = validatePassword(newPassword);
      if (!validation.isValid) {
        throw new Error(validation.errors.join(", "));
      }

      // Check that new password is different from current
      if (currentPassword === newPassword) {
        throw new Error("New password must be different from current password");
      }

      // Get the user document with password from database
      const userDoc = (await db.collection("users").findOne({
        _id: new ObjectId(user.id),
      })) as UserDocument | null;

      if (!userDoc) {
        throw new Error("User not found");
      }

      // Verify current password
      const isValidPassword = await bcrypt.compare(
        currentPassword,
        userDoc.password
      );
      if (!isValidPassword) {
        throw new Error("Current password is incorrect");
      }

      // Hash the new password
      const hashedPassword = await bcrypt.hash(newPassword, 10);

      // Update the password in database
      await db.collection("users").updateOne(
        { _id: new ObjectId(user.id) },
        { $set: { password: hashedPassword } }
      );

      return true;
    },
  },
};

