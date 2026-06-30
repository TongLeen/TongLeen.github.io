# 示例

## MOS 晶体管结构生成（简化）

```typescript
const sde = useSde<"Silicon" | "SiO2" | "PolySi", "Boron" | "Arsenic">();

// 衬底
sde.draw.rectangle({
  name: "Sub", material: "Silicon",
  p0: position(0, 0), p1: position(10, 10),
});

// 栅氧化层
sde.draw.rectangle({
  name: "Oxide", material: "SiO2",
  p0: position(2, 10), p1: position(8, 10.01),
});

// 多晶硅栅
sde.draw.rectangle({
  name: "Gate", material: "PolySi",
  p0: position(1, 10.01), p1: position(9, 10.5),
});

// 定义电极
sde.contact.add("Source", { position: position(1, 0), shape: "edge" });
sde.contact.add("Drain",  { position: position(9, 0), shape: "edge" });
sde.contact.add("Gate",   { position: position(5, 10.5), shape: "edge" });

// 沟道掺杂
sde.dop.constant({
  name: "PWell", dopant: "Boron", concentration: 1e17,
  kind: "position", rectangle: [position(0, 0), position(10, 10)],
});

// 源漏掺杂
sde.dop.gaussian({
  name: "SD", dopant: "Arsenic",
  start: position(0, 0), end: position(2, 0),
  peak_depth: 0.05, kind: "dose", dose: 1e15, std_dev: 0.02,
  polar: "Positive",
});

// 网格细化
sde.mesh.refine({
  name: "Channel",
  dx: [0.01, 0.005], dy: [0.01, 0.005],
  kind: "material", material: "Silicon",
  func: [{ func: "MaxTransDiff", value: 3 }],
});

sde.mesh.buildMesh("mos_device");

sde.save("mos_device.sde");
```


