#! /bin/bash

PAGE_W=32
PAGE_H=24

POS_X=5.5
POS_Y=4.5
WIDTH=13
HEIGHT=$(echo "scale=1; (${WIDTH}*${PAGE_H})/${PAGE_W}" | bc)
WIDTH=$(echo "scale=1; ${WIDTH} + 1" | bc)

MAP_NAME=map_${POS_X}-${POS_Y}-${WIDTH}-${HEIGHT}.svg

vpype read map.svg crop ${POS_X}cm ${POS_Y}cm ${WIDTH}cm ${HEIGHT}cm layout -l --fit-to-margins 3cm ${PAGE_H}cmx${PAGE_W}cm write ${MAP_NAME}

#vpype read cartiglio_small.svg translate 23cm 3.4cm pagesize -l 32cmx24cm write cartiglio_small_positioned.svg

vpype read --single-layer -l 1 ${MAP_NAME} read --single-layer -l 2 cartiglio_small_positioned.svg write ${MAP_NAME}