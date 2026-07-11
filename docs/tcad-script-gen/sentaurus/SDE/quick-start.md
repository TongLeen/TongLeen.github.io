---
outline: deep
---

# 快速开始

确保项目已安装 `Bun` 以及 `@tongleen/tcad-script-gen` 库。

## 编写脚本

将以下内容保存到文件：e.g. `str_gen.ts`

```typescript
import { useSde, position } from "@tongleen/tcad-script-gen";

// 创建 SDE 脚本上下文（M = 材料类型联合, D = 掺杂剂类型联合）
type Material = "Silicon" | "Oxide" | "Metal"
type Dopant = "BoronActiveConcentration" | "ArsenicActiveConcentration"
const { draw, contact, dop, mesh, save } = useSde<Material, Dopant>();

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

draw.saveModel("xxx_bnd.tdr")   // 生成 boundary 文件

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
    dx: [0.01, 0.1],
    dy: [0.01, 0.1],
    kind: "position",
    rectangle: [position(0, 0), position(10, 5)],
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

mesh.buildMesh("xxx_msh.tdr")   // 生成 mesh 文件

save("output.cmd")              // 输出 SDE 需要的脚本文件
```

## 运行生成

```bash
bun run str_gen.ts
```

这将生成 `output.cmd` 文件，可直接在 Sentaurus SDE 中加载执行。

## 使用 Agent Skill

现已发布针对该库的 Agent Skill：[发布页](https://skillhub.cn/skills/tcad-script-gen)

