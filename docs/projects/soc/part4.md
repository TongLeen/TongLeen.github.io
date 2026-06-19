---
outline: deep
---

Part-4 硬件单元集成与速度比较
===


这一部分的代码位于 [GitHub](https://github.com/TongLeen/SoC-Course-Design/tree/main/Part4)


## 设计需求

将[Part-2](./part2.md)的硬件计算单元集成到 SoC 系统当中，让 CM0 核使用硬件计算复杂函数，并对比软硬件计算的速度。

## 设计方案

任务主要分为两步：
1. 将硬件计算单元集成到 SoC；
2. 找一种比较计算速度的方法并实现。

### 硬件计算单元的集成

这里采用最简单的集成方法：将硬件计算单元作为AHB设备挂载到AHB总线上，CM0通过总线直接访问。

对于有忙状态的设备，一般需要一个状态寄存器来显示是否可以可用，但是这里的硬件计算单元不需要。因为本设计的计算单元只需要 2 个时钟即可计算完成。原因如下：

1. 第一个周期， CM0 通过总线向计算单元写入数据时，这时第一个时钟的计算已经完成；
2. 下一个周期，CM0 一定会进行**取指操作**而非访存，因此 AHB 总线被取指过程占用，也就是说**无论如何，第二周期 CM0 不会读取计算单元的输出**，这时第二个周期计算完成，结果在第二个周期结束后给出；
3. 在第三个周期，CM0 才有可能读取计算单元的结果，也可能不读取，但可以保证，即使不判断计算状态，计算单元一定会在 CM0 读取输出之前准备好结果。

因此，硬件单元只需要三个寄存器：数据输入、数据输出以及使用的函数。

在代码层面，可以向硬件单元写入一个数据，然后立即读取结果，就像是硬件单元的计算是瞬间完成的一样。

### 计算速度的比较

因为硬件单元计算只需要几个时钟，软件计算也只需要几十个周期，相比之下串口发送和接收要上万个时钟，从 FPGA 外计算内部代码耗时的行为完全不可取。

因此这里使用了 CM0 内部的`SysTick`定时间来计时。在计算开始前，开启计时器，然后在计算结束后关闭计时器，其差值就是计算使用的时间。

为了便于计算时间的可信度，这里使用了两个手段：
1. 将单次计算时间变为 1000 次计算的时间；
2. 使用一个空函数来去除由于控制代码导致的额外时间开销。

将最终的结果通过串口输出，我们可以得到最终耗时的比较。


## 设计实现

### 硬件计算单元的AHB接口

由于不需要额外的判断逻辑，只需要将对应的信号线连上即可。AHB 总线结构自然地保证结果可以计算完成。

当有外部写入时，自动完成第一拍的计算，在下一个周期完成第二拍的计算。由于前面讨论过，CM0 核不可能在第二个周期内访问，因此这里对外的`rvalid`不需要接，只需要软件保证读一次写一次即可。

```v
// 0x00 input
// 0x04 output
// 0x08 function
module AHBlite_ACC(
        AHBlite_Slave_inf.mod_slave     bus
    );

    logic       read_en, write_en;
    always_comb begin
        read_en  = bus.HSEL & bus.HREADY & (bus.HWRITE == 1'b0);
        write_en = bus.HSEL & bus.HREADY & (bus.HWRITE == 1'b1);
    end

    logic[1:0]  func;
    always_ff @(posedge bus.HCLK) begin
        if (read_en) begin
            if (bus.HADDR == 2'b10) begin
                func <= bus.HWDATA[7:0];
            end
        end
    end

    logic       core_w_en, core_r_en;
    always_comb begin
        core_w_en = write_en & (bus.HADDR[3:2] == 2'b00);
        core_r_en = read_en & (bus.HADDR[3:2] == 2'b01);
    end
    ComplicatedFunction
        core(
            .clk(bus.HCLK),
            .rst(bus.HRESETn),
            .wdata(bus.HWDATA),
            .wfunc(func),
            .wvalid(core_w_en),
            .wready(),
            .rdata(bus.HRDATA),
            .rvalid(),
            .rready(core_r_en)
        );

    assign bus.HREADYOUT = 1'b1;
endmodule
```


### `SysTick`计时器库

使用如下代码实现了`SysTick`的访问：

```c
#ifndef __SYSTICK_H__
#define __SYSTICK_H__

typedef struct {
    unsigned int    CSR ;
    unsigned int    RVR ;
    unsigned int    CVR ;
} SysTick_TypeDef;

#define SysTick_BASE    (0xe000e000 + 0x10)
#define SysTick         ((volatile SysTick_TypeDef*)SysTick_BASE)

#endif
```

### 硬件计算单元

使用如下代码实现了硬件计算单元的访问：

```c
#ifndef __ACC_H__
#define __ACC_H__

typedef struct {
    float           wdata   ;
    float           rdata   ;
    unsigned char   mode    ;
} ACC_TypeDef;

#define ACC_BASE    0x50000000
#define ACC         ((volatile ACC_TypeDef*)ACC_BASE)

#endif
```


### 上位机

由于测试速度与原先的功能不同，这里需要重新编写上位机。

这个上位机程序将显示出多个测试用例使用的时间，并计算出纯运算过程消耗的时间。

```py
import serial
import struct

from typing import Literal, cast

type FuncName = Literal["sqrt"] | Literal["exp"] | Literal["sin"] | Literal["cos"]

Func: dict[FuncName, int] = {
    "sqrt": 0,
    "exp": 1,
    "sin": 2,
    "cos": 3,
}

def main():
    com = serial.Serial(
        port="COM8",
        baudrate=115200,
        bytesize=8,
        parity=serial.PARITY_NONE,
    )

    now_func: FuncName = "sqrt"
    while True:
        try:
            i = input(f"{now_func + " "*(5-len(now_func))}> ")
        except KeyboardInterrupt:
            break

        s = i.strip()
        if s in Func.keys():
            now_func = cast(FuncName, s)
        else:
            try:
                num = float(s)
            except ValueError as e:
                print(f"Invalid input: {e}")
                continue
            f = Func[now_func]
            d = struct.pack(">f", num)
            ds = f.to_bytes() + d
            com.write(ds)


            dr = [com.read(4) for i in range(3)]
            numr = cast(list[int], [struct.unpack(">I", i)[0] for i in dr])
            print(f"Time used summary (1000 times):")
            print(f"Dummy: {numr[0]:>7}")
            print(f"Hard : {numr[1]:>7}\t[{numr[1]-numr[0]:>7}]")
            print(f"Soft : {numr[2]:>7}\t[{numr[2]-numr[0]:>7}]")
            continue
    return

if __name__ == "__main__":
    main()
```


## 速度测试

使用以下代码测试软硬件计算的速度差距。

这里一共计时了 3 个过程：
1. 只有控制语句的空过程；
2. 使用硬件计算的过程；
3. 使用软件计算的过程。

通过将(2)(3)分别与(1)做差，即可得到纯计算消耗的时间。

```c
#include "peripherals/WaterLight.h"
#include "peripherals/Uart.h"
#include "peripherals/ACC.h"
#include "peripherals/SysTick.h"
#include "math/math.h"

unsigned char Uart_recv() {
    while(!(Uart->status & 0x10));
    return Uart->RX;
}

void Uart_send(unsigned char byte) {
    while(!(Uart->status & 0x01));
    Uart->TX = byte;
    return;
}

void Uart_sendbytes_reversed(void* bytes, unsigned int length) {
    unsigned char* ptr = (unsigned char*)bytes + length;
    unsigned int i;
    for(i = 0; i < length; i++) {
        ptr--;
        Uart_send(*ptr);
    }
}

void SysTick_start(void) {
    SysTick->RVR = 0xffffff;
    SysTick->CVR = 0;
    SysTick->CSR = 0x5;
}

unsigned int SysTick_stop(void) {
    unsigned int t = SysTick->CVR;
    SysTick->CSR = 0;
    return 0xffffff - t;
}

float cal_hard(float i, unsigned char mode) {
    ACC->mode = mode;
    ACC->wdata = i;
    return ACC->rdata;
}

float cal_soft(float i, unsigned char mode) {
    switch(mode) {
        case 0:
            return Math_sqrt(i);
        case 1:
            return Math_exp(i);
        case 2:
            return Math_sin(i);
        case 3:
            return Math_cos(i);
        default:
            return 0;
    }
}

float cal_dummy(float i, unsigned char mode) {
    return i;
}

// time test
int main() {
    unsigned char mode;
    float i;
    unsigned int t_dummy, t_hard, t_soft;

    while(1) {
        mode = Uart_recv();
        ((unsigned char*)&i)[3] = Uart_recv();
        ((unsigned char*)&i)[2] = Uart_recv();
        ((unsigned char*)&i)[1] = Uart_recv();
        ((unsigned char*)&i)[0] = Uart_recv();

        SysTick_start();
        for (int k = 0; k < 1000; k++){
            i = cal_dummy(i, mode);
        }
        t_dummy = SysTick_stop();

        SysTick_start();
        for (int k = 0; k < 1000; k++){
            i = cal_hard(i, mode);
        }
        t_hard = SysTick_stop();

        SysTick_start();
        for (int k = 0; k < 1000; k++){
            i = cal_soft(i, mode);
        }
        t_soft = SysTick_stop();

        Uart_sendbytes_reversed((void*)&t_dummy, 4);
        Uart_sendbytes_reversed((void*)&t_hard, 4);
        Uart_sendbytes_reversed((void*)&t_soft, 4);
    }
    return 0;
}
```

以下是部分结果，左侧数字是完整的计时，方框里是去除`Dummy`后的计时：

```
$ uv run .\scripts\time_test.py
sqrt > 1
Time used summary (1000 times):
Dummy:   43024
Hard :   57024  [  14000]
Soft :  181024  [ 138000]
sqrt > sin
sin  > 1
Time used summary (1000 times):
Dummy:   43024
Hard :   57024  [  14000]
Soft :  204024  [ 161000]
sin  > cos
cos  > 1
Time used summary (1000 times):
Dummy:   43024
Hard :   57024  [  14000]
Soft :  214024  [ 171000]
cos  > 0
Time used summary (1000 times):
Dummy:   43024
Hard :   57024  [  14000]
Soft :  214024  [ 171000]
cos  > 2
Time used summary (1000 times):
Dummy:   43024
Hard :   57024  [  14000]
Soft :  214024  [ 171000]
```

在去除其他代码的耗时后，硬件计算相较于软件计算速度提升了约 10 倍。

注意这里的测试代码在每次计算时都重新配置了`mode`寄存器，而在批量计算中，很有可能是使用相同的函数进行大量计算，针对这种情况，下面设计另一种测试代码，重新比较速度：

```c
int main() {
    unsigned char mode;
    float i;
    unsigned int t_dummy, t_hard, t_soft;

    while(1) {
        mode = Uart_recv();
        ((unsigned char*)&i)[3] = Uart_recv();
        ((unsigned char*)&i)[2] = Uart_recv();
        ((unsigned char*)&i)[1] = Uart_recv();
        ((unsigned char*)&i)[0] = Uart_recv();

        SysTick_start();
        for (int k = 0; k < 1000; k++){
            ;
        }
        t_dummy = SysTick_stop();

        SysTick_start();
        ACC->mode = mode;
        for (int k = 0; k < 1000; k++){
            ACC->wdata = i;
            i = ACC->rdata;
        }
        t_hard = SysTick_stop();

        SysTick_start();
        switch(mode) {
            case 0:
                for (int k = 0; k < 1000; k++){
                    i = Math_sqrt(i);
                }
                break;
            case 1:
                for (int k = 0; k < 1000; k++){
                    i = Math_exp(i);
                }
                break;
            case 2:
                for (int k = 0; k < 1000; k++){
                    i = Math_sin(i);
                }
                break;
            case 3:
                for (int k = 0; k < 1000; k++){
                    i = Math_cos(i);
                }
                break;
            default:
                return 0;
        }
        t_soft = SysTick_stop();

        Uart_sendbytes_reversed((void*)&t_dummy, 4);
        Uart_sendbytes_reversed((void*)&t_hard, 4);
        Uart_sendbytes_reversed((void*)&t_soft, 4);
    }

    return 0;
}
```

得到的结果如下：
```
$ uv run .\scripts\time_test.py
sqrt > 1
Time used summary (1000 times):
Dummy:   20024
Hard :   32030  [  12006]
Soft :  134043  [ 114019]
sqrt > sin
sin  > 0
Time used summary (1000 times):
Dummy:   20024
Hard :   32030  [  12006]
Soft :  157043  [ 137019]
sin  > cos
cos  > 1
Time used summary (1000 times):
Dummy:   20024
Hard :   32030  [  12006]
Soft :  167043  [ 147019]
cos  > exp
exp  > 0
Time used summary (1000 times):
Dummy:   20024
Hard :   32030  [  12006]
Soft :  175372  [ 155348]
```

在使用相同函数进行重复计算时，软硬件计算速度均有提高，硬件计算速度约为软件计算的10倍。
