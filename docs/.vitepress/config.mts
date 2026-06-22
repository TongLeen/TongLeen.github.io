import { defineConfig } from 'vitepress'
import katex from '@vscode/markdown-it-katex'
import attr from 'markdown-it-attrs'
// ts: ignore
import { FullSearchPlugin } from 'vitepress-plugin-fullsearch'

import nav from './nav'
import sidebar from './sidebar'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "TongLeen's NoteBook",
  description: "A notebook of messy knowledge.",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav,
    sidebar,
    socialLinks: [
      { icon: 'github', link: 'https://github.com/TongLeen/' }
    ],
    footer: {
      // message: '',
      copyright: 'tong.leen@outlook.com | Copyright © 2026 TongLeen | Apache 2.0 | 转载请注明出处'
    },
  },
  head: [
    [
      'link',
      { rel: 'stylesheet', href: 'https://cdn.jsdelivr.net/npm/jsxgraph@1.9.0/distrib/jsxgraph.css' }
    ]
  ],
  markdown: {
    config: (md) => {
      md.use((katex as any).default ?? katex)
      md.use(attr)
    },
  },
  vite: {
    plugins: [
      FullSearchPlugin()
    ],
    css: {
      preprocessorOptions: {
        scss: {
          api: 'modern-compiler',
        },
      },
    }
  }
})
