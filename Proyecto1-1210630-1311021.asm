# Visualizador de Imagenes BMP
# By Edwin Franco 12-10630 
#	& Juan Ortiz 13-11021

# Instrucciones: 
# 1. Abrir bitmap display.
# 2. Establecer direccion base del mismo a 0x10040000 (heap).
# 3. Presionar boton connect to MIPS.
# 3. Compilar.
# 4. Ejecutar.

.data
	display: .space 0
	msg1: 	.asciiz "Ingrese la ruta donde se encuentra alojada la imagen: "
	msg2: 	.asciiz "Ha ocurrido un error al abrir el archivo"
	msg3:	.asciiz "Ha ocurrido un error al cargar el archivo"
	msg4: 	.asciiz "El archivo no es una imagen BMP"
	msg5: 	.asciiz "\n El tamaño del archivo, en bytes, es: "
	msg6: 	.asciiz "\n El ancho de la imagen, en pixeles, es: "
	msg7: 	.asciiz "\n La altura de la imagen, en pixeles, es: "
	msg8: 	.asciiz "\n El numero de bits usado para codificar el color de cada pixel es: "
	msg9: 	.asciiz "\n Ajuste el Bitmap Display de acuerdo a las dimensiones de la imagen. \n Presione Enter para continuar "
	msg10:	.asciiz "\n"
	prompt:	.asciiz "\n Introduzca una opcion y presione enter para continuar: \n 1. Cargar imagen.\n 2. Convertir a escala de grises.\n 3. Rotar 90 grados.\n 4. Flip Horizontal.\n 5. Flip Vertical.\n 6. Salir.\n ---> "
	
	path:	.space 1 			# direccion inicio ruta del archivo
	delay:	.space 1
	.align 2
	buffer:	.space 4			# direccion inicio lectura de la imagen	

#-------------------------------->-------------------------------->-------------------------------->
# Macro para imprimir cadena
.macro print_str (%str)
	li	$v0, 4
	la	$a0, %str
	syscall
.end_macro

# Macro para imprimir entero
.macro print_int(%int)
	li	$v0, 1
	add	$a0, $zero, %int
	syscall
.end_macro

# Recorrer el codigo hex de la imagen a traves de media palabras
.macro recorrerBuffer (%int)
	li 	$t0, %int
	lh 	$t1, buffer ($t0)
	addi 	$t0, $t0, 2
	lh  	$t2, buffer ($t0)	
	sll 	$t2, $t2, 16
	add 	$t1, $t1, $t2
.end_macro

# Recorrer el codigo hex de la imagen a traves de medias palabras y bytes
.macro getColorA (%int)
	add 	$t0, $zero, %int
	lhu 	$t1, buffer ($t0)
	addi 	$t0, $t0, 2
	lbu 	$t2, buffer ($t0)	
	sll 	$t2, $t2, 16
	add	$t1, $t1, $t2
.end_macro

# Recorrer el codigo hex de la imagen a traves de bytes y medias palabras
.macro getColorB (%int)
	add 	$t0, $zero, %int
	lbu 	$t1, buffer ($t0)
	addi 	$t0, $t0, 1
	lhu 	$t2, buffer ($t0)	
	sll 	$t2, $t2, 8
	add 	$t1, $t1, $t2
.end_macro

# Almacena pixel en Bitmap Display
.macro	paintalo (%int)
	add 	$a2, $a1, %int			# $a2 es la direccion del pixel a pintar
	sw 	$t1, 0 ($a2)			# guarda el color $t1 en la direccion $a2
.end_macro

# Extrae color de Bimap Display, convierte a blanco y negro y sobreescribe el original
.macro	paintalo2 (%int)
	add 	$a2, $a1, %int			# $a2 es la direccion del pixel a pintar
	lw  	$t1, 0 ($a2)			# $t1 = color RGB de $a2
	RGBtoBW ($t1)				# Metodo para convertir a blanco y negro
	paintalo (%int)				# Guarda nuevo color en Bitmap Display
.end_macro

# separar canales RGB
.macro ExtractRGB (%int)
	add 	$t1, $zero, %int		# tu vas a contener el canal rojo
	add 	$t2, $zero, %int		# tu vas a contener el canal verde
	add 	$t0, $zero, %int		# tu vas a contener el canal azul
	srl 	$t1, $t1, 16			# setear el canal rojo en el primer byte de $t1
	srl 	$t2, $t2, 8			# setear el canal verde en el primer byte de $t2
	
	# Guarda solo primer byte
	andi 	$t0, $t0, 0x000000FF
	andi 	$t1, $t1, 0x000000FF
	andi 	$t2, $t2, 0x000000FF
