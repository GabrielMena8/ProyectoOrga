.data

mensajeInicio: .asciiz "Bienvenido al conversor de digitos!"
salto: .asciiz "\n"
mensaje: 
        .ascii "¿Que tipo numero deseas convertir?"
        .ascii "\n"
        .ascii "Elige una opcion"
        .ascii "\n"
        .ascii "1. Base 10"
        .ascii "\n"
        .ascii "2. Binario"
        .ascii "\n"
        .ascii "3. Octal"
        .ascii "\n"
        .ascii "4. Hexadecimal"
        .ascii "\n"
        .ascii "5. Binario Empaquetado"
        .ascii "\n"
        .ascii "6. Decimal con parte fraccionaria a Binario"
        .asciiz "\n"
mensajeDecimalFraccionario: .asciiz "Ingrese el numero decimal con parte fraccionaria (Ejemplo: 2.75): "
mensajeDos: .ascii "¿Hacia que tipo de numero deseas convertir?"
                .ascii "\n"
                .ascii "Elige una opcion"
                .ascii "\n"
                .ascii "1. Decimal"
                .ascii "\n"
                .ascii "2. Binario"
                .ascii "\n"
                .ascii "3. Octal"
                .ascii "\n"
                .ascii "4. Hexadecimal"
                .ascii "\n"
                .ascii "5. Binario Empaquetado"
                .asciiz "\n"
                    .asciiz "\n"
        .ascii "6. Decimal con parte fraccionaria"
        .asciiz "\n"
            

mensajeError:   .asciiz "Ha ingresado un valor incorrecto, por favor intente de nuevo ->"
mensajeDecimal: .asciiz "Ingrese el numero decimal que desea convertir (Ejemplo : +51 positivo, -51 negativo):"
mensajeBinario: .ascii "Ingrese el numero binario que desea convertir (Ejemplo: 1010 ) "
                .asciiz "Ej. 1010=> "

mensajeOctal: .ascii "Ingrese el numero octal que desea convertir: "
              .asciiz "Ej. 743=> "
mensajeHexadecimal: .asciiz "Ingrese el numero hexadecimal que desea convertir( Ejemplo : +A5, -FF ) "
mensajeBinarioEmpaquetado: .asciiz "Ingrese el numero binario empaquetado que desea convertir: "
mensajeResultado: .asciiz "El resultado de la conversion es: "
mensajeResultadoIgual: .asciiz "El numero es igual en ambos sistemas =>"
mensajeDebug: .asciiz "Debug de lectura"

numMenu: .space 1
numDecimal: .space 12
numBinario: .space 33
numHexadecimal: .space 10
numOctal: .space 10
debug_msg1: .asciiz "Valor decimal recibido: "
debug_msg2: .asciiz "Valor después de complemento a dos: "
debug_msg3: .asciiz "Resultado binario: "
newline: .asciiz "\n"

pilaEmpaquetado: .space 16  
##Macros de impresion
.macro imprimirTexto(%texto)
    li $v0 4
    la $a0 salto
    syscall


    li $v0 4
    la $a0 %texto
    syscall
.end_macro

##Macro de terminancion
.macro end
    li $v0 10
    syscall
.end_macro

##Macro de lectura de datos
.macro leerDatoMenu(%tipo)

  li $s0 %tipo
    beq $s0 0 leerDatoMenuInicio
    beq $s0 1 leerDatoDecimal 
    beq $s0 2 leerDatoBinario
    beq $s0 3 leerDatoOctal
    beq $s0, 4, leerDatoHexadecimal
    beq $s0, 5, leerDatoDecimalFraccionario

leerDatoMenuInicio:
    li $v0 8
    la $a0 numMenu
    li $a1 2
    syscall
    b endLeerDato

   ##Branches para cuando hacer otros guardados

    leerDatoDecimal:
       li $v0 8
        la $a0 numDecimal
        li $a1 13  
        syscall
    
    b endLeerDato

    leerDatoBinario:
    
        li $v0 8
        la $a0 numBinario
        li $a1 33
        syscall

    b endLeerDato
    leerDatoOctal:
        li $v0, 8
        la $a0, numOctal
        li $a1, 13  
        syscall
        b endLeerDato

    
    leerDatoHexadecimal:
            li $v0, 8
            la $a0, numHexadecimal
            li $a1, 13 
            syscall
            b endLeerDato


    leerDatoDecimalFraccionario:
    li $v0, 6  # Syscall para leer float
    syscall
    b endLeerDato

    endLeerDato:

