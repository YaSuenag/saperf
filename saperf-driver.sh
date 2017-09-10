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
if [ $1 == '--jdk9' ]; then
  JDK9=1
  shift
fi

if [ -z "$JAVA_HOME" ]; then
  echo 'SA Perf needs $JAVA_HOME'
  exit 1
fi

IN_PIPE=`mktemp -u --suff _saperf-in`
OUT_PIPE=`mktemp -u --suff _saperf-out`

mkfifo $IN_PIPE $OUT_PIPE

SAPERF_AGENT=$SAPERF_HOME/agent/dist/saperf-agent.jar
SAPERF_AGENT_OPTS="in=$IN_PIPE,out=$OUT_PIPE"

perf record -g \
    $JAVA_HOME/bin/java \
        -javaagent:$SAPERF_AGENT=$SAPERF_AGENT_OPTS \
        -XX:-UseCodeCacheFlushing \
        $@ &

BG_PID=$!

TARGET_PID=`cat $OUT_PIPE`

COLLECTOR_OPTS=''
if [ $JDK9 -eq 1 ]; then
  COLLECTOR_OPTS=--jdk9
fi

$SAPERF_HOME/saperf-collector.sh $COLLECTOR_OPTS $TARGET_PID
echo -n '1' > $IN_PIPE

wait $BG_PID

rm -f $IN_PIPE $OUT_PIPE
