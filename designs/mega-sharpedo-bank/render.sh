#!/bin/bash
# Render a coloured preview PNG of one design.
# usage: ./render.sh 02_chomp.scad out.png "tx,ty,tz,rx,ry,rz,dist" [extra openscad args]
# Needs OpenSCAD; on a headless machine it runs under xvfb-run.
f=$1; o=$2; cam=$3; shift 3
run=""; [ -z "$DISPLAY" ] && command -v xvfb-run >/dev/null && run="xvfb-run -a"
$run openscad -o "$o" --imgsize=1200,1000 --camera="$cam" --colorscheme=Tomorrow "$@" "$f"
