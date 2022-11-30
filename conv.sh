#!/bin/bash

JUICY_BIN=/Users/fanu/Downloads/juicy-gcode-0.2.0.2/juicy-gcode
FILENAME=$1
FILENAME_NOEXT=$(echo "${FILENAME}" | rev | cut -d'.' -f2- | rev)
FILENAME_GCODE="${FILENAME_NOEXT}.gcode"
SERVO_UP_MIN=48
SERVO_UP_MAX=45
Y_MIN=0
Y_MAX=200
SERVO_UP=48
SERVO_DOWN=65

${JUICY_BIN} "$1" > "${FILENAME_GCODE}" &&
sed -I '' 's:G0 X0 Y0:G0 X30 Y30 F2000:gi' "${FILENAME_GCODE}" &&
sed -I '' 's:G00* Z1:M3 S'$SERVO_UP"\n"'G04 P0.1:gi' "${FILENAME_GCODE}" &&
sed -I '' 's:G01 Z0.*:G04 P0.2'"\n"'M3 S'$SERVO_DOWN"\n"'G04 P0.1:gi' "${FILENAME_GCODE}" &&
echo "G0 X30 Y30" >> "${FILENAME_GCODE}"

SERVO_DELTA=$(awk '{printf "%.4f\n", '$SERVO_UP_MIN' - '$SERVO_UP_MAX'}' <<< "")
# echo $SERVO_DELTA
cat "${FILENAME_GCODE}" | tr '\n' '\' > "${FILENAME_GCODE}.tmp"
ggrep -Po "Y\d+\.\d+.M3 S'$SERVO_UP'" "${FILENAME_GCODE}.tmp" | while read LINE; do
    CURRENT_Y=$(echo $LINE | cut -d'M' -f1 | cut -d'Y' -f2)
    # CURRENT_Y : Y_MAX = x : SERVO_DELTA
    SERVO_TO_SUBTRACT=$(awk '{printf "%.0f\n", '$SERVO_UP_MIN' - ('$SERVO_DELTA' * '$CURRENT_Y' / '$Y_MAX')}' <<< "")
    # echo $CURRENT_Y $SERVO_TO_SUBTRACT
    sed -I '' 's:Y'$CURRENT_Y'\\M3 S'$SERVO_UP':Y'$CURRENT_Y'\\M3 S'$SERVO_TO_SUBTRACT':gi' "${FILENAME_GCODE}.tmp"
done

cat "${FILENAME_GCODE}.tmp" | tr '\' '\n' > "${FILENAME_GCODE}"
rm "${FILENAME_GCODE}.tmp"