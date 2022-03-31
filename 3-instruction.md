# 指令系统

## 数据通路

8086 CPU 数据通路图示:

![datapath](assets/datapath.svg)

图中有 4 种实体，实体之间有 12 条 "可能" 的数据通路。其中 9 条实心箭头，对应 **9 条数据通路**。另有 3 条带 `X` 号的虚线箭头不是有效的数据通路。

根据数据通路定义，以下的九种 `MOV` 指令是合法的（其中 `ac` 为立即数, `reg` 为通用寄存器, `segreg` 为段寄存器, `mem` 为内存）:

    MOV reg, ac
    MOV reg, reg
    MOV reg, segreg
    MOV reg, mem
    MOV mem, ac
    MOV mem, reg
    MOV mem, segreg
    MOV segreg, reg
    MOV segreg, mem

注意: 使用段寄存器作为目的操作数时，不允许用 `CS` （修改 `CS` 只能通过段间跳转指令）。

## 段超越

采用数据的寄存器间接寻址或跳转的寄存器寻址时，寄存器中存储的都是相对于某个段的偏移量。特定寻址场景、特定寄存器对应有默认的段（隐式，一般不需要写出）:

- 数据访问: 
  - `BX`, `SI`, `DI` --> `DS`
  - `BP` --> `SS`
- 转移指令: `CS`
- 串指令的 `DI` 默认相对于 `ES`

如需改变默认相对的段，则使用段超越，即在 `[]` 前加 `段寄存器:` 以指定偏移量寄存器参考的段，例如 `SS:[BX]`, `CS:[DI]`。

## 类型转换

有时仅凭符号名/变量名很难准确知道内存操作数的类型。由于内存单元的基本单位是字节，所以无论变量如何定义，都可以进行类型转换。

通过 `BYTE PTR`, `WORD PTR`, `DWORD PTR` 三个操作符，明确地指定内存操作数的类型，或进行强制类型转换。

例如:

    MOV  BYTE PTR x, AL     ; 将 8 位的 AL 存入 x 对应的内存
    MOV  WORD PTR [DI], AX  ; 将 AX 中的一个 16 位的字存入 DI 寄存器所指向的内存地址

## 主要指令

- 传送指令

      MOV, XCHG, PUSH, POP, PUSHF, POPF
      LEA, LDS, LES

  操作符:

      OFFSET, SEG ; 获取变量符号的偏移量和段地址
      BYTE PTR, WORD PTR, DWORD PTR ; 类型转换
  
- 算术运算指令

      ADD, ADC, SUB, SBB, INC, DEC, CMP, NEG
      MUL, IMUL, CBW
      DIV, IDIV, CWD
    
- 逻辑运算指令

      AND, OR, XOR, NOT
      TEST
      SHL, SHR, SAL, SAR, ROL, ROR, RCL, RCR

- 控制转移指令

      JMP (short, near, word, far, dword)
      JA/JB/JE 系列, JG/JL/JE 系列
      LOOP, LOOPZ, LOOPNZ
      CALL (near, word, far, dword)
      RET, RETF
      INT, IRET

- 处理器控制指令

      CLC, STC, CLI, STI, CLD, STD, NOT, HLT

- 其他指令

      LODS, STOS, MOVS, CMPS, SCAS, REP ; 串处理
      IN, OUT

### 传送指令

    MOV, XCHG, PUSH, POP, PUSHF, POPF

类型转换: 打破类型匹配约定, 按照希望的类型来寻址

- `BYTE PTR`, `WORD PTR`, `DWORD PTR`

段超越: 打破操作数的段缺省约定, 转向指定的段来寻址

- `CS:`, `DS:`, `ES:`, `SS:`

#### `MOV` 指令

语法为 `MOV DST, SRC`, 必须遵守数据通路和以下规则:

- 源和目的操作数必须类型匹配（8 位对 8 位，16 位对 16 位）
- 目的操作数不能是立即数
- 源和目的操作数不能同时为内存操作数（串指令除外）
- 源和目的操作数不能通识为段寄存器

以下指令是错误的:

    MOV AX, BL  ; 将 BL 赋值给 AX, 扩展成 16 位 -- 类型不匹配
    MOV ES, DS  ; 将 ES 设成与 DS 相同 -- 源和目的不能通识为段寄存器
    MOV y x     ; 赋值 y = x -- 不能内存到内存
    MOV [DI], [SI]  ; 间接寻址, 内存变量传送 -- 不能内存到内存

类型转换: 

    MOV BYTE PTR x, AL
    MOV WORD PTR [DI] AX

`MOV` 指令的运用（也称 `MOV` 体操）:

