import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  base: "/jiyugaoka/",
  plugins: [tailwindcss()],
});