.end_macro


.macro convertirDecimalConSigno(%registro, %resultado)
    li $t0, 0  # Iterador
    li %resultado, 0  # Resultado
    li $t3, 1  # Factor de signo (1 para positivo, -1 para negativo)
    
    # Verificar el signo
    lb $t1, %registro($t0)
    beq $t1, 43, signoPositivo  # ASCII '+' es 43
    beq $t1, 45, signoNegativo  # ASCII '-' es 45
    j procesarDigitos  # Si no hay signo, empezar a procesar dígitos directamente
    
    signoPositivo:
        addi $t0, $t0, 1  # Avanzar al siguiente carácter
        j procesarDigitos
    
    signoNegativo:
        li $t3, -1
        addi $t0, $t0, 1  # Avanzar al siguiente carácter
    
    procesarDigitos:
        lb $t1, %registro($t0)
        beqz $t1, finConversion
        beq $t1, 10, finConversion  # Nueva línea (ASCII 10)
        
        # Verificar si el carácter es un dígito válido
        blt $t1, 48, error_formato  # Menor que '0' (ASCII 48)
        bgt $t1, 57, error_formato  # Mayor que '9' (ASCII 57)
        
        mul %resultado, %resultado, 10 
        subi $t2, $t1, 48  # Convertir ASCII a valor numérico
        add %resultado, %resultado, $t2
        
        addi $t0, $t0, 1
        j procesarDigitos
    
    finConversion:
        mul %resultado, %resultado, $t3  # Aplicar el signo
        j fin
    
    error_formato:
        li $v0, 4
        la $a0, mensajeError
        syscall
        li %resultado, 0  # Establecer resultado a 0 en caso de error
    
    fin:
.end_macro

.macro convertirDecimalFraccionarioABinario(%decimal, %fraccion)
    # Convertir la parte entera
    move $t0, %decimal
    li $t1, 31  # Contador de bits para la parte entera
    li $t4, 0   # Contador para la posición en la cadena de salida
    
    # Bucle para la parte entera
bucle_entera:
    andi $t2, $t0, 0x80000000  # Obtener el bit más significativo
    srl $t2, $t2, 31  # Desplazar a la posición menos significativa
    addi $t2, $t2, 48  # Convertir a carácter ASCII
    sb $t2, numBinario($t4)  # Almacenar en la cadena de salida
    addi $t4, $t4, 1    # Avanzar en la cadena de salida
    sll $t0, $t0, 1     # Desplazar el número a la izquierda
    addi $t1, $t1, -1   # Decrementar el contador de bits
    bgez $t1, bucle_entera  # Continuar si aún hay bits por procesar

    # Agregar el punto decimal
    li $t2, 46  # ASCII para '.'
    sb $t2, numBinario($t4)
    addi $t4, $t4, 1

    # Convertir la parte fraccionaria
    move $t0, %fraccion
    li $t1, 8  # 8 bits para la parte fraccionaria
    li $t3, 0x800000  # Máscara inicial (2^23)

bucle_fraccion:
    sll $t0, $t0, 1     # Desplazar la fracción a la izquierda
    and $t2, $t0, $t3  # Verificar si el bit actual está encendido
    beqz $t2, bit_cero_fraccion
    li $t2, 49  # ASCII '1'
    j guardar_bit_fraccion
bit_cero_fraccion:
    li $t2, 48  # ASCII '0'
guardar_bit_fraccion:
    sb $t2, numBinario($t4)  # Almacenar en la cadena de salida
    addi $t4, $t4, 1    # Avanzar en la cadena de salida
    addi $t1, $t1, -1   # Decrementar el contador de bits
    bnez $t1, bucle_fraccion  # Continuar si aún hay bits por procesar

    sb $zero, numBinario($t4)  # Terminar la cadena con null
.end_macro


