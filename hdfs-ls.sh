#!/bin/bash

echo ""
echo "Puede consultar el resultado de esta búsqueda en busqueda_recursiva.txt"
echo ""

Help()
{
	# Display Help
	echo
	echo "Script para listar el contenido de una carpeta en hdfs"
	echo "o buscar un fichero de forma recursiva en una ruta dada."
	echo "Si solo se aporta una ruta, lista su contenido." 
	echo "Si se aportan uno o dos patrones, buscará coincidencias"
	echo "de forma recursiva, partiendo de la ruta dada."
	echo
	echo "Sintaxis: ./hdfs-ls [-h|p|f|o]"
	echo
	echo "Opciones:"
	echo
	echo "-h     Muestra esta ayuda."
	echo "-p     Ruta para listar su contenido o buscar un fichero."
	echo "-f     Patron a encontrar dentro del contenido de la ruta."
	echo "       Si se deja en blanco, lista todo el contenido de la ruta."
	echo "-o     Segundo patron a encontrar dentro del contenido de la ruta."
	echo "       Puede ser el odate y si se deja en blanco, sólo busca coincidencias con el primer patrón."
	echo
}

while getopts "hp:f:o:" flag; do
	case $flag in
		h)
			Help
			exit 1
		;;
		p)
			path="$OPTARG"
		;;
		f)
			file="$OPTARG"
		;;
		o)
			odate="$OPTARG"
		;;
	esac
done

Buscar()
{
    if [ -z "$path" ]
    then
        # Ask the path to check
        echo
        read -p 'Ruta a consultar: ' path

        # Ask the file to check
        read -p 'Patrón a encontrar (dejar en blanco para listar todos los archivos): ' file
    fi

    if [ -z "$file" ]
    then
        hdfs dfs -ls $path | tee busqueda_recursiva.txt
    else
        if [ -z "$odate" ]
        then
            read -p 'Odate o segundo patron (dejar en blanco para mostrar todas las ocurrencias de patron anterior): ' odate
            echo
        fi
        
        if [ -z "$odate" ]
        then
            hdfs dfs -ls -R $path | grep $file | tee busqueda_recursiva.txt
        else
            hdfs dfs -ls -R $path | grep $file | grep $odate | tee busqueda_recursiva.txt
        fi
    fi
    
    echo
    read -p '¿Quiere realizar otra búsqueda? s/n ' repetir
    echo

    if [ "$repetir" = "s" ];
    then
        unset path
        unset file
        unset odate
        Buscar
    else
        exit 0
    fi
    
}
Buscar
