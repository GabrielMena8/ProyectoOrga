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
            

mensajeError: "Ha ingresado un valor incorrecto, por favor intente de nuevo ->"
mensajeDecimal: .asciiz "Ingrese el numero decimal que desea convertir: "
mensajeBinario: .asciiz "Ingrese el numero binario que desea convertir: "
mensajeOctal: .asciiz "Ingrese el numero octal que desea convertir: "
mensajeHexadecimal: .asciiz "Ingrese el numero hexadecimal que desea convertir: "
mensajeBinarioEmpaquetado: .asciiz "Ingrese el numero binario empaquetado que desea convertir: "
mensajeResultado: .asciiz "El resultado de la conversion es: "
mensajeResultadoIgual: .asciiz "El numero es igual en ambos sistemas =>"
mensajeDebug: .asciiz "Debug de lectura"

numMenu: .space 1
numDecimal: .space 10
numBinario: .space 33
numHexadecimal: .space 10

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

leerDatoMenuInicio:
    li $v0 8
    la $a0 numMenu
    li $a1 2
    syscall
    b endLeerDato

   ##Branches para cuando hacer otros guardados

    leerDatoDecimal:
        ##Debug de si entra aca
        li $v0 8
        la $a0 numDecimal
        li $a1 12
        syscall
    
    b endLeerDato
    

    # beq %tipo 2 leerDatoBinario
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
                bgt $t3 6  exceptionNotOption

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
        ##Seleccion de la conversion
            imprimirTexto(mensajeDos)
            leerDatoMenu(0)
            convertirStringADigito(numMenu, $t8) 

        ##Decision de conversion  
        beq $t8 1 decimalAdecimal
        beq $t8 2 decimalAbinario
        beq $t8 4 decimalAHex

decimalAdecimal:
        imprimirTexto(mensajeResultadoIgual)
        li $v0 1
        move $a0 $t3
        syscall
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
b end





binario:
    imprimirTexto(mensajeBinario)
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




