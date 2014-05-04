/***************************************************************************
 * Copyright 2014, Alba Mendez                                           *
 * This file is part of redasm-abc.                                        *
 *                                                                         *
 * redasm-abc is free software: you can redistribute it and/or modify      *
 * it under the terms of the GNU General Public License as published by    *
 * the Free Software Foundation, either version 3 of the License, or       *
 * (at your option) any later version.                                     *
 *                                                                         *
 * redasm-abc is distributed in the hope that it will be useful,           *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           *
 * GNU General Public License for more details.                            *
 *                                                                         *
 * You should have received a copy of the GNU General Public License       *
 * along with redasm-abc.  If not, see <http://www.gnu.org/licenses/>.     *
 ***************************************************************************/

module redasm;

import std.regex;
import std.file;
import std.path;
import std.stdio;
import std.datetime;
import std.conv;
import std.array;

import abcfile;
import asprogram;
import assembler;
import disassembler;
import swffile;

//FIXME: option parsing
//FIXME: catch exceptions
//FIXME: stop at fs boundary
//FIXME: lock the tagfile

bool findRoot(ref string dir, out string tagfile) {
  dir = absolutePath(dir);
  while (true) {
    tagfile = buildPath(dir, ".redasm");
    if (exists(tagfile) && isFile(tagfile)) return true;
    if (dir.length == 1) return false;
    dir = dirName(dir);
  }
}

int main(string[] args) {
  // Find the root
  string root = ".";
  string tagfile;
  SysTime mtime = SysTime(0);

  if (findRoot(root, tagfile)) {
    writefln("Using root: %s", root);
    SysTime atime;
    getTimes(tagfile, atime, mtime);
  } else {
    writeln("Root not found, creating a new one.");
    root = ".";
    tagfile = ".redasm";
  }

  // Find SWF
  auto swfFiles = array(dirEntries(root, "*.swf", SpanMode.shallow));

  if (swfFiles.length < 1) {
    writeln("Error: no SWF file found at the root.");
    return 1;
  }
  if (swfFiles.length > 1) {
    writeln("Error: Too many SWF files found at the root.");
    return 1;
  }

  // Verify time's correct
  auto swfFile = swfFiles[0];
  if (mtime.stdTime) {
    SysTime batime, bmtime;
    getTimes(swfFile.name, batime, bmtime);
    if (bmtime != mtime) {
      writeln("Error: Modification times don't match, SWF (or tag file) was probably modified externally.");
      return 1;
    }
  }

  // Actually process the SWF
  scope swf = SWFFile.read(cast(ubyte[]) read(swfFile.name));
  processSWF(root, swf, mtime);
  std.file.write(swfFile.name, swf.write());

  // Store new time at the tagfile
  if (!mtime.stdTime)
    std.file.write(tagfile, "DON'T TOUCH OR MODIFY THIS FILE IN ANY WAY.\n");
  SysTime batime, bmtime;
  getTimes(swfFile.name, batime, bmtime);
  setTimes(tagfile, batime, bmtime);

  return 0;
}


void processSWF(string root, SWFFile swf, SysTime mtime) {
  int idx = 0;
  foreach (ref tag; swf.tags) {
    if (tag.type == TagType.DoABC || tag.type == TagType.DoABC2) {
      if (tag.type == TagType.DoABC2) {
        auto ptr = tag.data.ptr + 4; // skip flags
        while (*ptr++) {} // skip name

        auto data = tag.data[ptr-tag.data.ptr..$];
        auto header = tag.data[0..ptr-tag.data.ptr];
        processTag(root, data, idx, mtime);
        tag.data = header ~ data;
      } else {
        processTag(root, tag.data, idx, mtime);
      }
      idx++;
    }
  }

  if (idx == 0) {
    writeln("The SWF didn't contain ABC tags.");
  }
}

void processTag(string root, ref ubyte[] data, int idx, SysTime mtime) {
  string name = "block-" ~ to!string(idx);
  string dir = buildPath(root, name);
  if (mtime.stdTime) {
    if (exists(dir) && isDir(dir)) {

      if (modifiedAfter(dir, mtime)) {
        writefln("%s: Reassembling...", name);
        scope as = new ASProgram;
        scope assembler = new Assembler(as);
        assembler.assemble(buildPath(dir, name ~ ".main.asasm"));
        scope abc = as.toABC();
        data = abc.write();
      } else {
        writefln("%s: Up to date.", name);
      }

    } else {
      writefln("%s: Skipping as it's not the first time.", name);
    }
  } else {
    writefln("%s: Disassembling...", name);
    scope abc = ABCFile.read(data);
    scope as = ASProgram.fromABC(abc);
    scope disassembler = new Disassembler(as, dir, name);
    disassembler.disassemble();
  }
}

bool modifiedAfter(string dir, SysTime mtime) {
  foreach(DirEntry e; dirEntries(dir, SpanMode.depth, false)) {
    if (e.timeLastModified > mtime) return true;
  }
  return false;
}
