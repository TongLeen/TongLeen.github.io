import { sidebarGenerate } from "./tools";


const sidebar = {
    ...sidebarGenerate(
        '/projects/soc/',
        'SoC 设计',
        { name: '介绍', relative: 'index.md' },
        { name: 'Part-1 UART 通信', relative: 'part1.md' },
        { name: 'Part-2 函数计算的硬件实现', relative: 'part2.md' },
        { name: 'Part-3 SoC 系统搭建', relative: 'part3.md' },
        { name: 'Part-4 硬件单元集成与速度比较', relative: 'part4.md' },
    )
}

export default sidebar;