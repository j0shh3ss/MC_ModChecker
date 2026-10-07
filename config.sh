#!/bin/bash

MC_VERSION="26.3"
LOADER="Fabric"
#Central Mod directory
MODS_DIR="/home/whats1ttoya/tests/mod_auto_update/mods"
#FUTURE - MODS_DIR="mnt/server/mods"

#Mods to declare
declare -A MOD_PROJECTS=(
        ["lithium"]="lithium"
        ["sodium"]="sodium"
        ["c2me"]="c2me"
        ["krypton"]="krypton"
)
