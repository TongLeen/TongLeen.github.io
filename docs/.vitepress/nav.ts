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
    },
    {
        text: 'TCAD 代码生成', items: [
            {
                text: 'Sentaurus', items: [
                    { text: 'SDE', link: '/tcad-script-gen/sentaurus/SDE/' }
                ]
            }
        ]
    }
]

export default nav;