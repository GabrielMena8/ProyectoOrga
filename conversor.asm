.data

mensajeInicio: .asciiz "Bienvenido al conversor de digitos!"
salto: .asciiz "\n"
mensaje: 
        .ascii "¿Que tipo numero deseas convertir?"
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
            

mensajeError:   .asciiz "Ha ingresado un valor incorrecto, por favor intente de nuevo ->"
mensajeDecimal: .asciiz "Ingrese el numero decimal que desea convertir:"
mensajeBinario: .ascii "Ingrese el numero binario que desea convertir: "
                .asciiz "Ej. 1010=> "

mensajeOctal: .asciiz "Ingrese el numero octal que desea convertir: "
mensajeHexadecimal: .asciiz "Ingrese el numero hexadecimal que desea convertir: "
mensajeBinarioEmpaquetado: .asciiz "Ingrese el numero binario empaquetado que desea convertir: "
mensajeResultado: .asciiz "El resultado de la conversion es: "
mensajeResultadoIgual: .asciiz "El numero es igual en ambos sistemas =>"
mensajeDebug: .asciiz "Debug de lectura"

numMenu: .space 1
numDecimal: .space 12
numBinario: .space 33
numHexadecimal: .space 10
numOctal: .space 10
pilaEmpaquetado: .space 7

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
        li $a1 12
        syscall
    
    b endLeerDato

    leerDatoBinario:
    
        li $v0 8
        la $a0 numBinario
        li $a1 33
        syscall

    b endLeerDato

    
    # beq %tipo 3 leerDatoOctal
    # beq %tipo 4 leerDatoHexadecimal
    # beq %tipo 5 leerDatoBinarioEmpaquetado

    endLeerDato:

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
        li $v0 1
        move $a0 %resultado 
        syscall ##Debug quitar en version final
.end_macro

###Decimal a Todos los sistemas
.macro convertirDecimalABinario(%decimal)
    ##Zona de variables y datos
        ##Copia del decimal
        move $t0 %decimal 
        li $t1 31 ##Contaddor de shift
        li $t4 0  ##Contador de digitos

    bucleDecimalABinario:
        bltz $t1 endBucleDecimalABinario
        srlv $t2 $t0 $t1 ##shifteamos tanto como el contador de shift indique
        and $t2 $t2 0x1  ##Obtenemos el bit menos significativo
        addi $t2 $t2 0x30 ##Convertimos el bit a caracter
        ##Guardamos el bit en el string
        sb $t2 numBinario($t4)
        ##Reducimos el contador de shift
        add $t1 $t1 -1
        ##Aumentamos el contador de digitos
        addi $t4 $t4 1

        b bucleDecimalABinario

    endBucleDecimalABinario:
        ##Imprimir el resultado
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
    ##Zona de variables y datos
        ##Copia del decimal
        move $t0 %decimal
        li $s0 0X07 ##Mascara para obtener el nibble
        li $t1 30 ##Contador de shift
        li $t4 0  ##Contador de digitos

    bucleDecimalAOctal:
        bltz $t1 endBucleDecimalAOctal
        srlv $t2 $t0 $t1 ##shifteamos tanto como el contador de shift indique
        and $t2 $t2 $s0  ##Obtenemos el nibble

        ##Cambio a cadena
            digitoOctal:
                addi $t2 $t2 0x30 ##Convertimos el nibble a caracter
                b finOctal
        
            finOctal:
                ##Guardamos el nibble en el string
                sb $t2 numOctal($t4)
                ##Reducimos el contador de shift
                add $t1 $t1 -3
                ##Aumentamos el contador de digitos
                addi $t4 $t4 1
                
        b bucleDecimalAOctal
    endBucleDecimalAOctal:
.end_macro

