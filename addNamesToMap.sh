#! /bin/bash

MAP_FILE=map_to_plot.svg
OUTPUT_FILE=map_to_plot.svg 
PAGE_W=32
PAGE_H=24
BIG_FONT=0.7
MID_FONT=0.5
MID_FONT_P=0.7 # 0.7 : 0.5 = 100 : x = ~71.4%
SML_FONT=0.25
SML_FONT_P=0$(echo "scale=4; ${SML_FONT} * 1.286" | bc)
SML_FONT_PP=0$(echo "scale=4; ${SML_FONT} * 1.4" | bc)
TITLE_FONT=0.8
SUBTITLE_FONT=0.45

LABELS=(
    "salesin ${BIG_FONT} 20 19.25 10.25"
    "catun ${MID_FONT} 20 14.54 5.35"
    "steinhalsen ${MID_FONT_P} 20 21 5.1"
    "lauren ${MID_FONT} 20 14 14.1"
    "wachefels ${MID_FONT_P} 20 7.4 17.25"
    "orthabuhr ${SML_FONT_P} 10 15.4 7.2"
    "lamorsin ${SML_FONT} 10 21.9 8.33"
    "elhyrst ${SML_FONT_P} 10 24.8 9.15"
    "kabin ${SML_FONT} 10 16.67 10.48"
    "uta_vel ${SML_FONT} 10 21.33 11.82"
    "knoll ${SML_FONT} 10 16.64 13.57"
    "hillfar ${SML_FONT} 10 9.085 12.2"
    "porto_lemoor ${SML_FONT_PP} 10 9.65 14.45"
    "vallursa ${SML_FONT} 10 11.18 15.57"
    "champieu ${SML_FONT_P} 10 15.7 17.25"
    "campo_robia ${SML_FONT_PP} 10 11.66 19.93"
    "cartiglio_title ${TITLE_FONT} 30 25.6 5.5"
    "cartiglio_subtitle ${SUBTITLE_FONT} 30 25.6 6.5"
)

RECT_W=3cm
RECT_H=0.5cm
MIN_X=500
MAX_X=3000
INC_X=200
CURRENT_X=-${MIN_X}
LINES_COMMAND=""

while [ "$CURRENT_X" -lt "$MAX_X" ]; do
    USABLE_X1=$(awk '{printf "%.3f\n", '$CURRENT_X' / 1000}' <<< "")
    USABLE_X2=$(awk '{printf "%.3f\n", ('$CURRENT_X' + '$MIN_X') / 1000}' <<< "")
    #echo $CURRENT_X $USABLE_X1 $USABLE_X2
    LINES_COMMAND=$LINES_COMMAND" line -- ${USABLE_X1}cm 0cm ${USABLE_X2}cm ${RECT_H}"
    CURRENT_X=$(echo "$CURRENT_X + $INC_X" | bc )
done
#echo $LINES_COMMAND

FULL_RECT="map/full_rect.svg"
EMPTY_RECT="map/empty_rect.svg"

# CREAZIONE RETTANGOLO PIENO
vpype \
    rect 0cm 0cm ${RECT_W} ${RECT_H} \
    ${LINES_COMMAND} \
    crop 0cm 0cm ${RECT_W} ${RECT_H} \
    write "${FULL_RECT}"

# CREAZIONE RETTANGOLO VUOTO
vpype \
    rect 0cm 0cm ${RECT_W} ${RECT_H} \
    write "${EMPTY_RECT}"

# CREAZIONE RIGA ASSE X (44 PEZZI)
PIECES_COMMAND=""
MAX_PIECES=22
CURRENT_LAYER=1

CURRENT_PIECE=0
while [ "$CURRENT_PIECE" -lt "$MAX_PIECES" ]; do
    CURRENT_X=$(awk '{printf "%.1f\n", '$CURRENT_PIECE' * 6}' <<< "")
    PIECES_COMMAND=$PIECES_COMMAND" read --single-layer -l ${CURRENT_LAYER} ${FULL_RECT} translate -l ${CURRENT_LAYER} ${CURRENT_X}cm 0cm"
    CURRENT_PIECE=$(( $CURRENT_PIECE + 1 ))
    CURRENT_LAYER=$(( $CURRENT_LAYER + 1 ))
done

CURRENT_PIECE=0
while [ "$CURRENT_PIECE" -lt "$MAX_PIECES" ]; do
    CURRENT_X=$(awk '{printf "%.1f\n", 3 + ('$CURRENT_PIECE' * 6)}' <<< "")
    PIECES_COMMAND=$PIECES_COMMAND" read --single-layer -l ${CURRENT_LAYER} ${EMPTY_RECT} translate -l ${CURRENT_LAYER} ${CURRENT_X}cm 0cm"
    CURRENT_PIECE=$(( $CURRENT_PIECE + 1 ))
    CURRENT_LAYER=$(( $CURRENT_LAYER + 1 ))
done