#Macro de conversion de string a digito 
.macro convertirStringADigito(%registro, %resultado)
    li $t0 0 ##Iterador
    li %resultado 0 
    ##Resultado
    bucle:
        ##Carga de caracter
        lb $t1 %registro($t0)
        ##Fin de cadena
        beqz $t1 endBucle
        beq $t1 0xA endBucle
        ## Para las decenas/centenas/
        mul %resultado %resultado 10 
        ##Conversion de caracter a digito
        subi $t2 $t1 0x30 
        ##Suma del digito
        add %resultado %resultado $t2
        ##Iterador
        addi $t0 $t0 1
        b bucle
        ##Debug de la conversion
    endBucle:
        ##Imprimir el resultado
        #li $v0 1
       # move $a0 %resultado 
        #syscall ##Debug quitar en version final
.end_macro

###Decimal a Todos los sistemas
.macro convertirDecimalABinario(%decimal)
    # Copiar el decimal y preparar registros
    move $t0, %decimal
    li $t1, 31  # Contador de bits
    li $t4, 0   # Contador para la posición en la cadena de salida
    
    # Verificar si el número es negativo
    bgez $t0, conversion
    # Si es negativo, no necesitamos convertir a complemento a dos
    # ya que el número ya está en esa representación

conversion:
    # Bucle principal de conversión
    li $t5, 0x80000000  # Máscara para obtener el bit más significativo
    
bucle_conversion:
    and $t2, $t0, $t5  # Obtener el bit actual
    beqz $t2, bit_cero
    li $t2, 49  # ASCII '1'
    j guardar_bit
bit_cero:
    li $t2, 48  # ASCII '0'
guardar_bit:
    sb $t2, numBinario($t4)  # Almacenar en la cadena de salida
    addi $t4, $t4, 1    # Avanzar en la cadena de salida
    
    srl $t5, $t5, 1     # Desplazar la máscara a la derecha
    addi $t1, $t1, -1   # Decrementar el contador de bits
    bgez $t1, bucle_conversion  # Continuar si aún hay bits por procesar

    sb $zero, numBinario($t4)  # Terminar la cadena con null
.end_macro


.macro convertirDecimalAHex(%decimal)
    ##Zona de variables y datos
        ##Copia del decimal
        move $t0 %decimal
        li $s0 0X0F ##Mascara para obtener el nibble
        li $t1 28 ##Contador de shift
        li $t4 0  ##Contador de digitos

    bucleDecimalAHex:
        bltz $t1 endBucleDecimalAHex
        srlv $t2 $t0 $t1 ##shifteamos tanto como el contador de shift indique
        and $t2 $t2 $s0  ##Obtenemos el nibble

        ##Cambio a cadena
            bge $t2 0xA letraHexadecimal

            digitoHexadecimal:
                addi $t2 $t2 0x30 ##Convertimos el nibble a caracter
                b finHexadecimal
        
            letraHexadecimal:
                addi $t2 $t2 55 ##Convertimos el nibble a caracter
                b finHexadecimal
            
            finHexadecimal:
                ##Guardamos el nibble en el string
                sb $t2 numHexadecimal($t4)
                ##Reducimos el contador de shift
                add $t1 $t1 -4
                ##Aumentamos el contador de digitos
                addi $t4 $t4 1
                
        b bucleDecimalAHex
    endBucleDecimalAHex:
.end_macro

.macro convertirDecimalAOctal(%decimal)
    # Copiar el decimal y preparar registros
    move $t0, %decimal
    li $t1, 30  # Contador de bits (empezamos desde el bit más significativo del octal)
    li $t4, 0   # Contador para la posición en la cadena de salida
    li $t5, 0   # Flag para indicar si hemos encontrado el primer dígito significativo
    
    # Manejar el signo
    bgez $t0, es_positivo
    li $t2, 45  # ASCII para '-'
    sb $t2, numOctal($t4)
    addi $t4, $t4, 1
    neg $t0, $t0  # Convertir a positivo para la conversión
    
es_positivo:
    # Manejar el caso especial de cero
    bnez $t0, no_es_cero
    li $t2, 48  # ASCII para '0'
    sb $t2, numOctal($t4)
    addi $t4, $t4, 1
    j fin_conversion

