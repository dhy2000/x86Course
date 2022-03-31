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

