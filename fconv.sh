#!/bin/bash

JUICY_BIN=/Users/fanu/Downloads/juicy-gcode-0.2.0.2/juicy-gcode
FILENAME=$1
FILENAME_NOEXT=$(echo "${FILENAME}" | rev | cut -d'.' -f2- | rev)
FILENAME_GCODE="${FILENAME_NOEXT}.gcode"


#sed -I '' 's:G0 X0 Y0:G0 X30 Y30 F2000:gi' "${FILENAME_GCODE}" &&

echo "G0 Z30 F2000" > "${FILENAME_GCODE}" &&
echo "G28 X Y" >> "${FILENAME_GCODE}" &&
echo "G92 X0 Y0" >> "${FILENAME_GCODE}" &&
echo "G0 X50 Y27 Z30 F2000" >> "${FILENAME_GCODE}" &&
echo "G92 X0 Y0" >> "${FILENAME_GCODE}" &&
echo "G0 X30 Y30" >> "${FILENAME_GCODE}" &&
${JUICY_BIN} "$1" >> "${FILENAME_GCODE}" &&
sed -I '' 's:G0 X0 Y0:G0 X30 Y30 F2000:gi' "${FILENAME_GCODE}" &&
sed -I '' 's:G01 Z0 F10.00:G01 Z0 F2000:gi' "${FILENAME_GCODE}" &&
sed -I '' 's:G00* Z1:G0 Z1 F2000:gi' "${FILENAME_GCODE}" &&
sed -I '' 's:Z1:Z12:gi' "${FILENAME_GCODE}" &&
sed -I '' 's:Z0:Z10.4:gi' "${FILENAME_GCODE}" &&
echo "G0 X30 Y30 Z30" >> "${FILENAME_GCODE}" &&
tail -n +12 "${FILENAME_GCODE}" > "${FILENAME_GCODE}2" &&
rm "${FILENAME_GCODE}" &&
mv "${FILENAME_GCODE}2" "${FILENAME_GCODE}" &&
sed -i '' -e '$ d' "${FILENAME_GCODE}" &&
sed -i '' -e '$ d' "${FILENAME_GCODE}" &&
echo "G0 Z30 F2000" >> "${FILENAME_GCODE}"
echo "G0 X30 Y150 F5000" >> "${FILENAME_GCODE}"
echo "G0 Z30 F2000" >> "${FILENAME_GCODE}"