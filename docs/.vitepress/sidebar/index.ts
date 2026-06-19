import { DefaultTheme } from "vitepress";
import TechnologySidebar from "./projects";
import SemiconductorSidebar from "./semiconductor";

type Sidebar = DefaultTheme.SidebarMulti

const finalSidebar: Sidebar = {
    ...TechnologySidebar,
    ...SemiconductorSidebar,
}

export default finalSidebar;