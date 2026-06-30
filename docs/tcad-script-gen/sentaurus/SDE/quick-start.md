---
outline: deep
---


# 快速开始

## 1. 安装依赖

确保项目已安装 `bun`（或 `node`）以及必要的 TypeScript 配置。

## 2. 编写脚本

```typescript
import { useSde } from "./src/sentaurus/sde/api2D";
import { position } from "./src/utils";

// 创建 SDE 脚本上下文（M = 材料类型联合, D = 掺杂剂类型联合）
const sde = useSde<"Silicon" | "Oxide", "BoronActiveConcentration" | "ArsenicActiveConcentration">();

// --- 绘图 ---
// 绘制矩形
sde.draw.rectangle({
  name: "Substrate",
  material: "Silicon",
  p0: position(0, 0),
  p1: position(10, 5),
});

// 绘制多边形
sde.draw.polygon({
  name: "Gate",
  material: "Oxide",
  positions: [position(2, 3), position(5, 1), position(8, 3)],
});

// 布尔合并
sde.draw.unite({
  positions: [position(0, 0), position(10, 5)],
  name: "ActiveRegion",
});

// --- 接触/电极 ---
sde.contact.add("Source", {
  position: position(1, 0),
  shape: "edge",
});

// --- 掺杂 ---
// 常量掺杂（按区域）
sde.dop.constant({
  name: "NWell",
  dopant: "ArsenicActiveConcentration",
  concentration: 1e18,
  kind: "region",
  region: "NWell.region",
});

// 高斯掺杂（按位置）
sde.dop.gaussian({
  name: "SourceDrain",
  dopant: "BoronActiveConcentration",
  start: position(0, 0),
  end: position(5, 0),
  peak_depth: 0.1,
  kind: "dose",
  dose: 1e15,
  std_dev: 0.05,
  polar: "Positive",
});

// --- 网格细化 ---
sde.mesh.refine({
  name: "Channel",
  dx: [0.01, 0.05],
  dy: [0.01, 0.05],
  kind: "position",
  rectangle: [position(2, 0), position(8, 2)],
});

// --- 网格偏移（界面局部加密） ---
sde.mesh.offset({
  maxlevel: 5,
  kind: "material",
  material: "Silicon",
  targets: [
    { target: "Oxide", value: 0.001, factor: 1.5 },
  ],
});

// --- 保存脚本（字符串写入文件） ---
sde.save("my_device.sde");

// --- 保存模型 & 生成网格（会在脚本末尾产生对应命令） ---
sde.draw.saveModel("my_device");
sde.mesh.buildMesh("my_device");
```

## 3. 运行生成

```bash
bun run index.ts
```

这将生成 `my_device.sde` 文件，可直接在 Sentaurus SDE 中加载执行。

