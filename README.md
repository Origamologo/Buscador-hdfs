# Buscador-hdfs

![Alt Text](https://github.com/Origamologo/Buscador-hdfs/blob/main/tux_holmes.jpeg)

Este repo contiene dos scripts para relizar búsquedas en hdfs:

* hdfs-ls.sh:

Script para listar el contenido de una carpeta en hdfs o buscar un fichero de forma recursiva a partir de una ruta dada.\
El resultado se guarda en resultado_infoengloba.txt\
Si solo se aporta una ruta, lista su contenido.\
Si se aportan uno o dos patrones, buscará coincidencias de forma recursiva, partiendo de la ruta dada.\
Se puede ejecutar directamente o mediante flags, del siguiente modo:

&emsp;Sintaxis: ./hdfs-ls [-h|p|f|o]

&emsp;Opciones:\
&emsp;&emsp;-h     Muestra la ayuda.\
&emsp;&emsp;-p     Ruta para listar su contenido o buscar un fichero.\
&emsp;&emsp;-f     Patron a encontrar dentro del contenido de la ruta. Si se deja en blanco, lista todo el contenido de la ruta.\
&emsp;&emsp;-o     Segundo patron a encontrar dentro del contenido de la ruta. Puede ser el odate y si se deja en blanco, sólo busca coincidencias con el primer patrón.


* infoengloba_diario.sh:

Script que lista el contenido de las rutas que se encuentre en un fichero llamado paths.txt\
El resultado se guarda en busqueda_recursiva.txt\
Es importante que en paths.txt haya un ruta por línea.\
Si no se le introduce una fecha en formato YYYY-MM-DD, mirará lo que haya para hoy, excepto par la tabla t_xmce_intraday, que mirará para ayer.
