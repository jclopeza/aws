# Redes privadas virtuales con VPC

## Creación de una VPC
Creamos una red de nombre `calculator-dev` con un CIDR block igual a 192.168.0.0/16. Nos devuelve un id = vpc-0297b2ffe5d8d1af9

## Creación de subredes dentro de la VPC
Se recomienda que cada subred esté en una zona de disponibilidad distinta. Creamos una subred de nombre `calculator-dev-private-1`, seleccionamos la zona de disponibilidad `us-east-1a` y el CIDR Block = 192.168.1.0/24. Nos devuelve el id = subnet-01690afd5d9a96e6e. Creamos tres subredes más, una privada y otras dos más públicas, todas en zonas de disponibilidad distintas.

En la subred pública, habilitar la autoasignación de IP públicas. De esta forma todas las máquinas que levantemos en esa subred tendrá una IP pública.

## Internet Gateway
Cada VPC necesita un internet gateway para poder salir a internet. Creamos uno de nombre `calculator-dev`. Lo asociamos a nuestra VPC y esto permitirá a la VPC salir a internet. Cada VPC sólo puede atachado un Internet Gateway.

## Tablas de rutas de la VPC
Cada VPC tiene sus propias tablas de rutas. Podemos verlo si vamos a `Route Tables`. Y estas tablas de rutas se pueden asociar a subnets. Por ejemplo, podemos decir en una tabla de rutas cómo salir a internet, pero si luego esa tabla de rutas no la asociamos a una subnet, esa subnet no podrá salir a internet.

Vamos a crear dos tablas de rutas, una para la red pública y otra para la red privada. Al crearlas, las tenemos que asociar a la VPC.

* calculator-dev-private
* calculator-dev-public

Por defecto, todas las máquinas que levantemos en subnets, se pueden ver entre ellas. Editamos la tabla de rutas `calculator-dev-public` y añadimos una ruta, decimos que todo lo que vaya a 0.0.0.0/0 (a cualquier dirección que no sea la local ya definida), que lo mande por el gateway que hemos creado. A la otra tabla de rutas no le añadimos esta salida a internet.

De esta forma, las subnets que tengan asociada la tabla de rutas `calculator-dev-public` tendrán salida a internet, y las subnets que tengan asociada la tabla de rutas `calculator-dev-private` no tendrán salida a internet.

## Asociación de tablas de rutas a subredes
Editamos las 4 subredes y a cada una le asociamos su tabla de rutas correspondiente.

## Network ACL
Sería una capa extra de seguridad para nuestra VPC y nuestras subredes. Aquí podemos definir rutas de entrada y rutas de salida.

La principal diferencia entre un Security Group y una Network ACL es que el Security Group se asigna por instancia y no por subred, mientras que el Network ACL se asigna por subred. Y defines a dónde pueden acceder las máquinas que están en esa subred y quién puede acceder a las máquinas que están en esa subred. Mientras que en un Security Group dices quién puede acceder a esa instancia y a dónde puede acceder esa instancia.

Ejemplo, podemos permitir el acceso a una subred sólamente por el puerto 3306 de MySQL. También hay que tener en cuenta que tenemos que permitir el acceso explícito a todos los puertos externos a los que queramos acceder desde una subred.

## Creamos instancias EC2
Y asociamos a una la subred pública y a otra la subred privada. Asociamos el mismo security group, pero para acceder a la instancia que está dentro de la red privada, tendremos que hacer un salto.

La instancia pública tendrá una ip pública y una ip privada. Pero la instancia privada sólo tendrá una ip privada.

Para acceder a la otra máquina, accedemos mediante la primera que es pública.