.end_macro

# Obtener escala grises (rgb2gray in MathLab).
# rgb2gray converts RGB values to grayscale values 
# by forming a weighted sum of the R, G, and B components:
# 0.2989 * R + 0.5870 * G + 0.1140 * B 
.macro RGBtoBW (%int)
	ExtractRGB (%int)
	mul 	$t1, $t1, 2989
	mul 	$t2, $t2, 5870
	mul 	$t0, $t0, 1140
	add 	$t1, $t1, $t2
	add 	$t1, $t1, $t0
	div 	$t1, $t1, 10000
	ComposeRGB
.end_macro

# Componer RGB
.macro ComposeRGB
	move 	$t2, $t1
	move 	$t0, $t1
	sll 	$t1, $t1, 16
	sll 	$t2, $t2, 8
	add 	$t1, $t1, $t2
	add 	$t1, $t1, $t0			# color obtenido en escala de grises
.end_macro

# Extrae pixel
.macro extraerPixel (%int)
	add 	$a2, $a1, %int			# $a2 es la direccion del pixel a mover
	lw  	$t8, 0 ($a2)			# $t8 = color RGB de $a2
.end_macro

# Mover Pixel
.macro	paintalo3 (%int)
	move 	$t1, $t8			# $t1 = $t8
	extraerPixel (%int)			# $t8 = pixel a eliminar se guarda en temporal 8
	add 	$a2, $a1, %int			# $a2 es la direccion del pixel a pintar
	sw 	$t1, 0 ($a2)			# mueve el pixel $t1 a la direccion $a2
.end_macro
#-------------------------------->-------------------------------->-------------------------------->
.text
main:
	jal 	inputFile
	j 	endProgram

# Solicitar ruta del archivo
inputFile:
	print_str (msg1)
	li 	$v0, 8
	la 	$a0, path
	li 	$a1, 25
	syscall

	#Encontrar salto de linea
	li 	$t0, 0
	findSL:
	lb 	$t1, path($t0)
	beq 	$t1, 10, delSL
	addi 	$t0, $t0, 1
	b findSL
	
delSL:
	sb 	$zero, path($t0)		#Sustituir salto de linea por caracter nulo	

openFile:
	# Abir el archivo
	li 	$v0, 13
	la 	$a0, path
	li 	$a1, 0
	li 	$a2, 0
	syscall
	bltz 	$v0, openError
	move 	$v1, $v0

	# Read input from file
	li 	$v0, 14
	move 	$a0, $v1			# file descriptor
	la 	$a1, buffer
	li 	$a2, 3145890
	syscall
	bltz 	$v0, readError

	# Read File Signarure
	li 	$t0, 0 
	lb 	$t1, buffer($t0)
	bne 	$t1, 66, fileNotAllow		# si no es B entonces branch to fileNotAllow
	addi 	$t0, $t0, 1
	lb 	$t1, buffer($t0)
	bne 	$t1, 77, fileNotAllow		# si no es M entonces branch to fileNotAllow

	# Read general information
	print_str (msg5)
	recorrerBuffer (2)			# guarda file size en $t1
	print_int ($t1)

	print_str (msg6)
	recorrerBuffer (18)			# $t1 guarda ancho imagen
	print_int ($t1)
	move 	$t6, $t1			# $t6 = ancho

	print_str (msg7)
	recorrerBuffer (22)			# $t1 guarda alto
	print_int ($t1)
	move 	$t7, $t1			# $t7 = alto

	# Primer pixel de la ultima fila de la imagen
	# viene dado por (altura - 1) * (anchura * 4)
	sll 	$t2, $t6, 2
	sub 	$t1, $t1, 1
	mul 	$t1, $t1, $t2
	move 	$s1, $t1

	print_str (msg8)
	recorrerBuffer (28)			# $t1 alacena Bits per pixel
	print_int ($t1)

	# Memoria Dinamica 1
	li 	$v0, 9				# allocate memory
	mul 	$s2, $t6, $t7
	sll	$a0, $s2, 2			# ancho * alto * 4 bytes
	syscall					# $v0 <-- address
	sb    	$v0, display

	# Memoria Dinamica 2
	li 	$v0, 9
	mul 	$a0, $s2, 3
	syscall
	sb    	$v0, display
	
	# Ajustar Bitmap Display
	print_str (msg9)
	li 	$v0, 8
	la 	$a0, delay
	li 	$a1, 16
	syscall
