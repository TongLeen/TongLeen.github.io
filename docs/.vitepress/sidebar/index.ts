import { DefaultTheme } from "vitepress";
import TechnologySidebar from "./projects";

type Sidebar = DefaultTheme.SidebarMulti

const finalSidebar: Sidebar = {
    ...TechnologySidebar,
}

export default finalSidebar;