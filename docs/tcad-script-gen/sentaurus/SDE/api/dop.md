---
outline: deep
---

# Dop 模块 — `dop`

```typescript
const { dop } = useSde<M, D>();
```

## `constant()`

定义常量掺杂。

**按位置区域掺杂（矩形窗口）：**
```typescript
dop.constant({
  name: string;           // 掺杂名称
  dopant: D;              // 掺杂剂类型
  concentration: number;  // 掺杂浓度
  decay?: Decay;          // 边缘浓度衰减参数（可选）
  replace?: Replace;      // 替换当前位置的掺杂（可选）
  kind: "position";       // 指定为位置方式
  rectangle: [Position, Position];  // 掺杂矩形窗口
});
```

**按材料掺杂（整层材料）：**
```typescript
dop.constant({
  name: string;           // 掺杂名称
  dopant: D;              // 掺杂剂类型
  concentration: number;  // 掺杂浓度
  decay?: Decay;          // 边缘浓度衰减参数（可选）
  replace?: Replace;      // 替换当前位置的掺杂（可选）
  kind: "material";       // 指定为材料方式
  material: M;            // 材料名称
});
```

**按区域掺杂（指定区域）：**
```typescript
dop.constant({
  name: string;           // 掺杂名称
  dopant: D;              // 掺杂剂类型
  concentration: number;  // 掺杂浓度
  decay?: Decay;          // 边缘浓度衰减参数（可选）
  replace?: Replace;      // 替换当前位置的掺杂（可选）
  kind: "region";         // 指定为区域方式
  region: string;         // 区域名称（自动补充 .region 后缀）
});
```

## `gaussian()`

定义高斯掺杂分布。

```typescript
// 方式一：指定峰值浓度
dop.gaussian({
  name: string,           // 掺杂名称
  start: Position;        // 参考窗口起点
  end: Position;          // 参考窗口终点
  peak_depth: number;     // 峰值深度
  dopant: D;              // 掺杂剂类型
  polar: GaussianPolar;   // "Positive" | "Negative" | "Both"
  lateral?: GaussianLateral;   // 横向分布
  eval_at_baseline?: boolean;  // 是否在基线上应用掺杂
  replace?: Replace;           // 替换当前位置的掺杂（可选）
  kind: "conc";           // 使用峰值浓度指定
  peak_conc: number;      // 峰值浓度
  another_conc: number;   // 另一深度处的浓度
  another_depth: number;  // 另一深度
});

// 方式二：指定剂量
dop.gaussian({
  name: string,           // 掺杂名称
  start: Position;        // 参考窗口起点
  end: Position;          // 参考窗口终点
  peak_depth: number;     // 峰值深度
  dopant: D;              // 掺杂剂类型
  polar: GaussianPolar;   // "Positive" | "Negative" | "Both"
  lateral?: GaussianLateral;   // 横向分布
  eval_at_baseline?: boolean;  // 是否在基线上应用掺杂
  replace?: Replace;           // 替换当前位置的掺杂（可选）
  kind: "dose";           // 使用总剂量指定
  dose: number;           // 注入剂量
  std_dev: number;        // 标准偏差
});
```

