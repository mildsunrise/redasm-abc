# Robust, Easy [Dis-]Assembler for ActionScript Bytecode

Did you know **[RABCDAsm](https://github.com/CyberShadow/RABCDAsm)**, the robust ActionScript (dis)assembler?  
**redasm-abc** aims to provide a simple, easy-to-use assistant to it.

Forget about the export-disassemble-edit-assemble-replace process;
note the difference:

#### Pure RABCDAsm

```bash
$ abcexport file.swf
$ rabcdasm file-0.abc
$ rabcdasm file-1.abc
$ rabcdasm file-2.abc
$ # edit what you want...
$ rabcasm file-0/file-0.main.asasm
$ rabcasm file-1/file-1.main.asasm
$ rabcasm file-2/file-2.main.asasm
$ abcreplace file.swf 0 file-0/file-0.main.abc
$ abcreplace file.swf 1 file-0/file-1.main.abc
$ abcreplace file.swf 2 file-0/file-2.main.abc
```

#### redasm-abc

```bash
$ redasm
$ # edit what you want...
$ redasm
```


## Installation

You need a working [D compiler](http://dlang.org) to build redasm-abc.
It's recommended you install liblzma and its development files, otherwise
redasm won't be able to handle LZMA-compressed SWFs.

To build:

```bash
$ git submodule update --init
$ rdmd build_redasm.d
```

If it succeeds, copy the resulting executable to your PATH:

```bash
$ sudo install redasm /usr/local/bin
```

That's it! Now you should be able to do `redasm` from anywhere.


## Usage

Put the SWF you want to inspect in an empty directory.  
Then run `redasm` to extract all its ABC blocks and disassemble them.  
Edit what you want, then run `redasm` again to apply the changes to the SWF.

redasm-abc will create a directory for each disassembled ABC block (`block-0`, `block-1`,
`block-2`) where its dissassembly lives. You shouldn't rename the directories or modify
the SWF externally.


## Tips

Just after running `redasm` on an SWF, you should immediately add the files to i.e. Git,
even if you're just planning to read the assembly.

``` bash
redasm
git init && git add -A
git commit -m "disassemble SWF"
```

Also read the [tips on RABCDAsm](https://github.com/cybershadow/rabcdasm#tips) itself.

Before disassembling an SWF for the first time, `redasm` creates a backup of the SWF
ending in `.bak`, at the same directory.
