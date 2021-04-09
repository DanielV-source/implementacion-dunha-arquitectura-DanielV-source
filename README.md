# Sistema de login de usuarios

Sistema de login de usuarios simple escrito en Elixir. Este sistema está enfocado a un sistema cliente-servidor. Al entregar la práctica estarán los txt que se utilizan como bd eliminados, se crean automáticamente al enviar las peticiones. Esto implica que la cuenta root (en el sistema la cuenta root por defecto tiene privilegios adicionales) no venga creada por defecto, para crearla seguir los comandos de abajo. También vienen adjuntos los comandos de la práctica y algunas pruebas de error. 

Todas las funciones a continuación han sido probadas con el compilador interactivo de Elixir (iex).

Los txt que se usarán como bd son: 

	-> "db.txt": Contiene el nombre de usuario, el email y la password.

	-> "info.txt": Contiene el nombre de usuario, el email, el nombre, los apellidos y el número de teléfono. 

	-> "sessions.txt": Contiene el nombre de usuario o el email del usuario de la sesión actual.

Usuario con privilegios por defecto: root
Autor: Daniel Vicente Ramos (daniel.vicente.ramos@udc.es)

## Features

- Registro y login de usuarios
- Uso de sesiones, que permitirán o impedirán el uso de ciertas peticiones del cliente.
- Cambiar información de perfil
- Cambiar contraseña
- Eliminar cuenta

## Comandos

Estos comandos son completamente funcionales.

| Comando | Descripción |
| ------ | ------ |
| Client.signup("test", "test@domain", "test") | Registra al usuario "test" en la bd |
| Client.signup("root", "root@root", "root") | Registra al usuario "root" en la bd. El usuario root dispone de privilegios por defecto. |
| ------ | ------ |
| Client.login("test", "test") | Inicia sesión en la cuenta "test" |
| Client.login("test@domain", "test") | Inicia sesión en la cuenta "test" |
| Client.login("root", "root") | Inicia sesión en la cuenta "root" |
| Client.login("root@root", "root") | Inicia sesión en la cuenta "root" |
| ------ | ------ |
| Client.changeInfo("Test", "testeando", "+34 #00 #0 #0 #0") | Actualiza la información del usuario actual. Al hacer esto se puede visualizar la información de este usuario mediante el comando "Client.getInfo()" |
| Client.changeInfo("test", "Test", "testeando", "+34 #00 #0 #0 #0") | Actualiza la información del usuario "test", para realizar esto **es necesario estar en una cuenta con privilegios** (por ejemplo "**root**").  | 
| Client.changeInfo("test@domain", "Test", "testeando", "+34 #00 #0 #0 #0") | Actualiza la información del usuario con email "test@domain", para realizar esto **es necesario estar en una cuenta con privilegios** (por ejemplo "**root**").  |
| ------ | ------ |
| Client.getInfo() | Muestra la información del usuario de la sesión actual, si no se ha añadido información mostrará un error, mirar en **Test y errores comunes**. | 
| Client.getInfo("test") | **No requiere estar en una sesión para ver esta información**. Muestra la información del usuario "test". |
| ------ | ------ |
| Client.changePass("newpass") | Actualiza la contraseña del usuario de la sesión actual a "newpass" |
| Client.changePass("test", "newpass") | Actualiza la contraseña del usuario "test" a "newpass", para realizar esto **es necesario estar en una cuenta con privilegios** (por ejemplo "**root**") |
| Client.changePass("test@domain", "newpass") | Actualiza la contraseña del usuario con email "test@domain" a "newpass", para realizar esto **es necesario estar en una cuenta con privilegios** (por ejemplo "**root**") |
| ------ | ------ |
| Client.signout() | Cierra la sesión actual |
| ------ | ------ |
| Client.remAccount() | Elimina de la bd todo el contenido del usuario de la sesión actual |
| Client.remAccount("test") | Elimina de la bd todo el contenido del usuario "test", para realizar esto **es necesario estar en una cuenta con privilegios** (por ejemplo "**root**") |

#### Tests y errores comunes

| Comando | Descripción del error |
| ------ | ------ |
|- Client.signup("tes", "test@domain", "test") | - No funciona, username no válido |
|- Client.signup("test", "test", "test") 	 	  | - No funciona, email no válido |
|- Client.signup("test", "test@domain", "tes") | - No funciona, pass no válida |

> Condiciones (Client.signup(usuario, email, password)) : 
> - El usuario tiene que tener una longitud mínima de 4 carácteres y máxima 15 carácteres
> - El email tiene que usar el formato (algo)@(algo)
> - La password tiene que tener una longitud mínima de 4 carácteres y máxima 15 carácteres

| Comando | Descripción del error |
| ------ | ------ |
| Client.login("test", "tes") | - No funciona, password incorrecta |
| Client.login("test@domain", "tes") | - No funciona, pass incorrecta |
| Client.login("tes@domain", "test") | - No funciona, email incorrecto |
| Client.login("tes", "test") | - No funciona, username incorrecto |