no_es_cero:
    # Bucle principal de conversión
    bucle_conversion:
        li $t6, 7  # Máscara para obtener los 3 bits menos significativos
        and $t2, $t0, $t6
        
        # Convertir a ASCII y guardar
        addi $t2, $t2, 48  # ASCII offset para '0'
        sb $t2, numOctal($t4)
        addi $t4, $t4, 1
        
        # Desplazar el número 3 bits a la derecha
        srl $t0, $t0, 3
        
        bnez $t0, bucle_conversion  # Continuar si aún hay bits por procesar

    # Invertir la cadena de caracteres
    li $t5, 0  # Inicio de la cadena
    addi $t6, $t4, -1  # Fin de la cadena
    
invertir_cadena:
    bge $t5, $t6, fin_conversion
    
    lb $t2, numOctal($t5)
    lb $t3, numOctal($t6)
    
    sb $t3, numOctal($t5)
    sb $t2, numOctal($t6)
    
    addi $t5, $t5, 1
    addi $t6, $t6, -1
    j invertir_cadena

fin_conversion:
    sb $zero, numOctal($t4)  # Terminar la cadena con null
.end_macro

#Convertir empaquetado
.macro decimalAEmpaquetado(%decimal)
    # Copiar el decimal a $t0
    move $t0, %decimal
    
    # Determinar el signo
    bgez $t0, positivo
    li $t8, 0  # Flag para negativo
    neg $t0, $t0  # Hacer positivo el número
    j procesarDigitos
positivo:
    li $t8, 1  # Flag para positivo

procesarDigitos:
    li $t2, 0  # Índice para la pila
    li $s1, 10  # Constante 10 para división

loopConstruccionPila:
    beqz $t0, finLoopConstruccionPila
    div $t0, $s1
    mflo $t0  # Cociente
    mfhi $t1  # Resto (dígito)
    sb $t1, pilaEmpaquetado($t2)
    addi $t2, $t2, 1
    j loopConstruccionPila

finLoopConstruccionPila:
    addi $t2, $t2, -1  # Ajustar índice
    li $t1, 0  # Resultado empaquetado

loopConversionBPD:
    bltz $t2, finLoopConversionBPD
    lb $t3, pilaEmpaquetado($t2)
    sll $t1, $t1, 4
    or $t1, $t1, $t3
    addi $t2, $t2, -1
    j loopConversionBPD

finLoopConversionBPD:
    # Añadir el signo
    sll $t1, $t1, 4
    beqz $t8, signoNegativo
    ori $t1, $t1, 0xC  # Positivo
    j finProceso
signoNegativo:
    ori $t1, $t1, 0xD  # Negativo

finProceso:
    # Imprimir el resultado en binario
    li $t7, 32  # Contador para 32 bits

imprimirBinario:
    li $t6, 4  # Contador para cada nibble (4 bits)
imprimirNibble:
    andi $t5, $t1, 0x80000000
    beqz $t5, imprimirCero
    li $v0, 11
    li $a0, '1'
    syscall
    j siguienteBit
imprimirCero:
    li $v0, 11
    li $a0, '0'
    syscall
siguienteBit:
    sll $t1, $t1, 1
    addi $t6, $t6, -1
    bnez $t6, imprimirNibble
    
    # Imprimir espacio entre nibbles
    li $v0, 11
    li $a0, ' '
    syscall
    
    addi $t7, $t7, -4
    bnez $t7, imprimirBinario
.end_macro






##Binario a Decimal

##Agregar la verificacion de la entrada

.macro verificarBinario()



.end_macro



.macro convertirStringADecimalConSigno(%direccion, %resultado)
    .data
        temp_word: .word 0
    .text
    la $t9, %direccion   # Cargamos la dirección de la etiqueta en $t9
    li $t0, 0            # Iterador
    li %resultado, 0     # Resultado
    li $t3, 0            # Flag para número negativo (0 = positivo, 1 = negativo)
    
    # Verificar si el primer carácter es un signo negativo
    lb $t1, ($t9)
    bne $t1, 45, bucle   # 45 es el código ASCII para '-'
    li $t3, 1            # Establecer flag de número negativo
    addi $t9, $t9, 1     # Mover al siguiente carácter

