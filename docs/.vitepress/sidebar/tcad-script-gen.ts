import { sidebarGenerate } from "./tools";
import { DefaultTheme } from "vitepress";

// const sidebar = {
//     ...sidebarGenerate(
//         '/tcad-script-gen/sentaurus/SDE/',
//         'Sentaurus SDE',
//         { name: '介绍', relative: 'index.md' },
//         { name: '快速开始', relative: 'quick-start.md' },
//         { name: 'API 参考', relative: 'api.md' },
//         { name: '技术细节', relative: 'details.md' },
//         { name: '示例', relative: 'examples.md' },
//     )
// }

const sidebar: DefaultTheme.Sidebar = {
    '/tcad-script-gen/sentaurus/SDE/': [{
        text: "Sentaurus SDE 脚本生成",
        items: [
            { text: '介绍', link: '/tcad-script-gen/sentaurus/SDE/index.md' },
            { text: '安装配置', link: '/tcad-script-gen/sentaurus/SDE/install.md' },
            { text: '快速开始', link: '/tcad-script-gen/sentaurus/SDE/quick-start.md' },
            {
                text: 'API 参考',
                collapsed: true,
                items: [
                    { text: 'API 总览', link: '/tcad-script-gen/sentaurus/SDE/api/' },
                    { text: 'Draw', link: '/tcad-script-gen/sentaurus/SDE/api/draw.md' },
                    { text: 'Contact', link: '/tcad-script-gen/sentaurus/SDE/api/contact.md' },
                    { text: 'Dop', link: '/tcad-script-gen/sentaurus/SDE/api/dop.md' },
                    { text: 'Mesh', link: '/tcad-script-gen/sentaurus/SDE/api/mesh.md' },
                    { text: 'Utils', link: '/tcad-script-gen/sentaurus/SDE/api/utils.md' },
                ]
            }
        ]
    }]
}

export default sidebar;