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

`MOV` 指令:

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


