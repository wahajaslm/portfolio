import { defineConfig } from 'astro/config';

export default defineConfig({
  integrations: [],
  srcDir: 'src',
  publicDir: 'public',
  site: 'https://wahajaslm.github.io',
  base: '/portfolio',
  markdown: {
    shikiConfig: {
      themes: {
        light: 'github-light',
        dark: 'github-dark',
      },
    },
  },
});
