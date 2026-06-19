import { DefaultTheme } from 'vitepress'

type NavItem = DefaultTheme.NavItem

const nav: NavItem[] = [
    { text: 'Home', link: '/' },
    {
        text: '项目实践', items: [
            { text: 'SoC 设计', link: '/projects/soc/' },
        ]
    },
    {
        text: '半导体物理', items: [
            { text: 'GaN HEMT', link: '/semiconductor/GaN-HEMT/' },
        ]
    }
]

export default nav;