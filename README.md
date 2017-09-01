# ViewerBMP
Visualizador de imagenes de mapa de bits

Programa desarrollado en el IDE MARS escrito en lenguaje ensamblador MIPS el cual permite:
• visualizar una imagen basada en mapa de bits (.BMP)
• convertir la imagen a Blanco y Negro
• Rotar 90° la imagen
• Flip vertical / horizontal

Para la visualización de la imagen, se hace uso de la herramienta Bitmap Display, para ello el usuario debe abrir el bitmap display y conectarlo a MIPS, entonces el programa:
• Solicita al usuario el nombre del archivo .bmp correspondiente a la imagen a renderizar.
• El usuario ajustar en el Bitmap Display el “Base address for display” a 0x 10000000 (global address).
• El archivo de imagen es abierto.
• Se lee la cabecera del archivo
• Comprobar que se trata de un archivo BMP
• Obtener el número de pixeles para el ancho y alto de la imagen
• Obtener el número de bits usados para el color de cada pixel
• Mostrar esta información al usuario para que pueda ajustar los valores en el Bitmap Display
(sólo trabaja con images con ancho y alto de 64, 128, 256, 512 y 1024 pixeles)
• Leer el resto del archivo BMP
• Mostrar un menú con las distintas opciones
