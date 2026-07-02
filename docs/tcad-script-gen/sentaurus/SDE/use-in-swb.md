---
outline: deep
---

# 在 SWB 中使用

`tcad-script-gen` 可以在 SWB 界面集成，以替代 SDE 生成模型和网格。

这要求首先完成 [将 Bun 集成到 SWB](./install.md#将-bun-集成到-swb)

## 添加 `Bun` 工具到工作台

如果一切正常，在工具界面的底部，将会出现一个包子 Logo

![Bunjs Logo](/bun_logo.gif)

它是 `Bun` 工具，我们所有操作都将在它当中进行
> 不需要添加 `SDE` ，`Bun` 可以在内部调用 `SDE` 以实现网格生成

## 配置库的运行环境

进入到当前项目的根目录，终端输入
```sh
bun add @tongleen/tcad-script-gen
```

等待安装完成

## 编辑脚本

在 SWB 界面，编辑 `Bun` 工具的 `Command` 文件。

**这里强烈推荐使用 `vscode` 编辑，因为其自带的代码补全和类型检查可以极大提高编码速度**

比如，将以下代码复制到 `Bun` 工具的脚本。这绘制了一个硅二极管：

```ts
import { useSde, position } from "@tongleen/tcad-script-gen";

// 创建 SDE 脚本上下文（M = 材料类型联合, D = 掺杂剂类型联合）
type Material = "Silicon" | "Oxide" | "Metal"
type Dopant = "BoronActiveConcentration" | "ArsenicActiveConcentration"
const { draw, contact, dop, mesh, save, runAndExit } = useSde<Material, Dopant>();

// --- 绘图 ---
draw.setCoordMode('y_down')
draw.setOverlapBehavior('replace')
// 绘制矩形
draw.rectangle({
    name: "Substrate",
    material: "Silicon",
    p0: position(0, 0),
    p1: position(10, 5),
});

draw.rectangle({
    name: "Oxide",
    material: "Oxide",
    p0: position(0, 0),
    p1: position(10, -1),
});

draw.rectangle({
    name: "AnodeMetal",
    material: "Metal",
    p0: position(0, 0),
    p1: position(5, -1),
});

// --- 接触/电极 ---
contact.add({
    name: "Anode",
    contacts: [
        { position: position(2.5, -0.5), shape: 'body' },

    ]
});
contact.add({
    name: "Cathode",
    contacts: [
        { position: position(5, 5), shape: 'edge' },
    ]
})

// --- 掺杂 ---
// 常量掺杂（按区域）
dop.constant({
    name: "Substrate",
    dopant: "ArsenicActiveConcentration",
    concentration: 1e14,
    kind: "region",
    region: "Substrate",
});

// 高斯掺杂（按位置）
dop.gaussian({
    name: "Anode",
    dopant: "BoronActiveConcentration",
    start: position(0, 0),
    end: position(5, 0),
    peak_depth: 0.1,
    kind: "conc",
    peak_conc: 1e19,
    another_depth: 1,
    another_conc: 1e14,
    polar: "Positive",
    lateral: { dist: "Erf", factor: 0.4 },
});


// --- 网格细化 ---
mesh.refine({
    name: "Sub",
    dx: [0.01, 0.4],
    dy: [0.01, 0.4],
    kind: "position",
    rectangle: [position(0, 0), position(10, 5)],
    func: [
        { func: 'MaxTransDiff', value: 1.2 }
    ]
});

// --- 网格偏移（界面局部加密） ---
mesh.offset({
    maxlevel: 5,
    kind: "material",
    material: "Silicon",
    targets: [
        { target: "Oxide", value: 0.001, factor: 1.5 },
    ],
});

mesh.buildMesh("n@node@_msh.tdr")   // 生成 mesh 文件

save("output.txt")              // 输出 SDE 需要的脚本文件
runAndExit()                    // 启动运行并自动退出
```

## 运行

点击对应的格点，点击运行，就像其他内置的工具一样。
