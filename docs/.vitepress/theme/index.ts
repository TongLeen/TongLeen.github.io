// .vitepress/theme/index.ts
import DefaultTheme from 'vitepress/theme'
// @ts-ignore
import 'katex/dist/katex.min.css'   // 引入 KaTeX 样式

export default {
    ...DefaultTheme,
}