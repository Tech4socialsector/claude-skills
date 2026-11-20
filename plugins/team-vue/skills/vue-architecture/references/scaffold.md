# Scaffolding a Vue Frontend in a Frappe App (frappe-ui 1.2.0)

Replace `myapp` with the app name. The UI is served at `/myapp`.
For general Vite + frappe-ui details, see the `frappe-ui` skill's SETUP.md. This file covers
the Frappe-app specifics.

## 1. Layout

```
apps/myapp/
  frontend/                 Vue project (package.json, vite.config.js, src/)
  myapp/public/frontend/    build output (generated, gitignored)
  myapp/www/myapp.html      HTML entry copied by the build (generated, gitignored)
```

Add to `apps/myapp/.gitignore`:

```
myapp/public/frontend
myapp/www/myapp.html
frontend/node_modules
```

## 2. `frontend/package.json`

```json
{
  "name": "myapp-ui",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build"
  },
  "dependencies": {
    "frappe-ui": "1.2.0",
    "vue": "^3.5.13",
    "vue-router": "^4.5.0",
    "pinia": "^3.0.0",
    "dayjs": "^1.11.13"
  },
  "devDependencies": {
    "vite": "^7.3.2",
    "@vitejs/plugin-vue": "^6.0.0",
    "tailwindcss": "^3.4.17",
    "postcss": "^8.4.49",
    "autoprefixer": "^10.4.20"
  }
}
```

Pin `frappe-ui` **exactly** (`1.2.0`, not `^1.2.0`) so every project and every machine renders
the same. Upgrade on purpose, together with the bundled `frappe-ui` skill (see its
`VERSION.md`). Use Node ≥ 20.19.

## 3. `frontend/vite.config.js`

```js
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import frappeui from 'frappe-ui/vite'
import path from 'path'

export default defineConfig({
  plugins: [
    // frontendRoute drives the dev banner and the production HTML entry
    // (../myapp/www/myapp.html). Output goes to ../myapp/public/frontend,
    // served from /assets/myapp/frontend/.
    frappeui({ frontendRoute: '/myapp' }),
    vue(),
  ],
  resolve: { alias: { '@': path.resolve(__dirname, 'src') } },
})
```

The plugin turns on the dev proxy to bench, Jinja boot data and the Frappe build config by
default. Don't override `optimizeDeps`.

## 4. `frontend/tailwind.config.js` and `postcss.config.js`

```js
// tailwind.config.js
import preset, { content } from 'frappe-ui/tailwind'

export default {
  presets: [preset],
  content: [...content, './index.html', './src/**/*.{vue,js,ts,jsx,tsx}'],
}
```

```js
// postcss.config.js
export default { plugins: { tailwindcss: {}, autoprefixer: {} } }
```

`src/style.css` contains only:

```css
@import 'frappe-ui/style.css';
```

Don't add `@tailwind` directives; the import already emits them.

## 5. `frontend/index.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My App</title>
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="/src/main.js"></script>
  </body>
</html>
```

## 6. `src/main.js` and `src/App.vue`

```js
// main.js
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { router } from './router'
import './style.css'
import App from './App.vue'

createApp(App).use(createPinia()).use(router).mount('#app')
```

```vue
<!-- App.vue — FrappeUIProvider exactly once; it renders toasts and dialog.* -->
<template>
  <FrappeUIProvider>
    <router-view />
  </FrappeUIProvider>
</template>

<script setup>
import { FrappeUIProvider } from 'frappe-ui'
</script>
```

Router: `createWebHistory('/myapp')` (see layers.md §6).

## 7. `myapp/hooks.py`

```python
website_route_rules = [
	{"from_route": "/myapp/<path:app_path>", "to_route": "myapp"},
]

# Optional: tile on the /apps screen
add_to_apps_screen = [{
	"name": "myapp",
	"logo": "/assets/myapp/images/logo.svg",
	"title": "My App",
	"route": "/myapp",
	"has_permission": "myapp.permissions.has_app_permission",
}]
```

## 8. Copy the team files
- `src/services/api.js` ← `vue-architecture/templates/api.js`
- `src/utils/notify.js` ← `vue-architecture/templates/notify.js`
- `src/components/common/*` and `src/config/statuses.js` ← `vue-common-components/templates/`

## 9. Develop and deploy

```bash
# develop (bench running)
cd apps/myapp/frontend && yarn install && yarn dev

# deploy: the build output is gitignored, so it MUST be built on every server
bench build --app myapp      # or: cd apps/myapp/frontend && yarn install && yarn build
bench --site <site> migrate
bench restart
```

If you skip the build on a server, it keeps serving the old UI or a blank page.

## 10. Sanity check
- The page renders in the Inter font on semantic surface colours.
- `<Button icon-left="lucide-plus" label="New" />` shows a plus icon. An empty square means
  Tailwind isn't scanning frappe-ui. Check `content`.
- The console is empty: no `Package subpath … not defined`, no `injection "Symbol(router)" not
  found`.