bucle:
    # Carga de carácter
    lb $t1, ($t9)
    
    # Fin de cadena
    beqz $t1, finConversion
    beq $t1, 0xA, finConversion
    
    # Para las decenas/centenas
    mul %resultado, %resultado, 10 
    
    # Conversión de carácter a dígito
    subi $t2, $t1, 0x30 
    
    # Suma del dígito
    add %resultado, %resultado, $t2
    
    # Avanzar al siguiente carácter
    addi $t9, $t9, 1
    j bucle

finConversion:
    # Si el número es negativo, multiplicar el resultado por -1
    beqz $t3, fin
    mul %resultado, %resultado, -1

fin:
    li $v0 1
     move $a0 %resultado 
    syscall ##Debug quitar en version final
.end_macro







.macro binarioADecimal(%binario, %resultado)
    li %resultado, 0
    li $t0, 0  # Iterador
    
    bucle_binario_decimal:
        lb $t1, %binario($t0)
        beqz $t1, fin_binario_decimal
        beq $t1, 0xA, fin_binario_decimal  # Nueva línea
        
        sll %resultado, %resultado, 1
        andi $t2, $t1, 0x01
        add %resultado, %resultado, $t2
        
        addi $t0, $t0, 1
        j bucle_binario_decimal
        
    fin_binario_decimal:
.end_macro

.macro binarioAOctal(%binario)
    binarioADecimal(%binario, $t7)  # Convertimos primero a decimal
    convertirDecimalAOctal($t7)  # Usamos la función existente
.end_macro

.macro binarioAHexadecimal(%binario)
    binarioADecimal(%binario, $t7)  # Convertimos primero a decimal
    convertirDecimalAHex($t7)  # Usamos la función existente
.end_macro

.macro binarioAEmpaquetado(%binario)
    binarioADecimal(%binario, $t7)  # Convertimos primero a decimal
    decimalAEmpaquetado($t7)  # Usamos la función existente
.end_macro






.macro octalADecimal(%octal, %resultado)
    li %resultado, 0
    li $t0, 0  # Iterador
    li $t3, 1  # Factor de signo (1 para positivo, -1 para negativo)
    
    # Verificar el signo
    lb $t1, %octal($t0)
    beq $t1, 43, signoPositivo  # ASCII '+' es 43
    beq $t1, 45, signoNegativo  # ASCII '-' es 45
    j procesarDigitos  # Si no hay signo, empezar a procesar dígitos directamente
    
    signoPositivo:
        addi $t0, $t0, 1  # Avanzar al siguiente carácter
        j procesarDigitos
    
    signoNegativo:
        li $t3, -1
        addi $t0, $t0, 1  # Avanzar al siguiente carácter
    
    procesarDigitos:
        lb $t1, %octal($t0)
        beqz $t1, finConversion
        beq $t1, 10, finConversion  # Nueva línea (ASCII 10)
        
        # Verificar si el carácter es un dígito octal válido
        blt $t1, 48, error_formato  # Menor que '0' (ASCII 48)
        bgt $t1, 55, error_formato  # Mayor que '7' (ASCII 55)
        
        mul %resultado, %resultado, 8
        subi $t2, $t1, 48  # Convertir ASCII a valor numérico
        add %resultado, %resultado, $t2
        
        addi $t0, $t0, 1
        j procesarDigitos
    
    finConversion:
        mul %resultado, %resultado, $t3  # Aplicar el signo
        j fin
    
    error_formato:
        li $v0, 4
        la $a0, mensajeError
        syscall
        li %resultado, 0  # Establecer resultado a 0 en caso de error
    
    fin:
.end_macro


.macro octalABinario(%octal)
    octalADecimal(%octal, $t7)  # Convertimos primero a decimal
    convertirDecimalABinario($t7)  # Usamos la función existente
.end_macro

.macro octalAHexadecimal(%octal)
    octalADecimal(%octal, $t7)  # Convertimos primero a decimal
    convertirDecimalAHex($t7)  # Usamos la función existente
.end_macro

.macro octalAEmpaquetado(%octal)
    octalADecimal(%octal, $t7)  # Convertimos primero a decimal
    decimalAEmpaquetado($t7)  # Usamos la función existente
.end_macro









