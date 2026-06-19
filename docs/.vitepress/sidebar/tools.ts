import { DefaultTheme } from "vitepress"

type SidebarItems = DefaultTheme.SidebarItem

type ItemType = {
    name: string
    relative: string
}

const sidebarGenerate = (
    root: string,
    name: string,
    ...items: ItemType[]
): Record<string, SidebarItems[]> => ({
    [root]: [{
        text: name,
        items: items.map(({ name, relative }) => ({
            text: name,
            link: `${root}/${relative}`,
        }))
    }]
})

export { sidebarGenerate };