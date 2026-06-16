import { DefaultTheme } from 'vitepress'

type NavItem = DefaultTheme.NavItem

const nav: NavItem[] = [
    { text: 'Home', link: '/' },
    {
        text: '技术', items: [
            { text: '机器学习', link: '/technology/machine-learning/part1.md' },
            { text: 'SoC 设计', link: '/technology/soc/' },
        ]
    },
]

export default nav;