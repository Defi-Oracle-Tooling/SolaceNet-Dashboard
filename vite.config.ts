import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { nodePolyfills } from 'vite-plugin-node-polyfills';

export default defineConfig({
  plugins: [
    react(),
    nodePolyfills({
      // Whether to polyfill `node:` protocol imports.
      protocolImports: true,
      // Polyfills for specific Node.js modules
      include: ['util', 'os', 'path', 'fs', 'buffer', 'stream', 'events']
    }),
  ],
  // Optimize dependency handling
  optimizeDeps: {
    esbuildOptions: {
      // Node.js global to browser globalThis
      define: {
        global: 'globalThis',
      },
    },
  },
  build: {
    // Output sourcemaps for better debugging
    sourcemap: true,
    // More efficient chunking
    rollupOptions: {
      output: {
        manualChunks: (id) => {
          // Split Azure dependencies into a separate chunk
          if (id.includes('@azure/')) {
            return 'azure-deps';
          }
          // Split React into its own chunk
          if (id.includes('react') || id.includes('react-dom')) {
            return 'react';
          }
          // Keep monitoring/telemetry separate
          if (id.includes('winston') || id.includes('applicationinsights')) {
            return 'monitoring';
          }
        }
      }
    }
  },
  // Define environment configuration
  define: {
    // Enable the use of environment variables in the client
    // This will expose process.env as an object in the browser
    'process.env': {},
  },
});