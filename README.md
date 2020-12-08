# SA perf

SA perf collects symbols in CodeCache for perf map ( `/tmp/perf-<PID>.map` ) via SA.

# How to use

## Full time profiling

### 1. Build JVMTI agent

You have to JDK 6 or later.

```
$ cd agent
$ ant
```

### 2. Run driver script

Run `saperf-driver.sh` . This script runs `java` via `perf record -g` with `-javaagent:saperf-agent.jar` and `-XX:-UseCodeCacheFlushing` .
You have to set `JAVA_HOME` environment variable.

* I recommend you to set `-XX:-UseCodeCacheFlushing` because HotSpot will collect unused `CodeBlob` from CodeCache. Thus `perf report` might report incorrect symbol(s) if CodeCache flushing is invoked. But this option might occur CodeCache full.

```
$ export JAVA_HOME=/path/to/jdk
$ ./saperf-driver.sh <options>
```

`<optins>` will be passed to `java` .
If you want to run it on JDK 9 or later, you need to pass `--jdk9` or `--jdk10` to options of `saperf-driver.sh`

```
$ ./saperf-driver.sh --jdk9 <options>
```

```
$ ./saperf-driver.sh --jdk10 <options>
```

## Partially profiling

### Run collector script

You have to set `JAVA_HOME` environment variable.

```
$ export JAVA_HOME=/path/to/jdk
$ ./saperf-collector.sh <PID>
```

If you want to run it on JDK 9, you need to pass `--jdk9` to options of `saperf-collector.sh`

```
$ ./saperf-collector.sh --jdk9 <PID>
```

# Notes

* SA perf dumps all symbols in CodeCache to `/tmp/perf-<PID>.map` . So you might lost these files when you restart your machine.
* SA perf collects all symbols through `CLHSDB` . `CLHSDB` attaches to target process via `ptrace` systemcall. So target process will be suspended while collecting data from CodeCache.
* `UseCodeCacheFlushing` is introduced since 6u21. If you want to profile your app with JDK 6u20 or earlier, please remove this option from `saperf-driver.sh` .
* If you want to get complete mixed call stack in `perf record -g`, you need to add `-XX:+PreserveFramePointer` to `java` options. However it is introduced since 8u60.
* On JDK 9, `saperf-collector.sh` collects symbols in CodeCache via `jcmd <PID> Compiler.codelist` because JDK 9 has a bug [JDK-8157947](https://bugs.openjdk.java.net/browse/JDK-8157947) that CLHSDB cannot load JavaScript. `Compiler.codelist` cannot collect stub routines. Thus you cannot check stubs in `perf report` .

# License

The GNU Lesser General Public License, version 3.0
