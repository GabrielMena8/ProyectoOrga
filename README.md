#Proyecto Organizacion del computador. 


Problemática


La junta directiva de la empresa Panita ha decidido que quiere ampliar su público y llegar a los programadores. La mejor manera que se les ha ocurrido para hacerlo es instalando un MARM (Mips Assembly Run Machine) en el sistema operativo KaiOS y ponerlo a correr un conversor de sistemas numéricos escrito en assembler de mips. Para ello ha contratado a la Universidad Metropolitana, la cual presume tener a los mejores desarrolladores del lenguaje. Los requerimientos del conversor son los siguientes: 


Las representaciones numéricas que deberán permitirse tanto para el valor introducido como para el resultado serán las siguientes.

Binario en Complemento a 2.

Ej: 0000 0000 0000 0000 1011 0011 0011 1100

No son necesarios los espacios

Decimal Empaquetado.

Ej: 0000 0000 0000 0000 0000 0101 0011 1100

No son necesarios los espacios

Base 10 (Cuando un número sea expresado en Base 10, será antecedido por el signo que le corresponda. "+" para números positivos, "-" para números negativos).

Ej: +32, -32

Octal (Cuando un número sea expresado en Octal, será antecedido por el signo que le corresponda. "+" para números positivos, "-" para números negativos)

Ej: +52, -52

Hexadecimal  (Cuando un número sea expresado en Hexadecimal, será antecedido por el signo que le corresponda. "+" para números positivos, "-" para números negativos)

Ej: +F3, -F3

Debe de haber una funcionalidad que le permita al usuario introducir números con parte fraccionaria y realizar las conversiones de decimal a binario con 8 bits asociados a la parte fraccional. 

Ej: 

entrada: 2.75

salida: 0000 0000 0000 0000  0000 0010.1100 0000

Como Panita tiene la memoria muy limitada, es esencial la reutilización de código, por lo que se deben de utilizar macros.


Los números deben ser ingresados como cadenas de caracteres.

El proyecto debe realizarse en grupos de máximo 3 personas.

No se permite el uso de syscall 34 ni de syscall 35 para imprimir números binarios o hexadecimales.
.
