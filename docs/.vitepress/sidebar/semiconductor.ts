import { sidebarGenerate } from "./tools";



const sidebar = {
    ...sidebarGenerate(
        '/semiconductor/GaN-HEMT/',
        'GaN HEMT',
        { name: '介绍', relative: 'index.md' },
        { name: 'GaN/AlN/AlGaN 材料与极化效应', relative: '01-GaN-material.md' },
        { name: 'GaN AlGaN 异质结', relative: '02-GaN-HeteroJunction.md' },
    )
}

export default sidebar;