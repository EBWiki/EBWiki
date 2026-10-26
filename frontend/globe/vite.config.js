import { defineConfig } from 'vite';
import cesium from 'vite-plugin-cesium';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.dirname(fileURLToPath(import.meta.url));

export default defineConfig({
  plugins: [cesium()],
  build: {
    outDir: path.resolve(root, '../../public/globe'),
    emptyOutDir: true,
    rollupOptions: {
      input: path.resolve(root, 'main.js'),
      output: {
        entryFileNames: 'globe.js',
        chunkFileNames: 'assets/[name]-[hash].js',
        assetFileNames: 'assets/[name]-[hash][extname]',
      },
    },
  },
});