.macro hexadecimalADecimal(%hex, %resultado)
    li %resultado, 0
    li $t0, 0  # Iterador
    li $t3, 1  # Factor de signo (1 para positivo, -1 para negativo)
    
    # Verificar el signo
    lb $t1, %hex($t0)
    beq $t1, 43, signoPositivo  # ASCII '+' es 43
    beq $t1, 45, signoNegativo  # ASCII '-' es 45
    j procesarDigitos  # Si no hay signo, empezar a procesar dígitos directamente
    
    signoPositivo:
        addi $t0, $t0, 1  # Avanzar al siguiente carácter
        j procesarDigitos
    
    signoNegativo:
        li $t3, -1
        addi $t0, $t0, 1  # Avanzar al siguiente carácter
    
    procesarDigitos:
        lb $t1, %hex($t0)
        beqz $t1, finConversion
        beq $t1, 10, finConversion  # Nueva línea (ASCII 10)
        
        # Multiplicar el resultado actual por 16
        sll $t4, %resultado, 4
        move %resultado, $t4
        
        # Convertir el carácter hexadecimal a su valor
        blt $t1, 58, digito  # Si es menor que ':', es un dígito
        blt $t1, 71, letraMayuscula  # Si es menor que 'G', es una letra mayúscula A-F
        blt $t1, 103, letraMinuscula  # Si es menor que 'g', es una letra minúscula a-f
        j error_formato
        
    digito:
        subi $t2, $t1, 48  # '0' = 48 en ASCII
        j sumarDigito
        
    letraMayuscula:
        subi $t2, $t1, 55  # 'A' = 65 en ASCII, 65 - 55 = 10
        j sumarDigito
        
    letraMinuscula:
        subi $t2, $t1, 87  # 'a' = 97 en ASCII, 97 - 87 = 10
        
    sumarDigito:
        add %resultado, %resultado, $t2
        
        addi $t0, $t0, 1
        j procesarDigitos
    
    finConversion:
        mul %resultado, %resultado, $t3  # Aplicar el signo
        j fin
    
    error_formato:
        li $v0, 4
        la $a0, mensajeError
        syscall
        li %resultado, 0  # Establecer resultado a 0 en caso de error
    
    fin:
.end_macro

.macro hexadecimalABinario(%hex)
    hexadecimalADecimal(%hex, $t7)  # Convertimos primero a decimal
    convertirDecimalABinario($t7)  # Usamos la función existente
.end_macro

.macro hexadecimalAOctal(%hex)
    hexadecimalADecimal(%hex, $t7)  # Convertimos primero a decimal
    convertirDecimalAOctal($t7)  # Usamos la función existente
.end_macro

.macro hexadecimalAEmpaquetado(%hex)
    hexadecimalADecimal(%hex, $t7)  # Convertimos primero a decimal
    decimalAEmpaquetado($t7)  # Usamos la función existente
.end_macro


.text


main:
    ##Zona de impresion inicial
        imprimirTexto(mensajeInicio)
        imprimirTexto(mensaje)

    ##Zona de lectura de datos ##   
        ##Registro de la opcion del menu
            leerDatoMenu(0)
        ##Conversion de string a digito del menu 
            convertirStringADigito(numMenu, $t3)

        ###Logica Condicional de la aplicacion 1
                beq $t3 1 decimal
                beq $t3 2 binario
                beq $t3 3 octal
                beq $t3 4 hexadecimal
                beq $t3 5 binarioEmpaquetado
                beq $t3, 6, decimalFraccionario
                beq $t3, 7, end
        ##Excepcion de opcion no valida
                ble $t3 1 exceptionNotOption
                bgt $t3, 7, exceptionNotOption
                

##Excepcion de opcion no valida
exceptionNotOption:
    imprimirTexto(mensajeError)
    b main 
    
