# tool: Bun

# Bun Util
set WB_tool(Bun,category) utility
set WB_tool(Bun,visual_category) utility
set WB_tool(Bun,acronym) bun
set WB_tool(Bun,after) all
set WB_tool(Bun,cmd_line) bun\ @commands@
set WB_binaries(tool,Bun) /bin/env
set Icon(Bun) $env(HOME)/.tcad-script-gen/bun_logo.gif
set WB_tool(Bun,input) [list commands parameter pref]
set WB_tool(Bun,input,commands,label)  "Bun Script..."
set WB_tool(Bun,input,commands,editor)  text
set WB_tool(Bun,input,commands,file)  @tool_label@.ts

set WB_tool(Bun,input,pref,label)  "Preferences..."
set WB_tool(Bun,input,pref,editor)  pref
set WB_tool(Bun,input,pref,file)  @tool_label@_bun.prf
set WB_tool(Bun,output) [list code]
set WB_tool(Bun,output,code,file) n@node@_gen.cmd
set WB_tool(Bun,output,files) "n@node@_* pp@node@_*"
set WB_tool(Bun,epilogue) { extract_vars "$nodedir" @stdout@ @node@ }
set WB_tool(Bun,available) { check_binary_path Bun }
lappend WB_tool(all) Bun


# Bun Structure
set WB_tool(BunStr,category) process
set WB_tool(BunStr,visual_category) group_process_emulation
set WB_tool(BunStr,acronym) bst
set WB_tool(BunStr,after) [list START cshell sprocess]
set Icon(BunStr) $env(HOME)/.tcad-script-gen/bunstr_logo.gif
set WB_tool(BunStr,epilogue) { extract_vars "$nodedir" @stdout@ @node@ }
set WB_binaries(tool,BunStr) /bin/env
set WB_tool(BunStr,available) { check_binary_path BunStr }
set WB_tool(BunStr,cmd_line) bun\ @commands@
set WB_tool(BunStr,input) [list commands acis acis_journal scheme grid \
    boundary doping layout prosit_layout pref tdrboundary epicsv]
set WB_tool(BunStr,input,commands,file)  @tool_label@_bst.ts
set WB_tool(BunStr,input,commands,newfile)  @tool_label@_bst.ts
set WB_tool(BunStr,input,commands,label)  "Commands..."
set WB_tool(BunStr,input,commands,editor)  text
set WB_tool(BunStr,input,commands,parametrized)  1
set WB_tool(BunStr,input,boundary,user)  1
set WB_tool(BunStr,input,boundary,label)  "Boundary File..."
set WB_tool(BunStr,input,boundary,editor)  text
set WB_tool(BunStr,input,boundary,parametrized)  1
set WB_tool(BunStr,input,pref,label)  "Preferences..."
set WB_tool(BunStr,input,pref,editor)  pref
set WB_tool(BunStr,input,pref,file)  @tool_label@_bst.prf
set WB_tool(BunStr,input,epicsv,label)   "CSV Data File..."
set WB_tool(BunStr,input,epicsv,parametrized) 1
set WB_tool(BunStr,input,epicsv,editor)  text
set WB_tool(BunStr,input,epicsv,file)    @tool_label@_epi.csv
set WB_tool(BunStr,output) [list commands acis acis_journal scheme boundary grid \
    doping layout prosit_layout tdr tdrboundary episcm epitcl]
set WB_tool(BunStr,output,acis,file)  n@node@.sat
set WB_tool(BunStr,output,scheme,file)  n@node@.scm
set WB_tool(BunStr,output,acis_journal,file)  n@node@.jrl
set WB_tool(BunStr,output,boundary,file)  n@node@_msh.bnd
set WB_tool(BunStr,output,commands,file)  n@node@_msh.cmd
set WB_tool(BunStr,output,layout,file)  n@node@_bst.lyt
set WB_tool(BunStr,output,prosit_layout,file)  n@node@_bst.lay
set WB_tool(BunStr,output,grid,file)  n@node@_msh.grd
set WB_tool(BunStr,output,doping,file)  n@node@_msh.dat
set WB_tool(BunStr,output,tdr,file)  n@node@_msh.tdr
set WB_tool(BunStr,output,tdrboundary,file) n@node@_bnd.tdr
set WB_tool(BunStr,output,episcm,file)     n@node@_epi.scm
set WB_tool(BunStr,output,epitcl,file)     n@node@_epi.tcl
set WB_tool(BunStr,output,files) "n@node@_* pp@node@_* n@node@.*"
lappend WB_tool(all) BunStr

# Bun Device
set WB_tool(BunDevice,category) device
set WB_tool(BunDevice,visual_category) group_device_gridgen
set WB_tool(BunDevice,acronym) bdv
set WB_tool(BunDevice,after) [list START cshell BunStr]
set WB_tool(BunDevice,cmd_line) bun\ @commands@
set WB_binaries(tool,BunDevice) /bin/env
set Icon(BunDevice) $env(HOME)/.tcad-script-gen/bundevice_logo.gif
set WB_tool(BunDevice,input) [list commands parameter grid doping edit tdr epitcl pref wizard]
set WB_tool(BunDevice,input,commands,file)  @tool_label@_bdv.ts
set WB_tool(BunDevice,input,commands,newfile)  @tool_label@_bdv.ts
set WB_tool(BunDevice,input,commands,label)  Commands...
set WB_tool(BunDevice,input,commands,editor)  text
set WB_tool(BunDevice,input,parameter,files)  sdevice_*.par
set WB_tool(BunDevice,input,parameter,file)  .par
set WB_tool(BunDevice,input,parameter,newfile)  sdevice.par
set WB_tool(BunDevice,input,parameter,common) 1
set WB_tool(BunDevice,input,parameter,label)  "Parameter..."
set WB_tool(BunDevice,input,parameter,parametrized)  1
set WB_tool(BunDevice,input,parameter,editor)  text
set WB_tool(BunDevice,input,edit,label)  "Include Materials..."
set WB_tool(BunDevice,input,edit,cmd)  G_ToolInput::GetDatex
set WB_tool(BunDevice,input,pref,label)  "Preferences..."
set WB_tool(BunDevice,input,pref,editor)  pref
set WB_tool(BunDevice,input,pref,file)   @tool_label@_bdv.prf
set WB_tool(BunDevice,output) [list log optlog plot acplot spectralplot optfarfield modegain dat optpattern save tdrdat]
set WB_tool(BunDevice,output,acplot,file)  n@node@_ac_bdv.plt
set WB_tool(BunDevice,output,plot,file)  n@node@_bdv.plt
set WB_tool(BunDevice,output,optfarfield,file)  n@node@_ff_bdv.plt
set WB_tool(BunDevice,output,modegain,file)  n@node@_gain_bdv.plt
set WB_tool(BunDevice,output,optpattern,file)  n@node@_op_bdv.dat
set WB_tool(BunDevice,output,optlog,file)  n@node@_optics_bdv.log
set WB_tool(BunDevice,output,spectralplot,file)  n@node@_spec_bdv.tdr
set WB_tool(BunDevice,output,files) "n@node@_* pp@node@_* *_n@node@_*"
set WB_tool(BunDevice,epilogue) { extract_vars "$nodedir" @stdout@ @node@ }
set WB_tool(BunDevice,available) { check_binary_path BunDevice }
lappend WB_tool(all) BunDevice
