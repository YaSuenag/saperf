/*
 * Copyright (C) 2017, 2020, Yasumasa Suenaga
 *
 * This file is part of SA perf.
 *
 * SA perf is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * SA perf is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with SA perf.  If not, see <http://www.gnu.org/licenses/>.
 */

function perfcodecache(){
  var prologue = function(start, end){};
  var epilogue = function(){};
  var visit = function(blob){
    var addr = Number(blob.codeBegin());
    var size = Number(blob.getCodeSize());
    try{
      var method = blob.getName();

      writeln(addr.toString(16) + " " + size.toString(16) + " " + method);
    }
    catch(e){
      writeln(addr.toString(16) + " " + size.toString(16) + " <Unknown 0x" + Number(blob.getAddress()).toString(16) + ">");
    }
  } 

  sa.codeCache.iterate(new sapkg.code.CodeCacheVisitor(){
    prologue: prologue,
       visit: visit,
    epilogue: epilogue
  });
}

registerCommand("perfcodecache", "perfcodecache", "perfcodecache");
