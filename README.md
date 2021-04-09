								*******************************
								*SISTEMA DE LOGIN DE USUARIOS *
								*******************************

	Sistema de login de usuarios simple escrito en Elixir. Al entregar la práctica
estarán los txt que se utilizan como bd eliminados, se crean automáticamente al enviar
las peticiones. Esto implica que la cuenta root (en la aplicación la cuenta root por defecto tiene privilegios adicionales) no venga creada por defecto, para crearla
seguir comandos de abajo. También vienen adjuntos los comandos de la práctica y algunas pruebas de error. 

Los txt que se usarán como bd son: 

	-> db.txt (Contiene el nombre de usuario, el email y la password)

	-> info.txt (Contiene el nombre de usuario, el email, el nombre, los apellidos y el número de teléfono) 

	-> sessions.txt (Contiene el nombre de usuario o el email del usuario de la sesión actual).


Usuario con privilegios por defecto: root

Autor: Daniel Vicente Ramos (daniel.vicente.ramos@udc.es)

==================================================================================================
				COMANDOS						||				DESCRIPCIÓN
==================================================================================================

Client.signup("tes", "test@gmail.com", "test")  //-> No funciona, username no válido
Client.signup("test", "test", "test") 	 	    //-> No funciona, email no válido
Client.signup("test", "test@gmail.com", "tes")  //-> No funciona, pass no válida
												// Condiciones:
												//Username = long mín 4 y máx 15 
												//Email = cualquier correo que contenga (algo)@(algo)
												//Pass = long mín 4 y máx 15


Client.signup("test", "test@gmail.com", "test") //-> Funciona (Usuario test)
Client.signup("root", "root@gmail.com", "root") //-> Funciona (Usuario root) 
												//*La cuenta root tiene privilegios adicionales*

Client.login("test", "tes")					    //-> No funciona, pass incorrecta
Client.login("test@gmail.com", "tes")			//-> No funciona, pass incorrecta
Client.login("tes@gmail.com", "test")  		    //-> No funciona, email incorrecto
Client.login("tes", "test")  		  			//-> No funciona, username incorrecto

Client.login("test", "test") 					//-> Funciona (Inicia sesión usuario test)
Client.login("root", "root") 					//-> Funciona (Inicia sesión usuario root)

Client.getInfo()								//-> Funciona 
												//(Obtiene la información del usuario actual)
												  Ejemplo: 
													>Username: test 
													>Email: test@gmail.com 
													>Name: (*)
													>Last Name: (*)
													>Phone Number: (*)

												//(*) Si no se han introducido los campos anteriores en 
												//la aplicación mostrará un error al recuperar la información, 
												//advirtiendo que es necesario hacer un 
												//"Client.changeInfo(name, last_name, phone_number)" para que 
												//se muestren

Client.changeInfo("Test", "testeando", "+34 #00 #0 #0 #0") 
												//-> Funciona, 
												//(Actualiza la información del usuario en la //sesión actual)

Client.changeInfo("root", "Test", "testeando", "+34 #00 #0 #0 #0") 
												//-> Funciona, 
												//(Actualiza la información del usuario "root" 
												//si dispone de los privilegios pertinentes)

Client.changePass("newpass") 					//->Funciona,
												//(Cambia la contraseña del usuario actual en sesión)

Client.changePass("test", "newpass")     		//->Funciona,
												//(Cambia la contraseña del usuario "test"
												//si dispone de los privilegios pertinentes)

Client.getInfo("test") 						    //-> Funciona 
							                    //(Público puedes ver el perfil de un usuario, "test" en este caso, 
												//no es necesario estar en una sesión)


Client.signout()								//-> Funciona,
												//(Cierra la sesión actual)

Client.remAccount()							    //-> Funciona,
												//(Elimina toda la información del usuario y 
												//termina la sesión //actual)

Client.remAccount("test")						//-> Funciona,
												//(Elimina toda la información del usuario 
												//"test" si se dispone de los privilegios pertinentes)
=================================================================================================
												
y multitud de excepciones y errores manejados