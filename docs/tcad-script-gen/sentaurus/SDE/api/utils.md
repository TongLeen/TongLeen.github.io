---
outline: deep
---

# 工具类型与辅助

## `Position` 类

```typescript
import { Position, position } from "./utils";

// 构造器
new Position(x: number, y: number, z: number = 0);
position(x: number, y: number, z: number = 0);

// 方法
pos.shift({ x, y, z });   // 位移，返回新 Position
pos.shiftX(x);            // X方向位移，返回新 Position
pos.shiftY(y);            // Y方向位移，返回新 Position
pos.add(otherPos);         // 加法
pos.midpoint(otherPos);    // 中点

// getter
pos.sde   // 返回 SDE 兼容的字符串 "(position x y z)"
```

## `Decay` 类型

```typescript
type Decay = {
  distribute: "Erf" | "Gauss";  // 衰减分布类型
  factor: number;                // 衰减因子
}
```

## `Replace` 类型

```typescript
type Replace = "Replace" | "LocalReplace" | "NoReplace";
```

## `GaussianLateral` 类型

```typescript
type GaussianLateral = {
  dist: "Gauss" | "Erf";
  factor: number;
}
```

## `GaussianPolar` 类型

```typescript
type GaussianPolar = "Positive" | "Negative" | "Both";
```
