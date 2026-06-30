---
outline: deep
---

# Draw 模块 — `draw`

```typescript
const { draw } = useSde<M, D>();
```

## `rectangle()`

创建矩形区域。

```typescript
draw.rectangle({
  name: string,        // 区域名称（自动追加 .region 后缀）
  material: M,         // 材料类型
  p0: Position,        // 左下角坐标
  p1: Position,        // 右上角坐标
  round?: [Position, number][];  // 可选的圆角列表：[[顶点位置, 半径]]
})
```

## `polygon()`

创建多边形区域。

```typescript
draw.polygon({
  name: string,           // 区域名称
  material: M,            // 材料类型
  positions: [Position, ...Position[]];  // 顶点列表（至少3个）
  round?: [Position, number][];          // 可选的圆角列表
})
```

## `unite()`

将多个区域执行布尔合并（Union）。

```typescript
draw.unite({
  positions: [Position, ...Position[]];  // 需要合并的区域内任意点列表
  name?: string;                         // 可选，合并后为结果区域命名
})
```

## `saveModel()`

生成 `(sde:save-model "...")` 命令，保存 SDE 模型。

```typescript
draw.saveModel("xxx_des.tdr")
```

## `setOverlapBehavior()`

设置重叠区域处理行为。

```typescript
draw.setOverlapBehavior("replace" | "keep");
// "replace" → ABA（后覆盖前）
// "keep"    → BAB（保留先来）
```

## `setCoordMode()`

设置工艺坐标方向。

```typescript
draw.setCoordMode("x_down" | "y_down");
// "x_down" → x轴向下
// "y_down" → y轴向下
```