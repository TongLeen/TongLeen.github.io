import { DefaultTheme } from 'vitepress'

type NavItem = DefaultTheme.NavItem

const nav: NavItem[] = [
    { text: 'Home', link: '/' },
    {
        text: '项目实践', items: [
            { text: '机器学习', link: '/projects/machine-learning/part1.md' },
            { text: 'SoC 设计', link: '/projects/soc/' },
        ]
    },
]

export default nav;