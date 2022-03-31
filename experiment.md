# 实验环境说明

实验环境: dosbox + MASM

## dosbox

安装 (Arch Linux):

    yay -S dosbox

启动:

    dosbox

调整窗口大小:

配置文件位于 `~/.dosbox/dosbox-0.74-3.conf`，编辑配置文件 `[sdl] `分组下的 `windowresolution` 和 `output` 字段: 
- 将 `windowresolution` 的值由 `original` 调整成希望的尺寸，格式形如 `1280x800`
- 将 `output` 字段的值由 `surface` 调整为 `opengl`

原始配置:

```configuration
[sdl]

windowresolution=original
output=surface
```

修改后配置:

```configuration
[sdl]

windowresolution=1280x800
output=opengl
```

注意: 以上解决方案适用于在 4K 显示器下窗口显示过小的问题，但调整大小后，窗口内的文字大小也随之变大。也就是暂时无法调整窗口内显示文字的行数。

## MASM

需要单独下载，套件内包括汇编器 `MASM.EXE`，链接器 `LINK.EXE`，调试器 `DEBUG.EXE`，代码编辑器 `EDIT.COM` 等。

将下载好的 MASM 工具放置在某个目录下，例如 `~/masm` (`~` 表示家目录) 。启动 dosbox 后使用 `mount` 命令挂载主机目录并切换盘符，即可在 dosbox 中使用 MASM 。

    mount c ~/masm
    c:

以上两条命令 ( `mount` 与切换盘符 ) 可以写入 dosbox 的配置文件末尾的 `[autoexec]` 分组，以便在下次启动 dosbox 时自动执行。

### 汇编器与链接器

以汇编程序 `HELLO.ASM` 为例:

- 汇编: `MASM.EXE HELLO.ASM` ，生成目标文件 `HELLO.OBJ`
  
   可选择是否生成 `.LST` 文件和 `.CRF` 文件，其中 `.LST` 文件为汇编和机器码的对应，体现了汇编语言如何翻译。

- 链接: `LINK.EXE HELLO.OBJ` ，生成可执行文件 `HELLO.EXE`

   可选择是否生成 `.MAP` 文件和 `.LIB` 文件，其中 `.MAP` 文件为内存图，含有每个段的起始地址，长度等信息。

- 执行: `HELLO.EXE`

注: 在 dosbox 中可以使用 Tab 键补全命令，例如键入 `ma` 后按 Tab 即可自动补全为 `MASM.EXE`。

### 编辑器

- 打开文件: `EDIT.COM HELLO.ASM`
- 编辑文件: 与 `nano` 或 `vim` 的 `INSERT` 模式相似，使用键盘方向键移动光标。
- 打开菜单栏: 按 `Alt` 键控制菜单栏，使用方向键移动光标选择栏目，按 `Enter` 键打开或执行；或直接按相应栏目上高亮的字母以打开或执行。

### 调试器

调试程序: `DEBUG.EXE HELLO.EXE`

常用调试命令:

- `d` 显示内存单元内容
  - 无参数则默认从 `CS:IP` 开始，连续使用则地址一直向后移动。
  - 可指定起始地址, 地址格式形如 `DS:0000` 或 `078A:0000`
- `e` 修改内存单元内容
  - 需指定起始地址，格式同 `d`
  - 每次修改一个字节，可以连续修改多个字节
- `r` 查看和修改寄存器
  - 不加参数为查看
  - 指定寄存器名为修改
- `u` 反汇编，查看机器码对应的汇编程序
  - 可以指定或不指定起始地址，规则同 `d`
  - 反汇编的结果不一定有意义（例如在数据段也可能反汇编出结果）
- `a` 修改汇编指令
  - 不指定地址默认为 `CS:IP`
  - 可指定修改的地址
  - 可以连续修改多条指令
- `t` 执行一条指令，同 Step In
- `p` 执行完子程序/循环/功能调用，同 Step Over
- `g` 执行到某个指令地址处，相当于断点
  - 不加参数则执行到结束
- `l` 装入文件
- `w` 写回文件
- `q` 退出调试器
