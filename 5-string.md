# 字符串处理

## 串操作指令

### 使用方法

串操作隐含着间接寻址: `DS:[SI] --> ES:[DI]`

使用串指令的常见过程:

- 设置 `DS`, `SI` (源串), `ES`, `DI` (目的串)
  - `DS` 和 `ES` 是段寄存器，不能直接用 `MOV ES, DS` 赋值
  - 借助其他寄存器 (`MOV AX, DS`, `MOV ES, AX`) 或堆栈 (`PUSH DS`, `POP ES`)
- 设置 `DF` 标志 (Direction Flag)
  - 通过 `CLD` ( `DF=0` ) 和 `STD` ( `DF=1` ) 指令
  - `DF=0` 则每次 `SI/DI++` (或 `+=2`), `DF=1` 则每次 `SI/DI--` (或 `-=2`)
- 选用重复执行指令 `REP*` 以及设置重复次数 `CX`
  - 重复指令包括无条件重复 `REP`, 有条件重复 `REPE/REPZ`, `REPNE/REPNZ`
  - `CX` 表示最大的重复次数
  - 重复的串指令每执行一次则 `CX--`

### 指令种类

串指令种类:

- 取串指令 `LODSB` / `LODSW`
  - 将源串 `DS:[SI]` 的一个字节或字取到 `AL` 或 `AX`，同时按照 `DF` 修改 `SI` 的值。
  - `LODSB` 取字节， `LODSW` 取字
- 存串指令 `STOSB` / `STOSW`
  - 将 `AL` 中的一个字节或 `AX` 的一个字存入目的串 `ES:[DI]`，并根据 `DF` 修改 `DI`。
  - `STOSB` 存字节，`STOSW` 存字
- 串传送指令 `MOVSB` / `MOVSW`
  - 将源串 `DS:[SI]` 的字节或字传送到目的串 `ES:[DI]`，并根据 `DF` 修改 `SI` 及 `DI`。
  - `MOVSB` 传送字节，`MOVSW` 传送字
- 串比较指令 `CMPSB` / `CMPSW`
  - 比较源串 `DS:[SI]` 与目的串 `ES:[DI]` 的一个字节或字。执行完后根据 `DF` 修改 `SI` 及 `DI`。
  - 用源串的字节或字减去目的串的字节或字，影响标志寄存器 `CF`, `SF`, `ZF` 。
  - 相当于 `CMP DS:[SI], ES:[DI]`
  - 后面往往跟着条件转移指令
- 串扫描指令 `SCASB` / `SCASW`
  - 在目的串 `ES:[DI]` 中扫描是否有 `AL` 或 `AX` 指定的字节或字。执行完后根据 `DF` 修改 `SI` 及 `DI`。
  - 相当于 `CMP AL/AX, ES:[DI]`
  - 比较结果不保存，只影响标志寄存器。

重复前缀指令 `REP`:
  - 格式: `REP 串操作指令`，例如 `REP MOVSB`
  - 每执行一次串操作，`CX--`，直到 `CX` 为零时停止。

条件重复前缀指令 `REPE` / `REPZ`, `REPNE` / `REPNZ`
  - 格式与 `REP` 指令相似
  - 每执行一次，`CX--`，当 `CX` 等于零或 `ZF` 不满足条件时停止。

- `REPE` / `REPZ`: 当 `CX != 0` 且 `ZF=1` 时执行串操作并 `CX--`
- `REPNE` / `REPNZ`: 当 `CX != 0` 且 `ZF=0` 时执行串操作并 `CX--`

修改 `DF` 方向标志指令
 - `CLD`: `DF=0`，执行串操作后 `SI` 和 `DI` 增加（根据字节或字操作决定 `+1` 还是 `+2`）
 - `STD`: `DF=1`，执行串操作后 `SI` 和 `DI` 减少（根据字节或字操作决定 `-1` 还是 `-2`）

## 基本应用

