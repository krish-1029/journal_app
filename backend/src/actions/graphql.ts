import { api, Action } from "actionhero";
import { ApolloServer } from "@apollo/server";
import { typeDefs } from "../graphql/schema";
import { resolvers } from "../graphql/resolvers";
import * as jwt from "jsonwebtoken";
import { ObjectId } from "mongodb";

/**
 * GraphQL Action
 * 
 * This Action handles all GraphQL requests from the Flutter app.
 * It uses Apollo Server to process GraphQL queries and mutations.
 * 
 * How it works:
 * 1. Flutter app sends a POST request to /api/graphql with a GraphQL query/mutation
 * 2. This action receives it, extracts the JWT token (if present)
 * 3. Decodes the token to get the authenticated user
 * 4. Passes the query + user context to Apollo Server
 * 5. Apollo Server executes the resolver (which accesses MongoDB)
 * 6. Returns the result to the Flutter app
 * 
 * Example request from Flutter:
 *   POST /api/graphql
 *   Body: { "query": "query { me { id, email, name } }" }
 *   Headers: { "Authorization": "Bearer <jwt-token>" }
 */

// Create Apollo Server instance (singleton - created once, reused for all requests)
let apolloServer: ApolloServer | null = null;

async function getApolloServer(): Promise<ApolloServer> {
  if (!apolloServer) {
    apolloServer = new ApolloServer({
      typeDefs,
      resolvers,
    });
    await apolloServer.start();
  }
  return apolloServer;
}

// Helper to extract user from JWT token
async function getUserFromToken(token: string | undefined): Promise<any> {
  if (!token) {
    return null;
  }

  try {
    // Remove "Bearer " prefix if present
    const cleanToken = token.replace(/^Bearer\s+/i, "");

    // Verify and decode the JWT token
    const decoded = jwt.verify(
      cleanToken,
      process.env.JWT_SECRET || "default-secret-change-in-production"
    ) as { userId: string; email: string };

    // Fetch user from database
    const db = (api as any).mongo.db;
    const userDoc = await db.collection("users").findOne({
      _id: new ObjectId(decoded.userId),
    });

    if (!userDoc) {
      return null;
    }

    // Return user object (without password)
    return {
      id: userDoc._id.toString(),
      email: userDoc.email,
      name: userDoc.name,
      createdAt: userDoc.createdAt.toISOString(),
    };
  } catch (error) {
    // Invalid token or expired
    return null;
  }
}

export class GraphQL extends Action {
  name = "graphql";
  description = "GraphQL endpoint for queries and mutations";
  
  inputs = {
    // GraphQL requests come as JSON in the body, but Actionhero can parse them into params
    // We'll also check the raw body for proper GraphQL format
  };

  async run(data: {
    connection: any;
    params: any;
  }) {
    // GraphQL requests typically come as JSON in the request body
    // Actionhero saves raw body at connection.rawConnection.params.rawBody when saveRawBody: true
    let body: any = {};
    
    try {
      // Get the raw body (this is where Actionhero stores it)
      const rawBody = data.connection.rawConnection?.params?.rawBody;
      if (rawBody) {
        // rawBody is a Buffer, convert to string first
        const bodyString = Buffer.isBuffer(rawBody) ? rawBody.toString('utf8') : rawBody;
        body = typeof bodyString === 'string' ? JSON.parse(bodyString) : bodyString;
      } else {
        // Fall back to params if no raw body
        body = data.params;
      }
    } catch (e) {
      console.error("Failed to parse raw body:", e);
      // Fall back to params if raw body parsing fails
      body = data.params;
    }

    const { query, variables, operationName } = body || {};

    // Validate that query is provided
    if (!query) {
      return {
        errors: [
          {
            message: "GraphQL query is required",
            extensions: { code: "QUERY_MISSING" },
          },
        ],
      };
    }

    // Get Apollo Server instance
    const server = await getApolloServer();

    // Extract JWT token from Authorization header
    const authHeader = data.connection.rawConnection?.req?.headers?.authorization;
    const token = typeof authHeader === "string" ? authHeader : undefined;

    // Get authenticated user from token
    const user = await getUserFromToken(token);

    // Create GraphQL context (available in all resolvers)
    const context = { user };

    // Execute the GraphQL query/mutation
    const result = await server.executeOperation(
      {
        query,
        variables,
        operationName,
      },
      { contextValue: context }
    );

    // Return the result (Apollo Server format)
    // Apollo Server v5 uses different response structure
    if (result.body.kind === "single") {
      return {
        data: result.body.singleResult.data,
        errors: result.body.singleResult.errors,
      };
    } else {
      // Handle incremental results (unlikely for our use case)
      return {
        data: null,
        errors: [{ message: "Unexpected response format" }],
      };
    }
  }
}