1. 遵循寻址方式规则: 在哪里，怎么存取，access
2. 遵循数据通路规则: 可以 / 不可以
3. 注意默认段 ( `DS`, `SS` ) 和段超越
4. 类型匹配和类型转换: `DB`, `DW`, `DD` 的范围, 相互如何 access

`MOV` 指令不改标志位，只有运算指令改标志位。

#### 交换指令 `XCHG`

格式为 `XCHG OPR1, OPR2`，使两个操作数互换。不允许任何一个操作数是立即数。

示例:

    XCHG BX, [BP+SI]    ; 交换寄存器 BX 与堆栈段 SS:[BP+SI] 的操作数

#### 堆栈指令

包括 `PUSH`, `POP`, `PUSHF`, `POPF`。示例:

    PUSH SRC    ; SP=SP-2, SS:[SP]<-SRC
    PUSHF       ; SP=SP-2, SS:[SP]<-PSW
    POP DST     ; DST<-SS:[SP], SP=SP+2
    POPF        ; PSW<-SS:[SP], SP=SP+2

其中 SRC 和 DST 都可以是寄存器及内存操作数。

#### 其他传送指令

    LEA     reg, src    ; 将源操作数 src 的偏移地址送入 reg 中
    LDS     reg, src    ; 将 src 中的双字内容依次送入 reg 和 DS
    LES     reg, src    ; 将 src 中的双字内容依次送入 reg 和 ES

上述三条指令中的 reg 不能是段寄存器。

- `LEA` 指令: 获取 src 的偏移地址。
- `LDS` 和 `LES` 获取的是该单元处的双字内容，不是地址。
  - `LDS`: 将低字送入 src, 高字送入 `DS` 寄存器
  - `LES` 与 `LDS` 类似，高字使用 `ES` 寄存器
  - 使用 `LDS` 及 `LES` 时，src 处保存的双字通常是某个形如 `seg:offset` 的逻辑地址。

#### 取地址还是取内容

当变量名（使用 `DW`, `DB`, `DD` 等伪指令定义的变量）直接位于 `MOV` 等指令中时，都是**直接寻址**，得到的是变量的内容。如果需要得到该变量地址，需要使用 `LEA` 指令。

    x   DW  ?       ; 假定 x 在 DATA 段内，偏移地址为 000AH, 内容为 1234H

    MOV AX, x       ; AX = x = 1234H
    LEA BX, x       ; BX = &x = 000AH
    MOV AX, [BX]    ; AX = *BX = 1234H

`OFFSET` 和 `SEG` 操作符也可用于获取地址。

    MOV BX, OFFSET x    ; 与 LEA BX, x 相同, 获取 x 的偏移地址
    MOV AX, SEG x       ; 

#### 传送指令示例

数据段:

    X1  EQU     100
    X2  DW      1234h
    X3  DD      20005678h

内存图 ( `地址:数据` ):

    DS: 0000:   34  X2
        0001:   12
        0002:   78  X3
        0003:   56
        0004:   00
        0005:   20

指令示例:

    MOV X2, X1  ; 源: 立即寻址, 目的: 直接寻址
    MOV X3, X2  ; 错误: 数据通路不对, 类型不匹配

    ; MOV X3, X2 的正确版
    MOV AX, X2  ; 源: 直接寻址, 目的: 寄存器寻址
    MOV WORD PTR X3, AX ; 源: 寄存器寻址, 目的: 直接寻址
    ; 执行后 DS:[0002] <- 34h, DS:[0003] <- 12h
    
    ; 以下两条指令等价
    LEA BX, X3  ; 源: 直接寻址, 目的: 寄存器寻址, BX = &X3 = 0002h
    MOV BX, OFFSET X3;  OFFSET 得到的偏移地址是 16 位的立即数

#### 另一组示例

数据段:

    X1  DW  2000h
    X2  EQU 100
    X3  DB  '1' ; 31h
    X4  DD  12345678h
    X5  DD  ?

内存图 ( `地址:数据` ):

    DS: 0000:   00  X1
        0001:   20
        0002:   31  X3
        0003:   78  X4
        0004:   56
        0005:   34
        0006:   12
        0007:   ??  X5
        0008:   ??
        0009:   ??
        000A:   ??

指令示例 (将 `X4` 的值赋给 `X5`):

    LEA DI, X5              ; DI = &X5
    MOV AX, WORD PTR X4     ; 源: 直接寻址, 目的: 寄存器寻址
    MOV [DI], AX            ; 源: 寄存器寻址, 目的：寄存器间接寻址
    MOV AX, WORD PTR X4+2   ; 源: 直接寻址(不是相对寻址)
    MOV [DI+2], AX          ; 目的: 寄存器相对寻址
    ; 每次搬运一个字, 分两次完成双字的赋值

