#!/usr/bin/env bash

ROOT="$HOME/.tcad-script-gen"

mkdir -p $ROOT


NEW_CONTENT='
# DO NOT edit

# tool: Bun
if {[file exists "$env(HOME)/.tcad-script-gen/tooldb_bun"]} {
    source $env(HOME)/.tcad-script-gen/tooldb_bun.tcl
} else {
    puts "Warning: $env(HOME)/.tcad-script-gen/tooldb_bun.tcl not found"
}
'

MARKER_START='# ==== Bun Start ===='
MARKER_END='# ==== Bun End ===='
TARGET_FILE="$STDB/tooldb_$USER"

if grep -q "$MARKER_START" $TARGET_FILE; then
    sed -i.bak "/$MARKER_START/,/$MARKER_END/d" $TARGET_FILE
    {
        echo "$MARKER_START"
        printf '%s\n' "$NEW_CONTENT"
        echo "$MARKER_END"
    } >> $TARGET_FILE
else
    {
        echo ""
        echo "$MARKER_START"
        printf '%s\n' "$NEW_CONTENT"
        echo "$MARKER_END"
    } >> $TARGET_FILE
fi


curl -fsSL https://blog.tongleen.art/sentaurus_bun/tooldb_bun.tcl -o $ROOT/tooldb_bun.tcl
curl -fsSL https://blog.tongleen.art/sentaurus_bun/bun_logo.gif -o $ROOT/bun_logo.gif
curl -fsSL https://blog.tongleen.art/sentaurus_bun/bundevice_logo.gif -o $ROOT/bundevice_logo.gif
curl -fsSL https://blog.tongleen.art/sentaurus_bun/bunstr_logo.gif -o $ROOT/bunstr_logo.gif
