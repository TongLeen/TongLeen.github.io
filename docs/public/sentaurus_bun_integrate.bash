#!/usr/bin/env bash

ROOT="$HOME/.tcad-script-gen"

mkdir -p $ROOT

cat > "$ROOT/tooldb_bun" <<'EOF'
# tool: Bun
set WB_tool(Bun,category) utility
set WB_tool(Bun,visual_category) utility
set WB_tool(Bun,acronym) bun
set WB_tool(Bun,after) all
set WB_tool(Bun,cmd_line) /bin/env\ bun\ @commands@
set WB_binaries(tool,Bun) /bin/env
set Icon(Bun) $env(HOME)/.tcad-script-gen/bun_logo.gif
set WB_tool(Bun,input) [list commands pref]
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
EOF


NEW_CONTENT='
# DO NOT edit

# tool: Bun
if {[file exists "$env(HOME)/.tcad-script-gen/tooldb_bun"]} {
    source $env(HOME)/.tcad-script-gen/tooldb_bun
} else {
    puts "Warning: $env(HOME)/.tcad-script-gen/tooldb_bun not found"
}
'

MARKER_START='# ==== Bun Start ===='
MARKER_END='# ==== Bun End ===='
TARGET_FILE="$STDB/tooldb_$USER"

if grep -q "$MARKER_START" $TARGET_FILE; then
    # 存在标记：删除从开始标记到结束标记之间的内容，然后插入新内容
    sed -i.bak "/$MARKER_START/,/$MARKER_END/d" $TARGET_FILE
    # 把新内容（带标记）追加进去
    {
        echo "$MARKER_START"
        printf '%s\n' "$NEW_CONTENT"
        echo "$MARKER_END"
    } >> $TARGET_FILE
else
    # 不存在标记：直接在文件末尾追加带标记的完整块
    {
        echo ""
        echo "$MARKER_START"
        printf '%s\n' "$NEW_CONTENT"
        echo "$MARKER_END"
    } >> $TARGET_FILE
fi



curl -fsSLO https://blog.tongleen.art/bun_logo.gif
