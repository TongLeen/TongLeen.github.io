---
outline: deep
---

# Contact 模块 — `contact`

```typescript
const { contact } = useSde<M, D>();
```

## `add()`

定义电极/接触。

```typescript
contact.add(
  name: string,              // 接触名称
  ...contacts: {
    position: Position;      // 接触位置
    shape: "body" | "edge";  // 接触类型：体接触 / 边接触
    remove?: boolean;        // 是否移除对应区域的网格
  }[]
);
```

同一个接触名称可以多次调用（会在同一电极上添加多个接触点）。

