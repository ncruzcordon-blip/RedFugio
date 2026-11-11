import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redfugio_frontend2/features/authentication/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}



class _LoginPageState extends State<LoginPage>{

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _LoginPresionado() async {
    // 1. Validamos que el formulario cumpla los requisitos de los campos
    if (formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      bool exito = await authProvider.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // Verificación de seguridad por si el widget se desmontó durante la petición asíncrona
      if (!mounted) return;

      if (exito) {
        // Redirigimos a la pantalla principal o dejamos que main.dart gestione el cambio
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        // Mostramos el mensaje de error que capturó tu AuthProvider o la API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              authProvider.errorMessage ?? 'Error al iniciar sesión. Inténtalo de nuevo.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context){

    final authProvider= context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 231, 231),
      body: SafeArea(
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Icon(Icons.phone_android, size: 40,),

              //Bienvenido!
              Text('Bienvenido!', 
                style:TextStyle(
                fontSize: 54),
              ),
              SizedBox(height: 10),
              Text('¡Te hemos extrañado!', 
                style: TextStyle(
                fontSize: 20,
                )
              ),
              SizedBox(height: 50),

//email textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 245, 245, 245),
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextFormField(
                      controller: emailController,

                      validator: (valor) {
                        if(valor == null || valor.trim().isEmpty){
                          return 'Requerido';
                        }
                        if(!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(valor.trim())){
                          return 'Correo electrónico no válido';
                        }
                        return null;
                      },

                      decoration: InputDecoration(
                      border: InputBorder.none, 
                      hintText: 'Email',
                    ),
                                ),
                  ),
                    
                ),
              ),
              
              SizedBox(height: 10),
              //password textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 245, 245, 245),
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: true,

                      validator: (valor) {
                        if(valor == null || valor.trim().isEmpty){
                          return 'Requerido';
                        }
                        return null;
                      },

                      decoration: InputDecoration(
                      border: InputBorder.none, 
                      hintText: 'Password',
                    ),
                                ),
                  ),
                    
                ),
              ),
              
            SizedBox(height: 10),

              Padding(
              padding: const EdgeInsetsGeometry.symmetric(horizontal: 25),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                onPressed: authProvider.isLoading ? null : _LoginPresionado, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 252, 110, 100),
                  padding: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Iniciar sesión',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18
                  ),)),
              ),),

            SizedBox(height: 10),
//CREAR CUENTA
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('¿Aún no tienes cuenta?',  
                    style: TextStyle(
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(onPressed: (){
                  Navigator.pushNamed(context, '/signUp');
                    }, 
                  child: const Text('Crear cuenta')
                  ),
                ],
              ) 
        ],),
          ),
      
        )
      )
    );
  }
}