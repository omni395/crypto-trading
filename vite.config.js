import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  plugins: [
    RubyPlugin(),
    vue(), // добавлен плагин для поддержки .vue файлов
  ],
  build: {
    rollupOptions: {
      input: {
        application: 'app/frontend/entrypoints/application.js',
        vue_app: 'app/frontend/entrypoints/vue_app.js',
      },
    },
  },
})
