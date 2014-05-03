# Robust, Easy [Dis-]Assembler for ActionScript Bytecode

Did you know **[RABCDasm](https://github.com/CyberShadow/RABCDAsm)**, the robust ActionScript (dis)assembler?  
**redasm-abc** aims to provide an easy-to-use assistant to it.

Forget about the export-disassemble-edit-assemble-replace process;
note the difference:

#### Pure RABCDasm

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


## Usage

Put the SWF you want to inspect in an empty directory.  
Then run `redasm` to extract all its ABC blocks and disassemble them.  
Edit what you want, then run `redasm` again to apply the changes to the SWF.

redasm-abc will create a directory for each disassembled ABC block.  
By default, the directories are named `block-0`, `block-1`, `block-2`, ...  
but you are free to *rename* them to your needs.


## Tips

Always keep a backup of the original SWF, even if you just want to disassemble it.  
After disassembling, add the files to version control (i.e. Git).

