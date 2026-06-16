import { DefaultTheme } from "vitepress";
type SidebarItems = DefaultTheme.SidebarItem[]

const TechnologySidebar: Record<string, SidebarItems> = {
    '/technology/machine-learning/': [{
        text: '机器学习', items: [
            { text: 'part1', link: '/technology/machine-learning/part1.md' }
        ]
    }],
    '/technology/soc/': [{
        text: 'SoC 设计', items: [
            { text: '介绍', link: '/technology/soc/index.md' },
            { text: 'Part-1 UART 通信', link: '/technology/soc/part1.md' },
            { text: 'Part-2 函数计算的硬件实现', link: '/technology/soc/part2.md' },
            { text: 'Part-3 SoC 系统搭建', link: '/technology/soc/part3.md' },
            { text: 'Part-4 硬件单元集成与速度比较', link: '/technology/soc/part4.md' },
        ]
    }]
}

export default TechnologySidebar;