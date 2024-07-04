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
mensajeError: "Ha ingresado un valor incorrecto, por favor intente de nuevo ->"
mensajeDecimal: .asciiz "Ingrese el numero decimal que desea convertir: "
mensajeBinario: .asciiz "Ingrese el numero binario que desea convertir: "
mensajeOctal: .asciiz "Ingrese el numero octal que desea convertir: "
mensajeHexadecimal: .asciiz "Ingrese el numero hexadecimal que desea convertir: "
mensajeBinarioEmpaquetado: .asciiz "Ingrese el numero binario empaquetado que desea convertir: "
mensajeResultado: .asciiz "El resultado de la conversion es: "

numMenu: .space 2
numDecimal: .space 10


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

beq %tipo 0 leerDatoMenuInicio

leerDatoMenuInicio:
    li $v0 8
    la $a0 numMenu
    li $a1 2
    syscall
    b endLeerDato

   ##Branches para cuando hacer otros guardados
    beq %tipo 1 leerDatoDecimal 
    

    leerDatoDecimal:
        li $v0 8
        la $a0 numDecimal
        li $a1 10
        syscall
        b endLeerDato
    

    # beq %tipo 2 leerDatoBinario
    # beq %tipo 3 leerDatoOctal
    # beq %tipo 4 leerDatoHexadecimal
    # beq %tipo 5 leerDatoBinarioEmpaquetado

    endLeerDato:

.end_macro


#Macro de conversion de string a digito 
.macro convertirStringADigito(%registro)
    li $t0 0 ##Iterador
    li $t3 0 ##Resultado

    bucle:
        lb $t1 %registro($t0)
        beqz $t1 endBucle
        mul $t3 $t3 10 ## Para las decenas/centenas/
        subi $t2 $t1 0x30  ##Conversion de caracter a digito
        add $t3 $t3 $t2
        addi $t0 $t0 1

        ##Debug 
        li $v0 1
        move $a0 $t3
        syscall

        b bucle
    endBucle:
        ##Imprimir el resultado
        
.end_macro



.text


main:
    ##Zona de impresion inicial
    imprimirTexto(mensajeInicio)
    imprimirTexto(mensaje)
    ##Zona de lectura de datos ##

    
    ##Registro de la opcion del menu
    li $t3 0 
    leerDatoMenu($t3)
    ##Conversion de string a digito del menu 
    convertirStringADigito(numMenu)

    ###Logica Condicional de la aplicacion
        beq $t3 1 decimal
        beq $t3 2 binario
        beq $t3 3 octal
        beq $t3 4 hexadecimal
        beq $t3 5 binarioEmpaquetado
        beq $t3 6 end
    b exceptionNotOption

##Excepcion de opcion no valida
exceptionNotOption:
    imprimirTexto(mensajeError)
    b main 
    
decimal:
    imprimirTexto(mensajeDecimal)

    ##Registro de la opcion del menu##
    li $t3 1
    leerDatoMenu($t3)

    ##Conversion de string a digito del menu
    convertirStringADigito(numDecimal)

    ##Impresion del resultado
    imprimirTexto(mensajeResultado)
    






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




