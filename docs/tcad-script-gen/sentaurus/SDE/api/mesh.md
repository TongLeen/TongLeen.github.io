---
outline: deep
---

# Mesh 模块 — `mesh`

```typescript
const { mesh } = useSde<M, D>();
```

## `refine()`

定义网格细化区域。

```typescript
// 按位置窗口细化
mesh.refine({
  name: string;
  dx: [number, number];   // [最大网格间距, 最小网格间距] (X方向)
  dy: [number, number];   // [最大网格间距, 最小网格间距] (Y方向)
  func?: RefinementFunction[];  // 可选细化函数
  kind: "position";
  rectangle: [Position, Position];  // 细化窗口
});

// 按材料细化
mesh.refine({
  name: string;
  dx: [number, number];   // [最大网格间距, 最小网格间距] (X方向)
  dy: [number, number];   // [最大网格间距, 最小网格间距] (Y方向)
  func?: RefinementFunction[];  // 可选细化函数
  kind: "material";
  material: M;            // 细化材料
});

// 按区域细化
mesh.refine({
  name: string;
  dx: [number, number];   // [最大网格间距, 最小网格间距] (X方向)
  dy: [number, number];   // [最大网格间距, 最小网格间距] (Y方向)
  func?: RefinementFunction[];  // 可选细化函数
  kind: "region";
  region: string;         // 细化区域
});
```

**RefinementFunction：**

```typescript
// 最大过渡差异（基于掺杂浓度）
{ func: "MaxTransDiff", value: number }

// use_region_names: true  — 传入区域名称（自动追加 .region 后缀）
{
  func: "MaxLenInt",
  interface: [string, string];      // 界面两侧的区域名称，无需 .region 后缀
  value: number;                    // 最大长度比
  factor: number;                   // 增长因子
  double_side?: boolean;            // 是否双侧加密
  use_region_names: true;
}

// use_region_names: false（或不传） — 传入实际材料名
{
  func: "MaxLenInt",
  interface: [M, M];                // 界面两侧的材料
  value: number;
  factor: number;
  double_side?: boolean;
  use_region_names?: false;
}
```

## `offset()`

定义界面局部网格偏移加密。

```typescript
// 按材料界面加密
mesh.offset({
  maxlevel: number;            // 最大加密级别
  kind: "material";
  material: M;
  targets: {
    target: M;                 // 目标材料
    value: number;             // 界面处局部网格尺寸
    factor: number;            // 增长因子
  }[];
});

// 按区域界面加密
mesh.offset({
  kind: "region";
  region: string;
  targets: {
    target: string;            // 目标区域
    // ...
  }[];
});
```

## `buildMesh()`

生成 `(sde:build-mesh "...")` 命令，触发网格构建。

```typescript
sde.draw.buildMesh("xxx_msh.tdr")
```
