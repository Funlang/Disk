# Disk

DOS 时代的磁盘编辑程序，1999 年用 x86 汇编写成。全屏文本界面，直接读写硬盘的
MBR、引导记录、FAT、根目录和数据区，十六进制与文本双栏编辑。

```
DISK v1.0   Copyright (c) Zhang Weidong, 1999-2000   NO:1999-0701
```

源码只有一份：`Disk.asm`，约 2900 行，未改动地保存下来。这是 Fun 语言作者
（一了 / Wisdom ZHANG）学生时代的早期作品。

---

## 中文说明

### 它是什么

在 Windows 之前、在大部分磁盘工具都还要收费的年代，用汇编直接和 BIOS 打交道
写的一个磁盘编辑器。装上 DOSBox 就能跑。

界面是一套仿 Turbo Vision 的菜单：

| 菜单 | 菜单项                                                                 |
|------|------------------------------------------------------------------------|
| File | Save Disk / Load Disk / Save CMOS / Load CMOS / Exit                    |
| View | MBR / Reserve / Boot / Fat 1st / Fat Copy / Root / Data Start / Sector / LSector |
| Edit | Edit / Save                                                            |
| Search | DIR / FileName / String / Next                                       |
| Drive | A: / B: / C: / Other Wise                                             |
| Option | Extra: 1C / Extra: 2C                                                |
| Help | How About                                                              |

- **View** 直接跳到分区表（MBR）、保留扇区、引导记录、两份 FAT、根目录、数据起始
  扇区，按物理扇区或逻辑扇区定位。
- **Edit** 在十六进制区和文本区同步编辑扇区内容，**Save** 写回磁盘。
- **Search** 支持按目录、文件名、字符串查找，Next 继续下一处。
- **Drive** 在 A: / B: / C: 之间切换，另外两个选项走扩展位置。
- 参数栏实时显示柱面 C、磁头 H、扇区 S、逻辑盘 LD、逻辑簇 LC、逻辑扇区 LS。
- File 菜单可以把整个磁盘或 CMOS 存成映像、再读回来。

### 技术实现

- 16 位实模式，两段式（`Code` / `Data`，均 `segment para`），`org 100h`。
- 底层中断：
  - `INT 10h`（BIOS 显示，19 处）画字符界面；
  - `INT 13h`（BIOS 磁盘）做原始扇区读写；
  - `INT 16h` 读键盘；
  - `INT 21h` 少量 DOS 调用。
- 分区表 / BPB 各字段自己解析（`PPPP`、`LDisk`、`PtoL`、`LtoP` 等过程），
  柱面、磁头、扇区、逻辑簇之间互相换算。
- 约 60 个过程，从 `DispPage`、`Box` 这类绘制例程，到 `GetHex`、`Disp2Hex`
  这类十六进制输入输出，再到 `Read`/`Write`/`LRead` 的扇区 I/O。

### 编译与运行

需要 MASM 或 TASM（DOS 下或 DOSBox 里）：

```bat
masm Disk.asm;
link Disk.obj;
exe2bin Disk.exe Disk.com
Disk.com
```

或者 TASM：

```bat
tasm Disk.asm
tlink /t Disk
Disk.com
```

只能跑在 16 位实模式环境（纯 DOS 或 DOSBox）。直接读写扇区，别在装了重要数据的
机器上乱按；要试就拿软盘或磁盘映像试。

### 版权

Copyright (c) Zhang Weidong, 1999-2000, All rights reserved.
源码作为历史存档公开，请自行斟酌用途。

---

## English

A disk editor for DOS, written in x86 assembly in 1999. Full-screen text UI,
reading and writing raw disk sectors: MBR, boot record, both FATs, root
directory and the data area, with side-by-side hex and text editing.

The whole thing is one file, `Disk.asm`, about 2900 lines, preserved unchanged.
An early work by the author of the Fun programming language (一了 / Wisdom ZHANG).

### What it does

A Turbo Vision-like menu bar:

| Menu | Items |
|------|-------|
| File | Save Disk / Load Disk / Save CMOS / Load CMOS / Exit |
| View | MBR / Reserve / Boot / Fat 1st / Fat Copy / Root / Data Start / Sector / LSector |
| Edit | Edit / Save |
| Search | DIR / FileName / String / Next |
| Drive | A: / B: / C: / Other Wise |
| Option | Extra: 1C / Extra: 2C |
| Help | How About |

- **View** jumps straight to the partition table (MBR), reserved sectors, boot
  record, both FAT copies, root directory and the data start, addressed by
  physical or logical sector.
- **Edit** edits a sector in a synchronized hex / text view; **Save** writes it back.
- **Search** finds by directory, filename or string; Next continues.
- **Drive** switches between A: / B: / C: plus two extras.
- A parameter bar shows cylinder C, head H, sector S, logical drive LD, logical
  cluster LC and logical sector LS in real time.
- The File menu saves the whole disk or the CMOS settings to an image and loads
  them back.

### How it is built

- 16-bit real mode, two para segments (`Code` / `Data`), `org 100h`.
- Interrupts: `INT 10h` (BIOS video, 19 calls) for the text UI; `INT 13h` (BIOS
  disk) for raw sector I/O; `INT 16h` for the keyboard; a few `INT 21h` DOS calls.
- Parses the partition table and BPB by hand (`PPPP`, `LDisk`, `PtoL`, `LtoP`
  and friends), converting between cylinder / head / sector / logical cluster.
- About 60 procedures, from drawing routines (`DispPage`, `Box`) to hex I/O
  (`GetHex`, `Disp2Hex`) to sector I/O (`Read` / `Write` / `LRead`).

### Build and run

MASM or TASM, under DOS or in DOSBox:

```bat
masm Disk.asm;
link Disk.obj;
exe2bin Disk.exe Disk.com
Disk.com
```

or

```bat
tasm Disk.asm
tlink /t Disk
Disk.com
```

It runs in 16-bit real mode only (plain DOS or DOSBox). It writes raw sectors, so
do not point it at a machine you care about; try it on a floppy or a disk image.

### License

Copyright (c) Zhang Weidong, 1999-2000, All rights reserved.
Published as a historical archive; use at your own discretion.
