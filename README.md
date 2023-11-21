# Buscador-hdfs

![Alt Text](https://github.com/Origamologo/Buscador-hdfs/blob/main/tux_holmes.jpeg)

Script para listar el contenido de una carpeta en hdfs o buscar un fichero de forma recursiva en una ruta dada.\
Si solo se aporta una ruta, lista su contenido.\
Si se aportan uno o dos patrones, buscará coincidencias de forma recursiva, partiendo de la ruta dada.\
Se puede ejecutar directamente o mediante flags, del siguiente modo:

&emsp;Sintaxis: ./hdfs-ls [-h|p|f|o]

&emsp;Opciones:\
&emsp;&emsp;-h     Muestra la ayuda.\
&emsp;&emsp;-p     Ruta para listar su contenido o buscar un fichero.\
&emsp;&emsp;-f     Patron a encontrar dentro del contenido de la ruta. Si se deja en blanco, lista todo el contenido de la ruta.\
&emsp;&emsp;-o     Segundo patron a encontrar dentro del contenido de la ruta. Puede ser el odate y si se deja en blanco, sólo busca coincidencias con el primer patrón.
