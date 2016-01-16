# Robust, Easy [Dis-]Assembler for ActionScript Bytecode

**redasm-abc** provides an easy and simple SWF reverse-engineering
workflow using the excellent [RABCDAsm](https://github.com/CyberShadow/RABCDAsm) assembler.
[Demo here](http://showterm.io/f8e8416a2968828a75353).


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

That's it! You should now be able to do `redasm` from anywhere.


## Usage

Put the SWF you want to inspect in an empty directory.  
Then run `redasm` to extract all its ABC blocks and disassemble them.  
Edit what you want, then run `redasm` again to apply the changes to the SWF.

redasm-abc will create a directory for each disassembled ABC block (`block-0`, `block-1`,
`block-2`) where its dissassembly lives. Never rename the directories
themselves, nor modify the SWF yourself. This will confuse redasm-abc.


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
