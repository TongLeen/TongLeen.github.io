import { defineConfig } from 'vitepress'
import katex from '@vscode/markdown-it-katex'
import attr from 'markdown-it-attrs'

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
    ]
  },
  markdown: {
    config: (md) => {
      md.use((katex as any).default ?? katex)
      md.use(attr)
    },
  },
})
