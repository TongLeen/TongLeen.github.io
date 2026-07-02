---
outline: deep
---

# 安装配置

## 环境要求

以下是使用该库的环境要求：
- Bun >= 1.3.10
- 网络连接（下载库需要）

## 安装步骤

### 安装 Bun

安装过程可以参考 [Bun 官方](https://bun.sh/)

安装完成后，在终端输入
```sh
bun -v
```

得到
```sh
$ bun -v
1.3.12
```

即代表安装成功

### 安装库

进入到工作文件夹并安装
```sh
cd /path/to/your/workspace/         # 进入要安装的目录
bun add @tongleen/tcad-script-gen   # 安装库
```

控制台输出以下内容表示安装成功
```sh
$ bun add @tongleen/tcad-script-gen
bun add v1.3.12 

installed @tongleen/tcad-script-gen@0.1.0

1 packages installed
```

如果出现`Connot find cmd 'bun'`，是因为`PATH`变量配置配置有误，输入
```sh
echo 'export BUN_INSTALL="$HOME/.bun"' >> ~/.bashrc
echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```
再次尝试即可。

## 将 Bun 集成到 SWB

在终端输入
```sh
curl -fsSL https://blog.tongleen.art/sentaurus_bun_integrate.bash
```
