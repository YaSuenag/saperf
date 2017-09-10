#!/bin/sh

# Copyright (C) 2017 Yasumasa Suenaga
#
# This file is part of SA perf.
#
# SA perf is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# SA perf is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with SA perf.  If not, see <http://www.gnu.org/licenses/>.

SAPERF_HOME=`dirname $0 | xargs readlink -f`

JDK9=0
TARGET_PID=''

if [ $1 == '--jdk9' ]; then
  JDK9=1
  TARGET_PID=$2
else
  TARGET_PID=$1
fi

if [ -z "$TARGET_PID" ]; then
  echo "Usage:"
  echo "  $0 [--jdk9] <PID>"
  exit 1
fi

if [ -z "$JAVA_HOME" ]; then
  echo 'SA Perf needs $JAVA_HOME'
  exit 2
fi

MAPFILENAME=/tmp/perf-$TARGET_PID.map

if [ $JDK9 -eq 0 ]; then
  $JAVA_HOME/bin/java \
      -cp $JAVA_HOME/lib/sa-jdi.jar \
      sun.jvm.hotspot.CLHSDB $TARGET_PID << EOF
jsload $SAPERF_HOME/sajs/perf-codecache.js
perfcodecache > $MAPFILENAME
quit
EOF

else
  SHOULD_SKIP=1

  $JAVA_HOME/bin/jcmd $TARGET_PID Compiler.codelist | while read line; do

    if [ $SHOULD_SKIP -eq 1 ]; then
      SHOULD_SKIP=0  # Skip JCMD header (PID)
      continue
    fi

    METHOD=`echo $line | cut -d' ' -f 3`
    START=`echo $line | sed -e 's/^.\+\(0x[0-9a-f]\+\) \- .\+$/\1/'`
    END=`echo $line | sed -e 's/^.\+ - \(0x[0-9a-f]\+\).\+$/\1/'`
    SIZE=`printf '%x' $(($END - $START))`
    PRINT_ADDR=`echo $START | sed -e 's/^0x0\+\([^0][0-9a-f]\+\)$/\1/'`

    echo "$PRINT_ADDR $SIZE $METHOD" >> $MAPFILENAME
  done

fi

echo

if [ $? -eq 0 ]; then
  echo "Dump CodeCache to $MAPFILENAME"
else
  echo "failed."
fi

