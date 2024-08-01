#!/bin/bash

output_file="resultado_zip.txt"

echo ""
echo "Puede consultar el resultado de esta búsqueda en $output_file"
echo ""

echo "Escriba el nombre del fichero con su ruta completa"
echo "(Por ejemplo: /path/to/file/whatever.zip)"
echo
read -p 'Ruta a consultar: ' file

{
  hdfs dfs -ls $file
  hdfs dfs -copyToLocal $file /tmp/
  file_name=$(basename "$file")
  unzip -l /tmp/$file_name
  rm /tmp/$file_name
} | tee $output_file
