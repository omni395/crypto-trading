import { defineConfig } from "vite";
import RubyPlugin from "vite-plugin-ruby";
import vue from "@vitejs/plugin-vue";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  plugins: [
    RubyPlugin(),
    tailwindcss(),
    vue(),
  ],
  build: { sourcemap: false },
});