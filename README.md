# Actions Test

测试一下使用 GitHub Actions 在线运行汇编程序并得到运行结果。

本示例中被运行的汇编程序为 `ADD32.ASM`，输入两个 32 位十进制整数（以换行符或空格隔开均可），分别以十进制和十六进制输出两数相加的算式。

测试用例位于 `testcases` 目录下，文件名格式为 `test*.in`。

## 自动测试流程

Actions 脚本位于 `.github/workflows/autorun.yml`。

- 安装 `dosbox`
  - `dosbox` 软件自带 GUI，为了在纯命令行环境下运行，需安装 `xvfb` 以模拟一个 X11 Server.
- 下载并解压 `masm`
  - 下载链接位于 Actions 环境变量 `MASM_DOWNLOAD_URL` 中
  - 解压路径位于 `~/masm/Bin`
- 将汇编代码和测试用例拷贝到测试目录
  - 测试目录为 `~/masm/program`
  - 汇编代码统一命名为 `PROG.ASM`
  - 测试用例放置在和汇编程序同一路径下
  - 所有文件名使用 `tr` 命令统一转为大写，与 DOS 一致
  - `MASM.EXE` 和 `LINK.EXE` 运行时需通过 stdin 指定输出文件名，这里将输入内容准备到文件
    - `MASM.TXT`: 汇编器 `MASM.EXE` 的输入，共 3 行（文件尾有空行），每行依次为 OBJ, LST, CRF 。

      ```
      PROG.OBJ
      PROG.LST
      

      ```

    - `LINK.TXT`: 链接器 `LINK.EXE` 的输入，共 3 行（文件尾有空行），每行依次为 EXE, MAP, LIB 。
    
      ```
      PROG.EXE
      PROG.MAP


      ```
- 建立 Dosbox 自动运行批处理
  - 初次安装 Dosbox 后首先用 `-printconf` 参数运行一次，建立配置文件并获取其路径（位于 `~/.dosbox` 中）
  - 向配置文件末尾写入自动运行的命令，包括
    - 挂载测试目录到虚拟 `c` 盘
    - 将 masm 添加到 `PATH`
    - 切换到虚拟 `c` 盘下的代码目录
    - 运行汇编器和链接器
    - 依次运行所有测试用例
    - 退出 Dosbox
- 运行 Dosbox
  - 需使用 `xvfb-run` 命令来模拟 X Server
  - 用 `timeout` 命令限制运行时间
- 显示及上传运行结果

## 注意事项 (踩坑记录)

- Dosbox 刚安装时是没有默认配置文件的，需要首次运行才能有
  - 用 `-printconf` 参数运行，生成配置文件并输出其绝对路径
- 在纯命令行环境下运行 Dosbox
  - 参考 [此解决方案](https://stackoverflow.com/questions/834723/a-dev-null-equivilent-for-display-when-the-display-is-just-noise) 安装并使用 `xvfb` 模拟一个无图形界面的 X Server
- 在 Actions 中安装软件包
  - 在脚本中应使用 `apt-get` 而不是 `apt` 命令 [参考此回答](https://askubuntu.com/questions/990823/apt-gives-unstable-cli-interface-warning)
- 注意测试目录下的文件名大小写
  - Linux 文件系统区分大小写，但 Dos 中文件名全部为大写
  - 在 Linux 中使用 `tr` 命令转换大小写
  - 测试目录中的所有文件名均采用大写，与 Dos 一致
- 测试程序、测试用例文件名不能超过 8 个字符