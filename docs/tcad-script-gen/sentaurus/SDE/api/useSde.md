---
outline: deep
---

# 入口函数 `useSde()`

`useSde()` 是核心工厂函数，用于创建 SDE（Sentaurus Structure Editor）命令脚本的构建器实例。它封装了命令积累、脚本输出和执行流程，提供了一种声明式、类型安全的方式来生成复杂器件结构描述。

## 函数签名
```ts
useSde<M extends string, D extends string>()
```

创建 SDE 命令构建器实例。泛型参数 `M` 和 `D` 分别是材料和掺杂剂的名称，用于为后续方法提供类型提示。

推荐使用解构返回值
```ts
type M = "Silicon" | "Oxide"
type D = "BoronActiveConcentration" | "ArsenicActiveConcentration"
const { draw, contact, dop, mesh, save, run, runAndExit } = useSde<M, D>();
```

## 返回值：一个对象，包含以下方法：


### `save()`

将当前累积的所有命令写入指定文件（覆盖写入）。使用 `Bun.write` 实现，支持相对或绝对路径。

```ts
save("output.cmd")
```

### `run()`

启动一个子进程执行 `sde -e -r` 命令，并将当前所有命令通过标准输入传递给该进程。子进程的输出（stdout/stderr）将继承自父进程（打印到终端）。返回值为子进程的退出码，`0` 表示成功。

> 一般情况使用 `runAndExit()` 而非这个函数；除非需要子进程运行结束后执行其他代码

```ts
run()
```

### `runAndExit()`

调用 `run()` 并以退出码结束当前进程（`process.exit(exitCode)`）。此方法不会返回。

```ts
runAndExit()
```

### `draw`

返回一个绘图命令构建器，用于生成图形。具体方法由 `draw` 模块导出，取决于导入的 `draw` 函数实现。

参见 [Draw 模块](./draw.md)

### `contact`

返回一个接触定义构建器，用于定义器件的电极或接触点。具体方法由 `contact` 模块导出。

参见 [Contact 模块](./contact.md)

### `dop`

返回一个掺杂命令构建器，用于设置不同区域的掺杂浓度和类型。

参见 [Dop 模块](./dop.md)

### `mesh`

返回一个网格定义构建器，用于生成或细化计算网格。

参见 [Mesh 模块](./mesh.md)