一些错误的指令:

    MOV X5, X4              ; 错误, 不能内存操作数直接赋值
    MOV [DI], WORD PTR X4   ; 错误, 内存-内存不能赋值
    MOV AX, X4              ; 错误, 类型不匹配

指令示例 (将 `X3` 的值赋给 `X5`, `X5` 高位置零):

注意 `X3` 是 `BYTE`, `X5` 是双字 `DD`。

采用直接寻址:

    ; 搬运最低位
    MOV AL, X3
    MOV BYTE PTR X5, AL     ; 目的: 直接寻址
    ; 置零高位
    XOR AL, AL              ; 清零
    MOV BYTE PTR X5+1, AL   ; *(X5+1) = 00h
    MOV BYTE PTR X5+2, AL
    MOV BYTE PTR X5+3, AL

其中置零 `X5` 的高字也可以写成

    XOR AX, AX  ; 将 AX 清零
    MOV WORD PTR X5+2, AX   ; *(WORD*)(X5+2) = 0000h

仍然是 `X3` 赋给 `X5`, 采用间接寻址:

    MOV BX, OFFSET X5   ; BX=0007h, 取地址

    MOV AL, X3          ; AL = X3
    MOV [BX], AL        ; *BX = AL
    XOR AL, AL          ; 清零 AL
    INC BX              ; BX = BX + 1 = &X3 + 1
    MOV [BX], AL        ; *BX = 0
    INC BX              ; BX = &X3 + 2
    MOV [BX], AL
    INC BX              ; BX = &X3 + 3
    MOV [BX], AL

注意: 上述代码中的 `BX` 不能换成 `BP`, 因为 `BP` 默认相对 `SS` 寻址，破坏堆栈段且 `X5` 没有改变。

### 算术运算指令

#### 加减法指令

    ADD dst, src    ; dst += src
    ADC dst, src    ; dst += src + CF (带进位加)
    INC opr         ; opr++
    SUB dst, src    ; dst -= src
    SBB dst, src    ; dst -= src - CF (带借位减)
    DEC opr         ; opr--

算术运算影响符号位:

- `ZF`: 如果运算结果为零则 `ZF=1`
- `SF`: 等于运算结果 dst 的最高位, 即符号位
- `CF`: 加法有进位或减法有借位, 则 `CF=1`
- `OF`: 若操作数符号相同且相加结果符号与操作数相反, 则 `OF=1`

加法举例

    ; 数据定义
    X   DW  ?
    Y   DW  ?
    Z   DD  ?
    
    ; 代码实现 Z = X + Y
    MOV DX, 0   ; 用 DX:AX 当被加数, 先清零 DX
    MOV AX, 0
    MOV AX, X   ; AX 做被加数的低 16 位
    ADD AX, Y   ; AX += Y, 可能产生进位 CF=1
    ADC DX, 0   ; DX += CF
    MOV WORD PTR Z, AX      ; 储存和的低字
    MOV WORD PTR Z+2, DX    ; 储存和的高字

减法举例

    ; 数据定义
    X   DD  ?
    Y   DD  ?
    Z   DD  ?
    
    ; 代码实现 Z = X - Y
    MOV DX, WORD PTR X+2    ; 用 DX:AX 作被减数, DX 作高字
    MOV AX, WORD PTR X      ; AX 作低字
    SUB AX, WORD PTR Y      ; 先进行低 16 位减法
    SBB DX, WORD PTR Y+2    ; 高 16 位借位剑法
    MOV WORD PTR Z, AX      ; 储存差的低字
    MOV WORD PTR Z+2, DX    ; 储存差的高字

#### 求补和比较

    NEG opr         ; opr = -opr
    CMP opr1, opr2  ; opr1 - opr2, 结果不送回, 只影响标志位

#### 乘除法

无符号乘 `MUL`

- 字节操作数: 8 位 x 8 位, `AX = AL * src`
- 字操作数: 16 位 x 16 位, `DX:AX = AX * src`

其中 `src` 为 8 位或 16 位的 reg 或 mem, **不能是立即数**。

无符号除法 `DIV`

- 字节操作数: `AX / src`, 商在 `AL`, 余数在 `AH`
- 字操作数: `DX:AX / src`, 商在 `AX`, 余数在 `DX`

同理，`src` 不能是立即数。