##Medio hecho, hay que terminar
.macro decimalAEmpaquetado(%decimal)
    ##Zona de variables y datos
        ##Copia del decimal
        move $t0 %decimal
        bltz $t0 casoNegativo
        b casoPositivo

         casoPositivo:
            li $t8 1 ##Flag de positivo
            b finEvaluacionSigno

         casoNegativo:   
            li $t8 0 ##Flag de negativo
            mul $t0 $t0 -1 ##Cambio de signo
            b finEvaluacionSigno

        finEvaluacionSigno:
            ##En t1 guardamos los digitos

            li $t2 0 ##Desplazamiento de la pila
            li $s1 10 ##Base de la conversion

            loopConstruccionPila:
                beqz $t0 endConstruccionPila

                div $t0 $s1 ##Division para obtener el residuo
                mfhi $t1 ##Obtenemos el residuo
                mflo $t0 ##Obtenemos el cociente

                sb $t1 pilaEmpaquetado($t2) ##Guardamos el residuo en la pila
                addi $t2 $t2 1 ##Aumentamos el desplazamiento
            
                b loopConstruccionPila
            endConstruccionPila:
                addi $t2 $t2 -1 ##Ajuste de desplazamiento
                li $t1 0
                ##Debug de la pila
                 ##Imprimir pila
            
                loopConversionBDP:
                    bltz $t2 endConversionBDP
                    lb $t6 pilaEmpaquetado($t2) ##Obtenemos el residuo
                    sll $t1 $t1 4 ##Multiplicamos el resultado por 10
                    or $t1 $t6 $t1 
                    addi $t2 $t2 -1 ##Ajuste de desplazamiento
                    b loopConversionBDP
                endConversionBDP:
                    ##Agregar el signo
                sll $t1 $t1 1 
                beqz $t8 casoFlagNegativo
                b casoFlagPositivo

                casoFlagPositivo:
                    li $t9 0xC
                    add $t1 $t1 $t9
                    b finFlags
                casoFlagNegativo:
                    li $t9 0xD
                    add $t1 $t1 $t9
                    b finFlags   
                finFlags:              
                ##Imprimir el resultado

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
                beq $t3 6 end
        ##Excepcion de opcion no valida
                ble $t3 1 exceptionNotOption
                bgt $t3 6 exceptionNotOption

##Excepcion de opcion no valida
exceptionNotOption:
    imprimirTexto(mensajeError)
    b main 
    
decimal:
                imprimirTexto(mensajeDecimal)
        ##Registro de la opcion del menu##
                leerDatoMenu(1)
            ##Conversion de string a digito el input
                convertirStringADigito(numDecimal, $t3)
                # Esta funcion no funciona convertirStringADecimalConSigno(numDecimal, $t3)
                

            ##Seleccion de la conversion
                imprimirTexto(mensajeDos)
                leerDatoMenu(0)
                convertirStringADigito(numMenu, $t8) 

            ##Decision de conversion  
            beq $t8 1 decimalAdecimal
            beq $t8 2 decimalAbinario
            beq $t8 3 decimalAOctal
            beq $t8 4 decimalAHex
            beq $t8 5 decimalAEmpaquetado

    decimalAdecimal:
            imprimirTexto(mensajeResultadoIgual)
            # li $v0 1
            # move $a0 $t3
            # syscall
        b end


    decimalAbinario:
            imprimirTexto(mensajeResultado)
            convertirDecimalABinario($t3)
            imprimirTexto(numBinario)
        b end
            

    decimalAHex:
            imprimirTexto(mensajeResultado)
            convertirDecimalAHex($t3)
            imprimirTexto(numHexadecimal)
        b end

    decimalAOctal:
            imprimirTexto(mensajeResultado)
            convertirDecimalAOctal($t3)
            imprimirTexto(numOctal)
        b end

    decimalAEmpaquetado:
            imprimirTexto(mensajeResultado)
            decimalAEmpaquetado($t3)
            imprimirTexto(pilaEmpaquetado)
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
    b end
hexadecimal:
    imprimirTexto(mensajeHexadecimal)
    b end
binarioEmpaquetado:
    imprimirTexto(mensajeBinarioEmpaquetado)
    b end
end:
    end




