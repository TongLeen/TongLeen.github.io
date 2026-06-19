import { DefaultTheme } from "vitepress";
type SidebarItems = DefaultTheme.SidebarItem[]

const sidebar: Record<string, SidebarItems> = {
    '/projects/machine-learning/': [{
        text: '机器学习', items: [
            { text: 'part1', link: '/projects/machine-learning/part1.md' }
        ]
    }],
    '/projects/soc/': [{
        text: 'SoC 设计', items: [
            { text: '介绍', link: '/projects/soc/index.md' },
            { text: 'Part-1 UART 通信', link: '/projects/soc/part1.md' },
            { text: 'Part-2 函数计算的硬件实现', link: '/projects/soc/part2.md' },
            { text: 'Part-3 SoC 系统搭建', link: '/projects/soc/part3.md' },
            { text: 'Part-4 硬件单元集成与速度比较', link: '/projects/soc/part4.md' },
        ]
    }]
}

export default sidebar;