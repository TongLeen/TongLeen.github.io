---
outline: deep
---

# 技术细节

## 工作流程

1. **调用 `useSde()`** 创建脚本上下文（内部维护命令列表 `cmds: string[]`）
2. **链式调用子模块方法** 向命令列表追加 SDE 命令字符串：
   - `sde.draw.*` — 定义几何形状和区域
   - `sde.contact.add()` — 定义电极
   - `sde.dop.constant()` / `sde.dop.gaussian()` — 定义掺杂
   - `sde.mesh.refine()` / `sde.mesh.offset()` — 定义网格细化
   - `sde.draw.saveModel()` / `sde.mesh.buildMesh()` — 输出与网格生成
3. **调用 `sde.save(filename)`** 将所有命令写入 `.sde` 文件

生成的文件由 Sentaurus SDE 读取执行。命令的顺序即代码调用的顺序。


## 类型安全与泛型

库利用 TypeScript 泛型提供编译期类型检查：

- `useSde<"Silicon" | "Oxide", "Boron" | "Arsenic">()` 限制了材料名和掺杂剂名为合法值
- `draw.rectangle({ material: "Silicon" })` 的 material 字段受泛型 `M` 约束
- `dop.constant({ dopant: "Boron", ... })` 的 dopant 字段受泛型 `D` 约束
- `dop.constant({ kind: "position" })` 会强制要求提供 `rectangle` 字段；`kind: "material"` 则要求 `material` 字段