> Condiciones (Client.login(usuario/email, password)) :
> - El usuario o email no puede estar vacío
> - Que coincidan usuario o email y password con la base de datos

| Comando | Descripción del error |
| ------ | ------ |
| Client.getInfo() | **Es necesario estar en una sesión para poder realizar esta acción**. Si el usuario no ha añadido información mediante el comando "Client.changeInfo(name, last_name, phone_number)", lanzará excepción ya que no puede recuperar la información de la bd |
> Condiciones (Client.getInfo()):
> - Que exista previamente una sesión mediante el comando "Client.login(usuario/email, password)", para poder consultar la información del usuario de la sesión actual en la bd. 

| Comando | Descripción del error |
| ------ | ------ |
| Client.getInfo("test") | Si el usuario "test" no ha añadido información mediante el comando "Client.changeInfo(name, last_name, phone_number)", lanzará excepción ya que no puede recuperar la información de la bd |
> Condiciones (Client.getInfo(usuario)):
> - Que el usuario "user" exista en la bd.

| Comando | Descripción del error |
| ------ | ------ |
| Client.changeInfo("", "testeando", "+34 #00 #0 #0 #0") | **Es necesario estar en una sesión para poder realizar esta acción**. Alguno de los campos no cumple las condiciones  |
> Condiciones (Client.changeInfo(nombre, apellidos, num_telefono)):
> - Que exista previamente una sesión mediante el comando "Client.login(usuario/email, password)", para poder consultar la información del usuario de la sesión actual en la bd. 
> - Que ninguno de los campos esté vacío.

| Comando | Descripción del error |
| ------ | ------ |
| Client.changeInfo("test", "Test", "testeando", "+34 #00 #0 #0 #0") | **Es necesario estar en una sesión para poder realizar esta acción**. Alguno de los campos no cumple las condiciones  |
> Condiciones (Client.changeInfo(usuario, nombre, apellidos, num_telefono)):
> - **Que el usuario no disponga de los permisos necesarios**. (Usar por ejemplo cuenta "root")
> - Que exista el usuario "usuario" en la bd
> - Que exista previamente una sesión mediante el comando "Client.login(usuario/email, password)", para poder consultar la información del usuario de la sesión actual en la bd. 
> - Que ninguno de los campos esté vacío.

| Comando | Descripción del error |
| ------ | ------ |
| Client.changePass("newPass") | **Es necesario estar en una sesión para poder realizar esta acción**. Alguno de los campos no cumple las condiciones |
> Condiciones (Client.changePass(new_password)):
> - Que exista previamente una sesión mediante el comando "Client.login(usuario/email, password)", para poder consultar la información del usuario de la sesión actual en la bd. 
> - La new_password tiene que tener una longitud mínima de 4 carácteres y máxima 15 carácteres

| Comando | Descripción del error |
| ------ | ------ |
| Client.changePass("test", "newPass") | **Es necesario estar en una sesión para poder realizar esta acción**. Alguno de los campos no cumple las condiciones. La nueva contraseña no tiene restricciones de longitud en caso de pérdida, el usuario root puede restablecerla con una más simple para que luego la cambie el usuario. |
> Condiciones (Client.changePass(usuario, new_password)):
> - **Que el usuario no disponga de los permisos necesarios**. (Usar por ejemplo cuenta "root")
> - Que exista el usuario "usuario" en la bd
> - Que exista previamente una sesión mediante el comando "Client.login(usuario/email, password)", para poder consultar la información del usuario de la sesión actual en la bd. 

| Comando | Descripción del error |
| ------ | ------ |
| Client.signout() | **Es necesario estar en una sesión para poder realizar esta acción**. Alguno de los campos no cumple las condiciones. |
> Condiciones (Client.signout()):
> - Que exista previamente una sesión mediante el comando "Client.login(usuario/email, password)", para poder consultar la información del usuario de la sesión actual en la bd. 

| Comando | Descripción del error |
| ------ | ------ |
| Client.remAccount() | **Es necesario estar en una sesión para poder realizar esta acción**. Alguno de los campos no cumple las condiciones. |
> Condiciones (Client.remAccount()):
> - Que exista previamente una sesión mediante el comando "Client.login(usuario/email, password)", para poder consultar la información del usuario de la sesión actual en la bd. 

| Comando | Descripción del error |
| ------ | ------ |
| Client.remAccount("test") | **Es necesario estar en una sesión para poder realizar esta acción**. Alguno de los campos no cumple las condiciones. |
> Condiciones (Client.remAccount(usuario)):
> - **Que el usuario no disponga de los permisos necesarios**. (Usar por ejemplo cuenta "root")
> - Que exista el usuario "usuario" en la bd
> - Que exista previamente una sesión mediante el comando "Client.login(usuario/email, password)", para poder consultar la información del usuario de la sesión actual en la bd. 