举例:

    MUL AL              ; AX = AL * AL
    MUL 10              ; 错误, src 不能为立即数
    DIV 10              ; 错误, src 不能为立即数
    MUL X1              ; X1 为 DB 或 DW 变量
    MUL [SI]            ; 错误, 虽然可用内存操作数但类型不明
    MUL BYTE PTR [SI]   ; 正确, AX = AL * op8
    MUL WORD PTR [SI]   ; 正确, DX:AX = AX * op16

举例 `Y=X*10`

    X   DW  ?
    Y   DW  ?

    MOV AX, X
    MOV BX, 10
    MUL BX      ; DX:AX = AX * BX
    MOV Y, AX   ; 只考虑低 16 位, 不考虑溢出

举例 `X=Y/10`

    X   DW  ?
    Y   DW  ?
    MOV AX, Y
    MOV BX, 10
    MOV DX, 0   ; 清零 DX, 被除数是 DX:AX
    DIV BX      ; DX:AX / BX, 商在 AX 余数在 DX
    MOV X, AX   ; 忽略余数

注意这里不能用 8 位除法，否则会溢出。

#### 逻辑运算

    AND dst, src    ; dst &= src
    OR dst, src     ; dst |= src
    XOR dst, src    ; dst ^= src
    NOT dst         ; dst = ~src

可以用这些指令实现组合/屏蔽/分离/置位，例如:

    AND AL, 0FH     ; 清零高 4 位
    AND AL, F0H     ; 清零低 4 位
    AND AL, FEH     ; 清零最低位
    OR  AL, 80H     ; 最高位置 1
    XOR AL, AL      ; 清零 AL, 等价于 MOV AL, 0 且效率更高

    OR AL,  30H     ; 将 0~9 变为 '0'~'9'
    AND AL, 0FH     ; 将 '0'~'9' 变为 0~9

#### 移位指令

    SHL dst, count  ; 逻辑左移
    SAL dst, count  ; 算术左移
    SHR dst, count  ; 逻辑右移
    SAR dst, count  ; 算术右移
    ROL dst, count  ; 循环左移
    ROR dst, count  ; 循环右移
    RCL dst, count  ; 进位循环左移
    RCR dst, count  ; 进位循环右移

注意: `count` 只能为 `1` 或 `CL`

示例 `X = X * 10`, `X = (X << 3) + (X << 1)`

    X   DW  ?

    MOV BX, X
    SHL BX, 1
    PUSH BX     ; X << 1
    SHL BX 1
    SHL BX 1    ; X << 3
    POP AX      ; AX = X << 1
    ADD AX, BX  ; AX = (X<<1) + (X<<3)
    MOV X, AX

示例 双字 `X`，`X << 4`

    X   DD  ?

    MOV AX, WORD PTR X
    MOV DX, WORD PTR X+2
    SHL AX, 1   ; 移出 CF
    RCL DX, 1   ; 移入 CF
    SHL AX, 1
    RCL DX, 1
    SHL AX, 1
    RCL DX, 1
    SHL AX, 1
    RCL DX, 1

    ; 也可以用循环实现但不如展开的效率高
    MOV CX, 4
    LP1:
    SHL AX, 1
    RCL DX, 1
    LOOP LP1


### 转移指令

#### 条件转移

- 无符号比较: `JA`/`JB`/`JE` 系列 (**A**bove / **B**elow / **E**qual)
- 有符号比较: `JG`/`JL`/`JE` 系列 (**G**reater / **L**ess / **E**qual)

指令格式: `JX 标号` ，比较的依据是**标志位**（紧跟 `CMP` 指令）。标号位于指令前面，实质是一个段内偏移值。

无符号数的条件转移指令:

- `JA` (`JNBE`): 无符号高于时转移
- `JAE` (`JNB` / `JNC`): 无符号高于等于时转移 (`CF=0` 时转移)
- `JE` (`JZ`) 等于时转移 (`ZF=1` 时转移)
- `JBE` (`JNA`): 无符号低于等于时转移
- `JB` (`JNAE` / `JC`): 无符号低于时转移 (`CF=1` 时转移)
- `JNE` (`JNZ`): 不等于时转移 (`ZF=0` 时转移)

示例 求 `Z=|X-Y|`，`X`, `Y`, `Z` 都是无符号数。

        MOV AX, X
        CMP AX, Y   ; if (AX < Y) swap AX, Y
        JAE L1      ; AX >= Y 则跳过交换
        XCHG AX, Y  ; 交换 AX 和 Y
    L1: SUB AX, Y   ; AX -= Y
        MOV Z, AX

#### 循环指令

格式: `LOOP 标号`。

`LOOP`: 先 `CX -= 1`, 当 `CX` 不为零时转移。（与循环体无关，只是个转移指令）

