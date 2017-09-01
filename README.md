# ViewerBMP
Visualizador de imagenes de mapa de bits

Programa desarrollado en el IDE MARS escrito en lenguaje ensamblador MIPS el cual permite visualizar una imagen basada en mapa de bits (.BMP), convertir la imagen a Blanco y Negro, Rotar 90° la imagen y hacer Flip vertical / horizontal.


Para la visualización de la imagen, se hace uso de la herramienta Bitmap Display, para ello el usuario debe abrir el bitmap display y conectarlo a MIPS, entonces al ejecutar el programa, éste:


• Solicita al usuario el nombre del archivo .bmp correspondiente a la imagen a renderizar.
<br />
• El usuario ajustar en el Bitmap Display el “Base address for display” a 0x 10000000 (global address).
<br />
• El archivo de imagen es abierto.
<br />
• Se lee la cabecera del archivo.
<br />
• Comprobar que se trata de un archivo BMP.
<br />
• Obtener el número de pixeles para el ancho y alto de la imagen.
<br />
• Obtener el número de bits usados para el color de cada pixel.
<br />
• Mostrar esta información al usuario para que pueda ajustar los valores en el Bitmap Display (sólo trabaja con images con ancho y alto de 64, 128, 256, 512 y 1024 pixeles).
<br />
• Leer el resto del archivo BMP.
<br />
• Mostrar un menú con las distintas opciones