decimal:
    imprimirTexto(mensajeDecimal)
    leerDatoMenu(1)
    convertirDecimalConSigno(numDecimal, $t7)  
    
    # Imprimir el resultado
    imprimirTexto(mensajeResultado)
    li $v0, 1
    move $a0, $t7
    syscall
    imprimirTexto(salto)
    
    # Continuamos con la selección de conversión
    imprimirTexto(mensajeDos)
    leerDatoMenu(0)
    convertirStringADigito(numMenu, $t8)
    
    # Decisión de conversión  
    beq $t8, 1, decimalAdecimal
    beq $t8, 2, decimalAbinario
    beq $t8, 3, decimalAOctal
    beq $t8, 4, decimalAHex
    beq $t8, 5, decimalAEmpaquetado

    decimalAdecimal:
        imprimirTexto(mensajeResultadoIgual)
        li $v0, 1
        move $a0, $t7
        syscall
        b end

    decimalAbinario:
    imprimirTexto(mensajeResultado)
    convertirDecimalABinario($t7)
    
    # Imprimir el resultado binario carácter por carácter
    li $t0, 0  # Inicializar contador
imprimir_binario:
    lb $t1, numBinario($t0)
    beqz $t1, fin_imprimir_binario
    li $v0, 11  # Syscall para imprimir carácter
    move $a0, $t1
    syscall
    addi $t0, $t0, 1
    j imprimir_binario
fin_imprimir_binario:
    
    imprimirTexto(salto)
    b end
            
    decimalAHex:
        imprimirTexto(mensajeResultado)
        convertirDecimalAHex($t7)
        imprimirTexto(numHexadecimal)
        b end

    decimalAOctal:
        imprimirTexto(mensajeResultado)
        convertirDecimalAOctal($t7)
        imprimirTexto(numOctal)
        b end

decimalAEmpaquetado:
    imprimirTexto(mensajeResultado)
    decimalAEmpaquetado($t7)  # Pasar el número decimal a la macro
    imprimirTexto(salto)
    b end




binario:
    imprimirTexto(mensajeBinario)
    leerDatoMenu(2)
    
    # Menú de conversión para binario
    imprimirTexto(mensajeDos)
    leerDatoMenu(0)
    convertirStringADigito(numMenu, $t8)
    
    # Decisión de conversión
    beq $t8, 1, binarioADecimal_conv
    beq $t8, 2, binarioABinario
    beq $t8, 3, binarioAOctal_conv
    beq $t8, 4, binarioAHex_conv
    beq $t8, 5, binarioAEmpaquetado_conv
    
    binarioADecimal_conv:
        binarioADecimal(numBinario, $t3)
        imprimirTexto(mensajeResultado)
        li $v0, 1
        move $a0, $t3
        syscall
        b end
        
    binarioABinario:
        imprimirTexto(mensajeResultadoIgual)
        imprimirTexto(numBinario)
        b end
        
    binarioAOctal_conv:
        binarioAOctal(numBinario)
        imprimirTexto(mensajeResultado)
        imprimirTexto(numOctal)
        b end
        
    binarioAHex_conv:
        binarioAHexadecimal(numBinario)
        imprimirTexto(mensajeResultado)
        imprimirTexto(numHexadecimal)
        b end
        
    binarioAEmpaquetado_conv:
        binarioAEmpaquetado(numBinario)
        imprimirTexto(mensajeResultado)
        move $a0, $t1  # Asumiendo que decimalAEmpaquetado guarda el resultado en $t1
        li $v0, 1
        syscall
        b end






    







octal:
    imprimirTexto(mensajeOctal)
    leerDatoMenu(3)  # Asumiendo que 3 es para octal en tu macro leerDatoMenu
    
    # Menú de conversión para octal
    imprimirTexto(mensajeDos)
    leerDatoMenu(0)
    convertirStringADigito(numMenu, $t8)
    
    # Decisión de conversión
    beq $t8, 1, octalADecimal_conv
    beq $t8, 2, octalABinario_conv
    beq $t8, 3, octalAOctal
    beq $t8, 4, octalAHex_conv
    beq $t8, 5, octalAEmpaquetado_conv
    
    octalADecimal_conv:
        octalADecimal(numOctal, $t8)
        imprimirTexto(mensajeResultado)
        li $v0, 1
        move $a0, $t8
        syscall
        b end
        
    octalABinario_conv:
        octalABinario(numOctal)
        imprimirTexto(mensajeResultado)
        imprimirTexto(numBinario)
        b end
        
    octalAOctal:
        imprimirTexto(mensajeResultadoIgual)
        imprimirTexto(numOctal)
        b end
        
    octalAHex_conv:
        octalAHexadecimal(numOctal)
        imprimirTexto(mensajeResultado)
        imprimirTexto(numHexadecimal)
        b end
        
    octalAEmpaquetado_conv:
        octalAEmpaquetado(numOctal)
        imprimirTexto(mensajeResultado)
        move $a0, $t1  # Asumiendo que decimalAEmpaquetado guarda el resultado en $t1
        li $v0, 1
        syscall
        b end


