import { bootstrap } from './server';

// This file is your standard entrypoint for local dev or Node starts.
bootstrap().catch((err) => {
  console.error("Fatal error in index.ts:", err);
  process.exit(1);
});