#-------------------------------->-------------------------------->-------------------------------->
# A pintar
paint:
	li  	$a1, 0x10040000			# direccion base bitmap display
	li 	$s2, 54				# en el byte 54 empiezan los colores
	move 	$t3, $s2
	move 	$t4, $s1			# pixel a pintar en iteracion actual
	move 	$s3, $s1			# fila en iteracion actual
	li 	$t5, 0
	sll	$s0, $t6, 2			# $s0 = ancho * 4

loop:
	bltz 	$s3, top
	getColorA ($t3)				# Consigue el color de la forma A
	paintalo ($t4)				# pinta el pixel actual
	addi 	$t3, $t3, 3			# ve hacia el siguiente color
	addi 	$t4, $t4, 4			# avanza un pixel en el bitmap display
	getColorB ($t3)				# Consigue el color de la forma B
	paintalo ($t4)				# pinta el pixel actual
	addi 	$t3, $t3, 3			# ve hacia el siguiente color
	addi 	$t4, $t4, 4			# avanza un pixel en el bitmap display
	addi 	$t5, $t5, 2			# en la fila actual nos movimos dos posiciones
	beq 	$t5, $t6, filUp			# si estamos en el ultimo pixel de la fila actual ve a filUP
	b 	loop

filUp:
	li 	$t5, 0 
	sub 	$s3, $s3, $s0			# sube una fila
	move 	$t4, $s3
	b 	loop
#-------------------------------->-------------------------------->-------------------------------->
# MENU
top:
	print_str (prompt)
	li 	$v0, 5
	syscall
	blez 	$v0, top
	li 	$t3, 6
	bgt 	$v0, $t3, top
	li 	$t3, 1
	beq 	$v0, $t3, paint
	li 	$t3, 2
	beq 	$v0, $t3, continue
	li 	$t3, 3
	beq 	$v0, $t3, continue2
	li 	$t3, 4
	beq 	$v0, $t3, continue3
	li 	$t3, 5
	beq 	$v0, $t3, continue4
	li 	$t3, 6
	beq 	$v0, $t3, continue5
#-------------------------------->-------------------------------->-------------------------------->
continue:
	move 	$t4, $s1			# pixel a repintar en iteracion actual
	move 	$s3, $s1			# fila en iteracion actual
	li 	$t5, 0
	sll 	$s0, $t6, 2			# $s0 = ancho * 4

# pintalo de blanco y negro
loop2:
	bltz 	$s3, top
	paintalo2 ($t4)				# re-pinta el pixel actual
	addi 	$t4, $t4, 4			# avanza un pixel en el bitmap display
	paintalo2 ($t4)				# re-pinta el pixel actual
	addi 	$t4, $t4, 4			# avanza un pixel en el bitmap display
	addi 	$t5, $t5, 2			# en la fila actual nos movimos dos posiciones
	beq 	$t5, $t6, filUp2		# si estamos en el ultimo pixel de la fila actual, ve a upFil
	b 	loop2

filUp2:
	li 	$t5, 0
	sub 	$s3, $s3, $s0			# sube una fila
	move 	$t4, $s3
	b 	loop2
#-------------------------------->-------------------------------->-------------------------------->
# A rotar 90!
continue2:
	sll 	$t9, $t6, 2
	sub 	$t9, $t9, 4			# $t9 esquina superior derecha del Bitmap Display
	add 	$t3, $s0, $s1
	sub 	$t3, $t3, 4			# $t3 esquina inferior derecha del Bitmap Display

	li 	$t5, 0				# contador j
	sll 	$s0, $t6, 2			# $s0 = ancho * 4
	sll 	$s2, $t6, 1			# $s2 = ancho * 2
	sub 	$t0, $s0, 4			# $t0 = ancho*4 - 4

loopExterno:
	bge 	$t5, $s2, top
	mul 	$k0, $t6, $t5			# $k0 = ancho * j
	li 	$t4, 0				# contador i

	sll 	$t2, $t5, 1
	sub 	$t2, $t0, $t2			# $t2 = (w*4) - 4 - (j*2) 
	b 	loopInterno