vpype \
    ${PIECES_COMMAND} \
    scaleto -o 0 0 26.1cm 3cm \
    layout -l --fit-to-margins 0cm -v top 26.1cmx3cm \
    write map/rect_line.svg

# CREAZIONE RIGA ASSE X (44 PEZZI)
PIECES_COMMAND=""
MAX_PIECES=16
CURRENT_LAYER=1

CURRENT_PIECE=0
while [ "$CURRENT_PIECE" -lt "$MAX_PIECES" ]; do
    CURRENT_X=$(awk '{printf "%.1f\n", '$CURRENT_PIECE' * 6}' <<< "")
    PIECES_COMMAND=$PIECES_COMMAND" read --single-layer -l ${CURRENT_LAYER} ${FULL_RECT} translate -l ${CURRENT_LAYER} ${CURRENT_X}cm 0cm"
    CURRENT_PIECE=$(( $CURRENT_PIECE + 1 ))
    CURRENT_LAYER=$(( $CURRENT_LAYER + 1 ))
done

CURRENT_PIECE=0
while [ "$CURRENT_PIECE" -lt "$MAX_PIECES" ]; do
    CURRENT_X=$(awk '{printf "%.1f\n", 3 + ('$CURRENT_PIECE' * 6)}' <<< "")
    PIECES_COMMAND=$PIECES_COMMAND" read --single-layer -l ${CURRENT_LAYER} ${EMPTY_RECT} translate -l ${CURRENT_LAYER} ${CURRENT_X}cm 0cm"
    CURRENT_PIECE=$(( $CURRENT_PIECE + 1 ))
    CURRENT_LAYER=$(( $CURRENT_LAYER + 1 ))
done

vpype \
    ${PIECES_COMMAND} \
    scaleto -o 0 0 18.1cm 3cm \
    rotate 90 \
    layout --fit-to-margins 0cm -h left 3cmx18.1cm \
    write map/rect_column.svg

# CREAZIONE BORDO MAPPA

vpype \
    pagesize -l ${PAGE_W}cmx${PAGE_H}cm \
    read -m -l1 -c map/rect_line.svg \
    translate -l1 2.9cm 2.9cm \
    read -m -l2 -c map/rect_line.svg \
    rotate -l2 180 \
    translate -l2 3cm 21cm \
    read -m -l3 -c map/rect_column.svg \
    rotate -l3 180 \
    translate -l3 2.9cm 3cm \
    read -m -l4 -c map/rect_column.svg \
    translate -l4 29cm 2.9cm \
    line 3.1cm 3.1cm 28.9cm 3.1cm \
    line 28.9cm 3.1cm 28.9cm 20.9cm \
    line 28.9cm 20.9cm 3.1cm 20.9cm \
    line 3.1cm 20.9cm 3.1cm 3.1cm \
    linemerge \
    linesimplify \
    reloop \
    linesort \
    write map/map_border.svg

CURRENT_LAYER=2
for LABEL in "${LABELS[@]}"; do
    FILE=$(echo $LABEL | cut -d' ' -f1)
    LABEL_H=$(echo $LABEL | cut -d' ' -f2)
    LABEL_W=$(echo $LABEL | cut -d' ' -f3)
    LABEL_X=$(echo $LABEL | cut -d' ' -f4)
    LABEL_Y=$(echo $LABEL | cut -d' ' -f5)
    echo $FILE $LABEL_W $LABEL_H $LABEL_X $LABEL_Y

    TL_X=$(echo "scale=4; ${LABEL_X} - (${LABEL_W} / 2)" | bc)
    TL_Y=$(echo "scale=4; ${LABEL_Y} - (${LABEL_H} / 2)" | bc)

    echo "Moving ${FILE} to ${TL_X};${TL_Y}"

    vpype read map/${FILE}'.svg' layout -l --fit-to-margins 0cm ${LABEL_H}cmx${LABEL_W}cm write map/${FILE}'_small.svg'

    vpype read map/${FILE}'_small.svg' translate -- ${TL_X}cm ${TL_Y}cm pagesize -l ${PAGE_H}cmx${PAGE_W}cm write map/${FILE}'_small.svg'
    
    READ_COMMAND="read -m -l 1 map/${OUTPUT_FILE}"
    if [ "$CURRENT_LAYER" -eq "2" ]; then READ_COMMAND=''; fi

    vpype \
        ${READ_COMMAND} \
        read -m -l ${CURRENT_LAYER} map/${FILE}'_small.svg' \
        write map/${OUTPUT_FILE}
    
    CURRENT_LAYER=$(( $CURRENT_LAYER + 1 ))
done


vpype \
    read -m -l1 ${MAP_FILE} \
    pagesize -l ${PAGE_H}cmx${PAGE_W}cm \
    read -m -l2 map/${OUTPUT_FILE} \
    read -m -l3 map/map_border.svg \
    linemerge \
    linesimplify \
    reloop \
    linesort \
    show \
    write map/${OUTPUT_FILE} 