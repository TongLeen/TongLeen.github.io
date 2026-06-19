import { sidebarGenerate } from "./tools";



const sidebar = {
    ...sidebarGenerate(
        '/semiconductor/GaN-HEMT/',
        'GaN HEMT',
        { name: '介绍', relative: 'index.md' },
    )
}

export default sidebar;