import { api, Initializer, log } from "actionhero";
import { MongoClient, Db } from "mongodb";

/**
 * MongoDB Initializer
 * 
 * This initializer connects to MongoDB when the server starts.
 * The connection is stored in Actionhero's api object so it can be
 * accessed from anywhere in your application.
 * 
 * Usage in actions:
 *   const db: Db = api.mongo.db;
 *   const entries = await db.collection('entries').find({}).toArray();
 */
export class MongoDBInitializer extends Initializer {
  constructor() {
    super();
    this.name = "mongodb";
    this.loadPriority = 100;
    this.startPriority = 200;
    this.stopPriority = 10000;
  }

  async initialize() {
    // Add mongo property to api object
    (api as any).mongo = {
      client: null as MongoClient | null,
      db: null as Db | null,
    };
  }

  async start() {
    const mongoUrl = process.env.MONGODB_URL || "mongodb://localhost:27017";
    const dbName = process.env.MONGODB_DB_NAME || "journal_db";

    log(`Connecting to MongoDB at ${mongoUrl}`, "info");

    try {
      const client = new MongoClient(mongoUrl);
      await client.connect();

      (api as any).mongo.client = client;
      (api as any).mongo.db = client.db(dbName);

      log(`Connected to MongoDB database: ${dbName}`, "info");
    } catch (error) {
      log(`Failed to connect to MongoDB: ${error}`, "error");
      throw error;
    }
  }

  async stop() {
    const client = (api as any).mongo?.client as MongoClient | null;
    if (client) {
      log("Closing MongoDB connection", "info");
      await client.close();
    }
  }
}

