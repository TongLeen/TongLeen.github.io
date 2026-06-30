import { DefaultTheme } from "vitepress";
import TechnologySidebar from "./projects";
import SemiconductorSidebar from "./semiconductor";
import tcad from './tcad-script-gen';

type Sidebar = DefaultTheme.SidebarMulti

const finalSidebar: Sidebar = {
    ...TechnologySidebar,
    ...SemiconductorSidebar,
    ...tcad,
}

export default finalSidebar;