`JCXZ`: 当 `CX=0` 时转移（不执行 `CX -= 1`）

示例

    MOV CX, 4
    LP1:
    ......
    LOOP LP1

    MOV CX, 4
    LP2:
    DEC CX
    JCXZ LP2

#### 无条件转移指令

`JMP` 指令, 格式: `JMP 标号|寄存器操作数|内存操作数`

1. 段内直接短转移: `JMP SHORT PTR 标号`, EA 是 8 位
2. 段内直接转移: `JMP NEAR PTR 标号`
3. 段内间接转移: `JMP WORD PTR 寄存器或内存`
4. 段间直接转移: `JMP FAR PTR 标号`
5. 段间间接转移: `JMP DWORD PTR 寄存器或内存`

#### 子程序调用

- `CALL` 指令: 子程序调用
- `RET` 指令: 从子程序中返回

`CALL` 指令:

1. 段内直接调用: `CALL dst`
  - `SP=SP-2`, `SS:[SP]`: 返回地址偏移值
  - `IP=IP+dst`
2. 段内间接调用: `CALL dst`
  - `SP=SP-2`, `SS:[SP]`: 返回地址偏移值
  - `IP=*dst`
3. 段间直接调用: `CALL dst`
  - `SP=SP-2`, `SS:[SP]`: 返回地址段值
  - `SP=SP-2`, `SS:[SP]`: 返回地址偏移值
  - `IP=OFFSET dst`
  - `CS=SEG dst`
4. 段间间接调用: `CALL dst`
  - `SP=SP-2`, `SS:[SP]`: 返回地址段值
  - `SP=SP-2`, `SS:[SP]`: 返回地址偏移值
  - `IP` 为 `EA` 的低 16 位
  - `CS` 为 `EA` 的高 16 位

段内调用，`dst` 应为 `NEAR PTR`, 段间调用则为 `FAR PTR`。

示例

    CALL P1             ; 段内直接调用 P1, P1 为 NEAR
    CALL NEAR PTR P1    ; 同上
    CALL P2             ; 段间直接调用 P2, P2 为 FAR
    CALL FAR PTR P2     ; 同上
    CALL BX             ; 段内间接寻址, 过程地址位于 BX 中
    CALL [BX]           ; 段内间接地址, 过程地址位于数据段中
    CALL WORD PTR [BX]  ; 同上

`RET` 指令:

1. 段内返回: `RET`
  - `IP=[SP]`, `SP=SP+2`
2. 段内带立即数返回: `RET exp`
  - `IP=[SP]`, `SP=SP+2`
  - `SP=SP+exp`
3. 段间返回: `RET`
  - `IP=[SP]`, `SP=SP+2`
  - `CS=[SP]`, `SP=SP+2`
4. 段间带立即数返回: `RET exp`
  - `IP=[SP]`, `SP=SP+2`
  - `CS=[SP]`, `SP=SP+2`
  - `SP=SP+exp`

过程的定义

    过程名      PROC [near | far]
                过程体
                RET
    过程名      ENDP

## 应用举例

将内存中的值 x 显示为 10 进制

    MOV AX, X       ; 取 AX
    XOR DX, DX      ; DX:AX 作为被除数
    MOV BX, 10000   ; 依次除以 10000, 1000, 100, 10 显示商
    DIV BX          ; DX:AX / BX, 商在 AX, 余数在 DX
    PUSH DX         ; 保存余数
    MOV DL, AL      ; 显示的字符送 DL
    OR DL, 30H      ; 0~9 -> '0'~'9'
    MOV AH, 2       ; DOS 2 号功能调用, 显示 DL 的 ASCII 字符
    INT 21H         ; DOS 功能调用

    POP AX          ; 上次的余数作为被除数
    XOR DX, DX
    MOV BX, 1000    ; 上次 10000, 这次 1000
    DIV BX
    PUSH DX
    MOV DL, AL
    OR DL, 30H
    MOV AH, 2
    INT 21H

    POP AX
    XOR DX, DX
    MOV BX, 100     ; 1000 -> 100
    DIV BX
    PUSH DX
    MOV DL, AL
    OR DL, 30H
    MOV AH, 2
    INT 21H

    POP AX
    XOR DX, DX
    MOV BX, 10      ; 100 -> 10
    DIV BX
    PUSH DX
    MOV DL, AL
    OR DL, 30H
    MOV AH, 2
    INT 21H

    POP AX
    MOV DL, AH      ; 最后一个余数送给输出
    OR DL, 30H      ; 转成 ASCII 码
    MOV AH, 
    INT 21H

以上代码也可以写成循环（次数为 4），不如展开了效率高