- 用 `REP STOSB` 指令将长度为 `LEN` 的缓冲区 `BUFF` 清零。

      PUSH  ES              ; 修改 ES 前先保存

      PUSH  DS
      POP   ES              ; ES = DS

      MOV   DI, OFFSET BUFF ; DI = BUFF 首地址
      ; 也可以用 LEA DI, BUFF

      MOV   CX, LEN         ; CX = BUFF 长度
      CLD                   ; 设置方向为自增
      MOV   AL, 0           ; AX = 要存入的字节
      REP   STOSB           ; 重复 CX 次执行 STOSB

      POP   ES              ; 恢复 ES

    对应 C 语言:

    ```c
    memset(BUFF, 0, LEN);
    ```

- 用 `REP MOVSB` 指令将缓冲区 `BUFF1` 内容传送到 `BUFF2`, 长度为 `LEN`。

      PUSH  ES

      PUSH  DS
      POP   ES                  ; ES = DS

      MOV   SI, OFFSET BUFF1    ; LEA SI, BUFF1
      MOV   DI, OFFSET BUFF2    ; LEA DI, BUFF2

      MOV   CX, LEN             ; CX = 复制的长度
      CLD                       ; 方向自增
      REP   MOVSB

      POP   ES
    
    对应 C 语言:

    ```c
    memcpy(BUFF2, BUFF1, LEN);
    ```

- 将长度为 `LEN` 的缓冲区 `BUFF1` 中的小写字母变成大写。

      PUSH  ES

      PUSH  DS
      POP   ES                  ; ES = DS

      MOV   SI, OFFSET BUFF1    ; LEA SI, BUFF1
      MOV   DI, SI

      MOV   CX, LEN
      CLD

      LP1:
      LODSB                     ; AL <- DS:[SI], SI++
      CMP   AL, 'a'
      JB    CONTINUE
      CMP   AL, 'z'
      JA    CONTINUE
      SUB   AL, 20H             ; 小写变大写

      CONTINUE:
      STOSB                     ; ES:[DI] <- AL, SI--
      LOOP  LP1

      POP   ES
    
    对应 C 语言:

    ```c
    int CX = LEN;
    char *SI = BUFF1, *DI = *SI;
    while (cx--) {
        char AL = *SI;
        if (AL >= 'a' && AL <= 'z')
            AL -= 0x20;
        *DI = AL;
        SI++, DI++;
    }
    ```

- 比较 `STRING1` 与 `STRING2` 按字典序排序的大小，假定都是大写字母且长度都为 `LEN`。

      PUSH  ES

      PUSH  DS
      POP   ES      ; ES = DS

      MOV   SI, OFFSET STRING1
      MOV   DI, OFFSET STRING2

      MOV   CX, LEN
      CLD
      REPZ  CMPSB   
      ; while (CX != 0 && DS:[SI] == ES:[DI]) SI++, DI++, CX--;

      JZ    EQUAL   ; 两字符串相等
      JA    GREATER ; STRING1 > STRING2
      JB    LESS    ; STRING1 < STRING2

      ; 后续处理
      EQUAL:
      ; ......

      GREATER:
      ; ......

      LESS:
      ; ......

      POP   ES
    
    对应 C 语言:

    ```c
    strncmp(STRING1, STRING2, LEN);
    ```

    上述代码还可以通过 `CX` 的值判断比较操作进行了多少次，如果 `CX=0` 则比较至最后了。

- 扫描长度为 `LEN` 的串 `STRING1` 中是否含有字母 `A`

      PUSH  ES

      PUSH  DS
      POP   ES          ; ES = DS

      MOV   DI, OFFSET STRING1

      MOV   CX, LEN
      MOV   AL, 'A'
      CLD
      REPNZ SCASB
      ; while (CX != 0 && AL != ES:[DI]) CMP AL, ES:[DI] / SI++,DI++

      JZ    FOUND   ; 找到

      POP   ES
    
    `REPNZ SCASB` 停下来后，如果 `ZF=1` 则 `AL=ES:[DI]`，通过 `CX` 的值可以看出 `A` 在 `STRING1` 中的位置。如果 `ZF=0` 则已经遍历到最后仍未找到。

## 综合应用

- 在缓冲区中查找 `\r\n` (`0DH`, `0AH`) 并将其删掉（将若干行文本拼接成不换行的文本）
- 在缓冲区查找换行符 `0AH` 并将其补成回车换行 `0DH, 0AH`。