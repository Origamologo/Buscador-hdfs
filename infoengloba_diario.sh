#!/bin/bash

# Guarda la fecha actual en formato YYYY-MM-DD
current_date=$(date +%F)

# Comprueba que existe el fichero
if [ -e "paths.txt" ]; then

    # Lee cada linea y busca el fichero para hoy
    while IFS= read -r path; do
    
        output=$(hdfs dfs -ls "$path" | grep "$current_date")
        
        # Comprueba si han llegado ficheros o no
	if [ -z "$output" ]; then

		echo "No hay nada en la ruta $path"
		echo ""
	else
		echo "En la ruta $path hoy tenemos:"
		echo ""
		echo hdfs dfs -ls "$path" | grep "$current_date"
		echo ""
	fi
        
    done < "paths.txt"
    
else
    echo "El fichero paths.txt no existe."
fi