loopInterno:
	srl 	$k1, $t4, 2			# $k1 = i/4
	bge 	$t4, $t2, loopAux
	# Pixel correspondiente a la esquina inferior izquierda con un offset (casillas) segun iteracion
	add 	$s4, $s1, $t4
	sub 	$s5, $k0, $t5
	sub 	$s4, $s4, $s5			# $s4 = ($s1 + i) - (w*j - j)
	# Pixel correspondiente a la esquina inferior derecha con un offset (filas) segun iteracion
	mul 	$s5, $s0, $k1
	add 	$s6, $k0, $t5
	add 	$s5, $s5, $s6
	sub 	$s5, $t3, $s5			# $s5 = $t3 - ((w*4) * (i/4)) + (w*j + j)
	# Pixel correspondiente a la esquina superior derecha con un offset (casillas) segun iteracion
	sub 	$s6, $t9, $t4
	sub 	$s7, $k0, $t5
	add 	$s6, $s6, $s7			# $s6 = ($t9 - i) + ($k0 - j)

	extraerPixel ($s4)			# Pixel guardado en $t8
	paintalo3 ($s5)				# $s5 almacenado en $t8 y $s4 en $s5
	paintalo3 ($s6)  			# $s6 almacenado en $t8 y $s5 en $s6
	
	# liberados $s5 y $s6
	# Pixel correspondiente a la esquina superior izquierda con un offset (filas) segun iteracion
	mul 	$s5, $s0, $k1
	add 	$s6, $k0, $t5
	add 	$s7, $s5, $s6			# $s7 = (ancho*4 * i/4) + ($k0 + $t5)

	# continuemos rotando
	paintalo3 ($s7)				# $s7 almacenado en $t8 y $s6 en $s7
	paintalo3 ($s4)				# $s4 almacenado en $t8 y $s7 en $s4
	
	addi 	$t4, $t4, 4
	b 	loopInterno

loopAux:
	addi 	$t5, $t5, 4
	b 	loopExterno
#-------------------------------->-------------------------------->-------------------------------->
# Flip horizontal!
continue3:
	add 	$t3, $s0, $s1
	sub 	$t3, $t3, 4			# $t3 esquina inferior derecha del Bitmap Display

	sll 	$s0, $t6, 2			# $s0 = ancho * 4
	sll 	$s2, $t6, 1			# $s2 = ancho * 2
	
	li 	$t4, 0				#contador i
	li 	$t5, 0				#contador j

loopExterno2:
	bge 	$t5, $s0, top
	mul 	$k0, $t6, $t5			# $k0 = ancho * j
	li 	$t4, 0
	b 	loopInterno2

loopInterno2:
	bge 	$t4, $s2, loopAux2
	sub 	$s4, $s1, $k0
	add 	$s4, $s4, $t4			# $s4 = primer pixel ultima fila - (ancho * j) + i

	sub 	$s5, $t3, $k0
	sub 	$s5, $s5, $t4			# $s5 = esquina inferior derecha - (ancho * j) - i

	extraerPixel ($s4)			# Pixel guardado en $t8
	paintalo3 ($s5)				# $s5 almacenado en $t8 y $s4 en $s5
	paintalo3 ($s4)				# $s4 almacenado en $t8 y $s7 en $s4

	addi 	$t4, $t4, 4
	b 	loopInterno2

loopAux2:
	addi 	$t5, $t5, 4
	b 	loopExterno2
#-------------------------------->-------------------------------->-------------------------------->
# Flip vertical!
continue4:
	sll 	$s0, $t6, 2			# $s0 = ancho * 4
	sll 	$s2, $t6, 1			# $s2 = ancho * 2

	addi 	$t4, $zero, 0			#contador i
	addi 	$t5, $zero, 0			#contador j

loopExterno3:
	bge 	$t4, $s0, top
	li 	$t5, 0
	b 	loopInterno3

loopInterno3:
	bge 	$t5, $s2, loopAux3
	mul 	$k0, $t6, $t5
	sub 	$s4, $s1, $k0
	add 	$s4, $s4, $t4			# $s4 = primer pixel ultima fila - (ancho * j) + i

	add 	$s5, $k0, $t4			# $s5 = (ancho * j) + i

	extraerPixel ($s4)			# Pixel guardado en $t8
	paintalo3 ($s5)				# $s5 almacenado en $t8 y $s4 en $s5
	paintalo3 ($s4)				# $s4 almacenado en $t8 y $s7 en $s4

	addi 	$t5, $t5, 4
	b 	loopInterno3

loopAux3:
	addi 	$t4, $t4, 4
	b 	loopExterno3

#-------------------------------->-------------------------------->-------------------------------->
continue5:
	#Close the file 
	li 	$v0, 16
	move 	$a0, $v1			# file descriptor to close
	syscall
	jr 	$ra	
	
# Cerrar programa si falla al abrir imagen		
openError:
	print_str (msg2)
	j 	endProgram

# Cerrar programa si falla al leer imagen		
readError:
	print_str (msg3)
	j 	endProgram

# Cerrar programa si la imagen no es bmp		
fileNotAllow:
	print_str (msg4)
	j 	endProgram

# Finaliza Programa
endProgram: 
	li 	$v0, 10
	syscall
