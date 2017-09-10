/*
 * Copyright (C) 2017 Yasumasa Suenaga
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

package com.yasuenag.saperf.agent;

import java.lang.instrument.*;
import java.io.*;


public class AgentMain implements Runnable{

  private final File inFile;

  private final File outFile;

  public AgentMain(File inFile, File outFile){
    this.inFile = inFile;
    this.outFile = outFile;
  }

  private void silentClose(Closeable c){
    try{
      c.close();
    }
    catch(NullPointerException e){
      // Do nothing
    }
    catch(IOException e){
      e.printStackTrace();
    }
  }

  private String getPid() throws IOException{
    BufferedReader reader = null;
    try{
      reader = new BufferedReader(new FileReader("/proc/self/stat"));
      String line = reader.readLine();
      return line.split(" ")[0];
    }
    finally{
      silentClose(reader);
    }
  }

  public void run(){
    OutputStream out = null;
    try{
      out = new FileOutputStream(outFile);
      out.write(getPid().getBytes());
    }
    catch(IOException e){
      e.printStackTrace();
    }
    finally{
      silentClose(out);
    }

    InputStream in = null;
    try{
      in = new FileInputStream(inFile);
      in.read();
    }
    catch(IOException e){
      e.printStackTrace();
    }
    finally{
      silentClose(in);
    }

  }

  public static void agentmain(String agentArgs, Instrumentation inst){
    premain(agentArgs, inst);
  }

  public static void premain(String agentArgs, Instrumentation inst){
    String[] argPairs = agentArgs.split(",");

    String in = null;
    String out = null;

    for(String pair : argPairs){
      String[] opts = pair.split("=");

      if(opts[0].equals("in")){
        in = opts[1];
      }
      else if(opts[0].equals("out")){
        out = opts[1];
      }
      else{
        System.err.println("Unknown option: " + opts[0]);
        return;
      }

    }

    if(in == null){
      System.err.println("infile is not specified.");
      return;
    }
    if(out == null){
      System.err.println("outfile is not specified.");
      return;
    }

    Runtime.getRuntime()
	   .addShutdownHook(
                        new Thread(new AgentMain(new File(in), new File(out))));
  }

}

