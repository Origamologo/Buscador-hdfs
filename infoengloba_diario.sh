#!/bin/bash

echo ""
read -p 'Escriba la fecha de llegada de ficheros en formato YYYY-MM-DD o deje en blanco para consultar la actual: ' current_date
echo ""

if [ -z "$current_date_input" ]
then
    # Guarda la fecha actual en formato YYYY-MM-DD
    current_date=$(date +%F)
else
    current_date=$current_date_input
fi

# Comprueba que existe el fichero
if [ -e "paths.txt" ]; then

    # Abrir resultado_infoengloba.txt para escritura
    exec 3>&1
    exec 1> >(tee resultado_infoengloba.txt)

    # Lee cada linea y busca el fichero para hoy
    while IFS= read -r path; do
    
    	# Comprueba si el path es "/data/master/cib/xmce/data/t_xmce_intraday" y en caso afirmativo mira la carga de ayer
	if [ "$path" = "/data/master/cib/xmce/data/t_xmce_intraday" ] && [ "$(date +%F)" = "$current_date" ]
	then
    		# Si las dos condiciones son verdaderas, comprueba la fecha de ayer
    		current_date=$(date -d "yesterday" +%F)
    	else
    		# En caso contrario, vuelve a la fecha de hoy
    		if [ "$(date +%F)" != "$current_date" ]
    		then
    			current_date=$current_date_input
    		else
    			current_date=$(date +%F)
    		fi
	fi

    
        output=$(hdfs dfs -ls "$path" | grep "$current_date")
        
        # Comprueba si han llegado ficheros o no
        if [ -z "$output" ]; then

            echo "El $current_date no hay nada en la ruta $path"
            echo ""
        else
            echo "En la ruta $path el $current_date tenemos:"
            echo ""
            hdfs dfs -ls "$path" | grep "$current_date"
            echo ""
        fi
        
    done < "paths.txt"

    # Cerrar el descriptor de archivo
    exec 1>&3
    exec 3>&-
    
else
    echo "El fichero paths.txt no existe."
fi
