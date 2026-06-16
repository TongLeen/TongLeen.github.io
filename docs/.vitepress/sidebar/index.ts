import { DefaultTheme } from "vitepress";
import TechnologySidebar from "./technology";

type Sidebar = DefaultTheme.SidebarMulti

const finalSidebar: Sidebar = {
    ...TechnologySidebar,
}

export default finalSidebar;