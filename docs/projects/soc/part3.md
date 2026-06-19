---
outline: deep
---

Part-3 SoC 系统搭建
===

这一部分的代码位于 [GitHub](https://github.com/TongLeen/SoC-Course-Design/tree/main/Part3)

## 设计需求

在已给出的一个 Arm Cortex-M0 软核的基础上：
1. 使用 AHBlite 总线构建起 SoC，使用访存控制流水灯；
2. 将上一次任务的函数算法移植到软件上，使用 CM0 核实现与上一次课同样的功能。


## 设计方案

本次设计同时涉及到硬件和软件两部分。

硬件部分包括 AHB 总线的构建，APB 总线的构建和 APB 桥的设计、存储设备、IO 设备的设计；
软件部分包括启动文件的编写、常用函数库编写、外设库编写、算法编写。

### 硬件设计方案

在当前设计中，搭建一个完整的 SoC，除处理器核心以外，还需要：
1. 一条 AHB 总线，CM0 核可以使用该总线访问其他设备；
2. 存储器，用于存储机器码核运行时变量；
3. IO 外设，用以完成 SoC 与外界交互。

#### AHB 总线配置

使用单主机的 AHB-lite 作为系统总线。这里将实现一个可配置的 AHB 互联模块，可以根据参数自动配置从机数量和从机地址。

#### 存储器配置

SoC 使用 2 块内存，其中以`0x00000000`为起始地址的内存存储机器码和常量(RO)，作为 ROM1，以`0x20000000`为起始的地址存储运行时可变的变量(RW)，作为 RAM1。ROM1 的大小设定为`0x00010000`，RAM1 的大小为`0x00004000`。

#### 外设配置

低速外设挂载在 APB 总线上，并使用一个 APB 桥将其连接到 AHB 上。

外设一共有两个，一个串口通信外设核一个流水灯外设，这两个外设将位于 APB 总线上。APB 桥的起始地址为`0x40000000`，这与示例设定的地址设定一致。


### 软件设计方案

#### 初始化

首先第一件事要做的，就是让 CM0 核完成最基本的初始化，然后开始执行 C 程序。

C 程序依赖的初始化只有两个：栈指针（Stack Pointer，SP）初始化和全局变量初始化。

##### 栈指针初始化

如果不使用全局变量，全局变量初始化不是必须的。那么正确初始化 SP 即可运行 C 程序，正好 CM0 给出了一个十分简单的 SP 初始化方法：位于`0x00000000`的 32bit 数即为复位后 SP 的初始值。那么只需要在启动文件里将 SP 放在正确位置即可。

除了 SP 初始值，还需要设置复位后程序计数器（Program Counter，PC）的值和中断向量表。PC初始值直接设置为入口的 Label，中断向量表先不管，因为这次实验没用到中断。

##### 全局变量初始化

完成这些后，下一件事就是初始化全局变量，这一步可以使用 C 程序完成。

这一步只需要根据各个数据段的开始地址和大小，将数据从 ROM1 复制到 RAM1 中即可，然后将对应区域清零。

此时一个完整的 C 运行环境已经初始化完成，可以调用`main()`函数进行功能的编写了。

#### 外设访问方式

使用结构体指针来完成外设的访问。

每个外设库都只是一个头文件，没有设计复杂的库函数，因此没有对应的 C 源文件。

#### 算法

由于原先硬件实现使用的查找表是 18bit 宽，这在 CPU 中不支持，这里直接使用非压缩 32bit 浮点数。

其余处理过程与[硬件实现](./part2.md#设计方案)相同。



## 设计实现


### 硬件部分

=== 接口信号的简化

这里将使用 SystemVerilog 的接口`interface`，将原先设计中的单一连线打包成一个接口，实现连线的简化。

这里完成了三个`interface`，包括主机与AHB互联的`AHBlite_Master_inf`、AHB从机与互联的`AHBlite_Slave_inf`以及APB从设备与APB桥使用的`APB_inf`。

#### 主机与AHB互联的`AHBlite_Master_inf`

```v
interface AHBlite_Master_inf;
    logic           HCLK            ;
    logic           HRESETn         ;
    logic[31:0]     HADDR           ;
    logic[ 1:0]     HTRANS          ;
    logic[ 2:0]     HBURST          ;
    logic[ 2:0]     HSIZE           ;
    logic[ 3:0]     HPROT           ;
    logic           HWRITE          ;
    logic[31:0]     HWDATA          ;
    logic[31:0]     HRDATA          ;
    logic           HREADY          ;
    logic           HRESP           ;
    modport mod_interconnect(
                output  HCLK, HRESETn,
                input   HADDR, HTRANS, HBURST, HSIZE, HPROT, HWRITE, HWDATA,
                output  HRDATA, HREADY, HRESP
            );
    modport mod_master(
                input   HCLK, HRESETn,
                output  HADDR, HTRANS, HBURST, HSIZE, HPROT, HWRITE, HWDATA,
                input   HRDATA, HREADY, HRESP
            );
endinterface
```
#### AHB 从机与互联的`AHBlite_Slave_inf`

```v
interface AHBlite_Slave_inf;
    logic           HCLK         ;
    logic           HRESETn      ;
    logic           HSEL         ;
    logic[31:0]     HADDR        ;
    logic[ 1:0]     HTRANS       ;
    logic[ 2:0]     HBURST       ;
    logic[ 2:0]     HSIZE        ;
    logic[ 3:0]     HPROT        ;
    logic           HWRITE       ;
    logic[31:0]     HWDATA       ;
    logic           HREADY       ;
    logic           HREADYOUT    ;
    logic[31:0]     HRDATA       ;
    logic           HRESP        ;

    modport mod_interconnect(
                output  HCLK, HRESETn,
                output  HSEL, HADDR, HTRANS, HBURST, HSIZE, HPROT, HWRITE,
                output  HWDATA, HREADY,
                input   HREADYOUT, HRDATA, HRESP
            );
    modport mod_slave(
                input   HCLK, HRESETn,
                input   HSEL, HADDR, HTRANS, HBURST, HSIZE, HPROT, HWRITE,
                input   HWDATA, HREADY,
                output  HREADYOUT, HRDATA, HRESP
            );
endinterface
```
#### APB 从机信号`APB_inf`

这里的 APB 实现的 APB3，这个版本的 APB 没有`PSTRB`信号，因此只能进行 32bit 寄存器访问，不支持字节和半字访问。

```v
interface APB_inf;
    logic       PCLK;
    logic       PRESETn;
    logic[31:0] PADDR;
    logic       PSEL;
    logic       PENABLE;
    logic       PWRITE;
    logic[31:0] PWDATA;
    logic[31:0] PRDATA;
    logic       PREADY;
    logic       PSLVERR;

    modport mod_bridge(
                output  PCLK, PRESETn,
                output  PADDR, PSEL, PENABLE, PWRITE, PWDATA,
                input   PRDATA, PREADY, PSLVERR
            );
    modport mod_slave(
                input   PCLK, PRESETn,
                input   PADDR, PSEL, PENABLE, PWRITE, PWDATA,
                output  PRDATA, PREADY, PSLVERR
            );
endinterface
```


#### 编写参数化的 AHB 互联

这里将使用`interface`数组配合`generate`实现参数可配置从机数量，实现参数配置从机的起始地址和地址范围。

具体实现代码见附录，这里展示 AHB 桥实例化的方法。

```v
AHBlite_Master_inf master_inf();
AHBlite_Slave_inf  slave_inf[0:2]();
AHBlite_Interconnect
    #(
        .number_of_slaves(3),
        .slave_addr(
            '{
                '{base: 32'h0000_0000, mask: 32'hffff_0000},
                '{base: 32'h2000_0000, mask: 32'hffff_c000},
                '{base: 32'h4000_0000, mask: 32'hffff_0000}
            })
    )
    u_AHBlite_Interconnect(
        .HCLK(clk),
        .HRESETn(AHB_reset_n),
        .master(master_inf),
        .slaves(slave_inf)
    );
```
给出从机的数量`number_of_slaves`，然后再`slave_addr`中给出每个从机地址的起始和对应地址的掩码，即可完成 AHB 互联的配置。

#### APB桥的设计

APB 协议要求第一个时钟周期`T0`同时给出地址、数据、片选以及读写信号，在第二个周期`T1`给出传输使能信号，然后在`T1`末尾从机采样数据，在第三个周期`T2`输出数据/写入数据。

这个时序相比 AHB 而言，不支持流水线传输，不可在`T1`变更数据。利用 APB 与 AHB 时序的特点，设计如下的 APB 桥：
1. 当 AHB 上向 APB 从机发起访问时，首先传输地址。在第一个周期`T0`末尾，APB 桥代替 APB 从机锁存地址、读写信号，并产生`PSEL` 信号给对应从机；
2. 在第二个周期`T1`开始时，主机给出写数据（如果是写操作），此时 APB 桥给从机`PENABLE`信号，表示地址与数据均准备好，从机在`T1`末尾采样写入的数据；
3. 从机在第三个周期`T2`开始时给出读数据（如果是读操作），APB 桥根据地址选择对应从机的`PRDATA`、`PSLVERR`信号返回给 AHB 主机。

可以这样设计的原因是：APB 要求地址和数据同时放在总线上，并且保持至少 2 个周期，那么在 AHB 访问 APB 桥时，当`T0`结束时，地址被所存，主机数据放入`HWDATA`，这时可以让`HWDATA`直连`PWDATA`，那么对于从机来说，地址信号和数据信号都是同一个时钟到来，而且当前时钟从机不会采样，在下一个周期采样，因此数据和地址保持了 2 个周期，满足 APB 协议的时序。

这里有一点要注意，为了保持`T2`内`PWDATA`上内容不变，APB桥 必须在`T1`时间内输出`HREADYOUT=0`来反压主机，这样访问一次APB 从机要至少划花费 3 个周期。

APB 桥的设计与 AHB 互联一样，支持同样的可变数量的从机配置。除此之外，考虑到 APB 桥可能只占用一部分地址空间，因此在参数中可以设置 APB 桥对应空间的位宽，这实现了从设备无需配置完整的 32bit 地址，仅需要配置当前外设位于当前 APB 内地址的偏移量即可。

#### APB 外设的设计

低速外设将被挂在 APB 桥上，通过 APB 桥接入 AHB 总线，实现与处理器的信息交互。

##### UART 外设
这里使用的 UART 依旧是之前使用的 UART 模块。

由于设计之初就考虑了状态与握手，这里只需要简单地将握手信号连接到状态寄存器，即可完成外设状态寄存器的设计。

其余译码结构只需要将对于数据写入或从模块读取，实现很简单，这里不再赘述。

##### 流水灯外设

流水灯是示例代码中的流水灯模块，由于示例中使用的是AHBlite总线访问，这里将其改造成了APB接口，以便于直接挂载到APB总线上。


### 软件实现

#### 启动文件

启动文件中配置复位地址，复位 SP，以及使用 B 指令跳转到 C 函数即可。

```asm
                PRESERVE8
                THUMB

                AREA    RESET, DATA, READONLY
                EXPORT  __Vectors
__Vectors       DCD     0x20004000                ; Top of Stack
                DCD     Reset_Handler             ; Reset Handler
                DCD     0                         ; NMI Handler
                DCD     0                         ; Hard Fault Handler
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; SVCall Handler
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; PendSV Handler
                DCD     0                         ; SysTick Handler
                DCD     0                         ; IRQ0 Handler

                AREA    |.text|, CODE, READONLY

Reset_Handler   PROC
                GLOBAL  Reset_Handler
                ENTRY
                IMPORT  __init
                BL      __init
                IMPORT  main
                BL      main
                B       .
                ENDP
                END
```

#### C 程序的全局变量初始化

在上面的启动文件中，在进入`main`函数之前，首先进入了`__init`函数。

这是一个初始化内存的函数，功能就是将 ROM1 中的全局变量初始化的值拷贝到 RAM1 中，并清零没有初始化的全局变量。

其实现如下

```c
extern unsigned int Image$$RW_IRAM1$$Base;
extern unsigned int Image$$RW_IRAM1$$Length;
extern unsigned int Load$$RW_IRAM1$$Base;
extern unsigned int Image$$RW_IRAM1$$ZI$$Base;
extern unsigned int Image$$RW_IRAM1$$ZI$$Length;

void __init() {
    memoryCopy(
        (void*)&Image$$RW_IRAM1$$Base,
        (void*)&Load$$RW_IRAM1$$Base,
        (unsigned int)&Image$$RW_IRAM1$$Length
    );
    memorySet(
        (void*)&Image$$RW_IRAM1$$ZI$$Base,
        (unsigned int)&Image$$RW_IRAM1$$ZI$$Length,
        0x00
    );
}

void memoryCopy(void* dst, void* src, unsigned int size) {
    unsigned int i
    unsigned char* dst_u8 = (unsigned char*) dst;
    unsigned char* src_u8 = (unsigned char*) src;
    for(i = 0; i < size; i++) {
        *dst_u8 = *src_u8;
        dst_u8++;
        src_u8++;
    }
}

void memorySet(void* dst, unsigned int size, unsigned char value) {
    unsigned int i;
    unsigned char* dst_u8 = (unsigned char*) dst;
    for(i = 0; i < size; i++) {
        *dst_u8 = value;
        dst_u8++;
    }
}
```

#### 外设库的实现

直接用地址访问难免显得不优雅，这里使用结构体指针的方式完成了 UART 和流水灯控制。

##### UART 外设库

串口外设库如下

```c
#ifndef __UART_H__
#define __UART_H__

// 0x00     RX
// 0x04     TX
// 0x08     status [7:5] reserved [4]rx_valid [3:1] reserved [0] tx_ready
typedef struct {
    unsigned char   RX;
    unsigned char   __dummy_0;
    unsigned short  __dummy_1;
    unsigned char   TX;
    unsigned char   __dummy_2;
    unsigned short  __dummy_3;
    unsigned char   status;
    unsigned char   __dummy_4;
    unsigned short  __dummy_5;
} Uart_TypeDef;

#define Uart_BASE   0x40000010
#define Uart        ((volatile Uart_TypeDef*)Uart_BASE)

#endif
```

当使用串口发送数据，使用
```c
Uart->TX = byte;
```
即可将`byte`中的数据写入寄存器。


##### 流水灯外设库

```c
#ifndef __WATERLIGHT_H__
#define __WATERLIGHT_H__

typedef struct {
    unsigned char   mode;
    unsigned char   __dummy_0;
    unsigned short  __dummy_1;
    unsigned int    speed;
} WaterLight_TypeDef;

#define WaterLight_Base     0x40000000
#define WaterLight          ((volatile WaterLight_TypeDef*)WaterLight_Base)

#endif
```


#### 主函数

在主函数中编写逻辑，实现接收5字节后启动运算，在输出4字节。实现代码如下

```c
unsigned char Uart_recv() {
    while(!(Uart->status & 0x10));
    return Uart->RX;
}
void Uart_send(unsigned char byte) {
    while(!(Uart->status & 0x01));
    Uart->TX = byte;
    return;
}

int main() {
    unsigned char mode;
    float i;

    while(1) {
        mode = Uart_recv();

        ((unsigned char*)&i)[3] = Uart_recv();
        ((unsigned char*)&i)[2] = Uart_recv();
        ((unsigned char*)&i)[1] = Uart_recv();
        ((unsigned char*)&i)[0] = Uart_recv();

        switch(mode) {
            case 0: i = Math_sqrt(i);   break;
            case 1: i = Math_exp(i);    break;
            case 2: i = Math_sin(i);    break;
            case 3: i = Math_cos(i);    break;
            default: i = 0;             break;
        }
        Uart_send(((unsigned char*)&i)[3]);
        Uart_send(((unsigned char*)&i)[2]);
        Uart_send(((unsigned char*)&i)[1]);
        Uart_send(((unsigned char*)&i)[0]);
    }
    return 0;
}
```