hexadecimal:
    imprimirTexto(mensajeHexadecimal)
    leerDatoMenu(4)  # Asumiendo que 4 es para hexadecimal en tu macro leerDatoMenu
    
    # Imprimir el valor hexadecimal leído para verificar
    imprimirTexto(numHexadecimal)
    
    # Convertir el hexadecimal a decimal inicialmente
    hexadecimalADecimal(numHexadecimal, $t7)
    
    # Imprimir el resultado de la conversión inicial para verificar
    imprimirTexto(mensajeResultado)
    li $v0, 1
    move $a0, $t7
    syscall
    imprimirTexto(salto)
    
    # Continuamos con la selección de conversión
    imprimirTexto(mensajeDos)
    leerDatoMenu(0)
    convertirStringADigito(numMenu, $t8)
    
    # Imprimir la opción seleccionada para verificar
    li $v0, 1
    move $a0, $t8
    syscall
    imprimirTexto(salto)
    
    # Decisión de conversión
    beq $t8, 1, hexadecimalADecimal_conv
    beq $t8, 2, hexadecimalABinario_conv
    beq $t8, 3, hexadecimalAOctal_conv
    beq $t8, 4, hexadecimalAHexadecimal
    beq $t8, 5, hexadecimalAEmpaquetado_conv
    
    # Si llegamos aquí, la opción no era válida
    imprimirTexto(mensajeError)
    b end
    
    hexadecimalADecimal_conv:
        # Ya tenemos el valor en $t7, solo imprimimos
        imprimirTexto(mensajeResultado)
        li $v0, 1
        move $a0, $t7
        syscall
        b end
        
    hexadecimalABinario_conv:
        hexadecimalABinario(numHexadecimal)
        imprimirTexto(mensajeResultado)
        imprimirTexto(numBinario)
        b end
        
    hexadecimalAOctal_conv:
        hexadecimalAOctal(numHexadecimal)
        imprimirTexto(mensajeResultado)
        imprimirTexto(numOctal)
        b end
        
    hexadecimalAHexadecimal:
        imprimirTexto(mensajeResultadoIgual)
        imprimirTexto(numHexadecimal)
        b end
        
    hexadecimalAEmpaquetado_conv:
        hexadecimalAEmpaquetado(numHexadecimal)
        imprimirTexto(mensajeResultado)
        move $a0, $t1  # Asumiendo que decimalAEmpaquetado guarda el resultado en $t1
        li $v0, 1
        syscall
        b end


    binarioEmpaquetado:
        imprimirTexto(mensajeBinarioEmpaquetado)
        b end


    
  decimalFraccionario:
    imprimirTexto(mensajeDecimalFraccionario)
    leerDatoMenu(5)  # Usar la nueva opción para leer float
    
    # $f0 contiene el float leído
    # Convertir la parte entera a entero
    cvt.w.s $f1, $f0
    mfc1 $t7, $f1  # $t7 contiene la parte entera

    # Calcular la parte fraccionaria
    cvt.s.w $f1, $f1
    sub.s $f2, $f0, $f1  # $f2 contiene la parte fraccionaria

    # Convertir la parte fraccionaria a un entero (multiplicando por 2^24)
    lui $t0, 0x4b00  # Carga la parte alta de 2^24 (16777216.0) en formato IEEE 754
    ori $t0, $t0, 0x0000  # Completa la parte baja (que es 0 en este caso)
    mtc1 $t0, $f3  # Mueve el valor a un registro de punto flotante
    mul.s $f2, $f2, $f3
    cvt.w.s $f2, $f2
    mfc1 $t8, $f2  # $t8 contiene la parte fraccionaria como un entero

    # Convertir a binario
    convertirDecimalFraccionarioABinario($t7, $t8)

    # Imprimir el resultado
    imprimirTexto(mensajeResultado)
    imprimirTexto(numBinario)
    imprimirTexto(salto)

    b end

    end:
        end




