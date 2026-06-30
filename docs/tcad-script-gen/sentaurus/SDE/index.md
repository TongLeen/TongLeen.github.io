---
outline: deep
---

# Sentaurus SDE 脚本生成库

## 概述

本库是一个 TypeScript 编写的 **Sentaurus TCAD SDE (Structure Editor) 脚本生成器**。它通过提供类型安全的函数式 API，帮助用户以编程方式生成 SDE 命令序列，从而自动化器件结构定义、掺杂、网格划分等工作流程。

库的核心思想是：将一系列 SDE 命令收集到字符串数组中，然后一次性写入 `.sde` 脚本文件，供 Sentaurus 工具链执行。


## 项目结构

> 该项目是 `tcad-script-gen` 的一个部分\
> 项目位于 [GitHub](https://github.com/tongleen/tcad-script-gen/)

```
src/sentaurus/sde/
├── api2D/          # 二维器件结构的高级 API
│   ├── index.ts    # 入口：useSde() 工厂函数
│   ├── draw.ts     # 几何图形绘制（矩形、多边形、布尔合并、圆角）
│   ├── contact.ts  # 电极/接触定义
│   ├── dop.ts      # 掺杂定义（常量掺杂、高斯掺杂）
│   └── mesh.ts     # 网格细化控制
└── core/           # 底层命令生成函数
    ├── geo.ts      # 几何相关 SDE 命令生成
    └── dr.ts       # 掺杂与细化（Doping/Refinement）命令生成
```

## 运行环境

- 运行时：**[Bun](https://bun.sh/)**（也兼容 Node.js）
- 语言：TypeScript（严格模式）
- 输出：纯文本 `.sde` 脚本文件，由 **Synopsys Sentaurus SDE** 加载

## 对 Vibe Coding 的优势

原生 SDE 脚本是一种 Lisp 风格的 DSL（领域特定语言），具有大量括号嵌套、重复的引号字符串和手写 ID 关联。这种语法对 LLM 不够友好——生成时容易产生括号不匹配、字符串引用错误、参数顺序混淆等问题，且缺乏类型系统来约束非法输入。

本库将器件描述从 SDE 的 DSL 转换为 **TypeScript**，带来了以下优势：

- **结构化参数**：TypeScript 的对象字面量语义清晰，LLM 可以自然地生成 `{ name, material, p0, p1 }` 而非 `(sdegeo:create-rectangle (position 0 0 0) (position 10 5 0) "Silicon" "Sub.region")`，减少括号和引号层面的低级错误。
- **类型约束即提示**：泛型参数 `M`（材料名）和 `D`（掺杂剂名）以及可辨识联合 `kind` 为 LLM 提供了显式的合法值范围——模型在生成代码时能直接感知到哪些是允许的输入，而非靠猜测 SDE 命令的参数格式。
- **IDE 即时反馈**：TypeScript 的类型检查在保存瞬间即可发现参数缺失或类型错误，无需将脚本提交给 Sentaurus 运行、等待报错、再回头排查——这在"prompt → 生成 → 验证"的快速迭代循环中至关重要。
- **自动管理命名**：区域内 ID（如 `.region`、`.refine`、`.ref`、`.plc_refine` 等后缀）由库内部自动追加，LLM 只需提供有意义的 `name` 即可，避免了跨命令的手动字符串拼接和 ID 追踪。
