import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redfugio_frontend2/features/authentication/providers/auth_provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp>{

  final BoxDecoration estiloRecuadro = BoxDecoration(
          color: const Color.fromARGB(255, 245, 245, 245),
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
  );

  final InputDecoration estiloTexto = InputDecoration(
    border: InputBorder.none,
    hintStyle: TextStyle(color: const Color.fromARGB(255, 43, 43, 43),
    fontSize: 15),
  );

  String seleccion = '';

  final formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();
  final entidadController = TextEditingController();

  bool get formularioCompleto {
    return nombreController.text.trim().isNotEmpty;
  }

  bool errorSeleccion = false;

  @override
  void dispose() {
    nombreController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    entidadController.dispose();
    super.dispose();
  }

  /// Método para ejecutar el registro con tu AuthProvider
  void _registroPresionado() async {
    // 1. Comprobamos la selección del tipo de cuenta
    if (seleccion.isEmpty) {
      setState(() {
        errorSeleccion = true;
      });
    } else {
      setState(() {
        errorSeleccion = false;
      });
    }

    // 2. Validamos el formulario entero
    if (formKey.currentState!.validate() && !errorSeleccion) {
      final authProvider = context.read<AuthProvider>();

      // Mapeamos la selección de tu compañera al código de la API ('u' o 'p')
      String roleCode = (seleccion == 'Profesional/Entidad') ? 'p' : 'u';

      // 3. Ejecutamos el registro llamando al AuthProvider
      bool exito = await authProvider.register(
        name: nombreController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: roleCode,
        organizationName: roleCode == 'p' ? entidadController.text.trim() : null,
      );

      if (!mounted) return;

      // 4. Evaluamos la respuesta
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Cuenta creada con éxito. Inicia sesión.'),
          ),
        );
        // Volvemos a la pantalla de Login
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              authProvider.errorMessage ?? 'Error al registrar el usuario.',
            ),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context){

    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 231, 231),
      body: SafeArea(
        child: Center(
          child: Form(
            key: formKey,
          child: Column(
            children: [
             
//Crear cuenta
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                color: Colors.white,
                  child: Row(
                    children: [
                      IconButton(onPressed: (){
                        Navigator.pop((context));
                      }, icon: Icon(
                        Icons.arrow_back,
                        size: 28,
                        color: Colors.black,
                      ), ), 
                      
                        Text('crear cuenta', 
                        style: TextStyle(fontSize: 23),  
                      ),
                    ],
                  ),
              ),
              
              SizedBox(height: 20),
//NOMBRE COMPLETO
              Padding(
                padding: const EdgeInsets.only(right: 185.0),
                child: Text('NOMBRE COMPLETO'),
              ),
  //NOMBRE textfield
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: estiloRecuadro,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),

                          child: TextFormField(
                            controller: nombreController,

                            decoration: estiloTexto.copyWith(
                            hintText: 'Nombre y apellidos',
                            ),

                            validator: (valor) {
                              if(valor == null || valor.trim().isEmpty){
                                return 'Requerido';
                              }
                                return null;
                              },

                            //onChanged: (value) => {
                              //setState(() {})
                            //},
                          ),
                        ),    
                      ),
                    ),
              
              
              SizedBox(height: 20),

//campo email
              Padding(
                padding: const EdgeInsets.only(right: 185.0),
                child: Text('CORREO ELECTRÓNICO'),
              ),
              //email textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: estiloRecuadro,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextFormField(
                      controller: emailController,

                      decoration: estiloTexto.copyWith(
                      hintText: 'tu@email.com'
                      ),

                      validator: (valor) {
                        if(valor == null || valor.trim().isEmpty){
                          return 'Requerido';
                        }
                        if(!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(valor.trim())){
                          return 'Correo electrónico no válido';
                        }
                        return null;
                        },
                    ),
                  ),
                    
                ),
              ),
              
              SizedBox(height: 20),
//Contraseña
              Padding(
                padding: const EdgeInsets.only(right: 250.0),
                child: Text('CONTRASEÑA'),
              ),
              //password textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: estiloRecuadro,
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

                      decoration: estiloTexto.copyWith(
                      hintText: 'Password',
                    ),
                                ),
                  ),
                    
                ),
              ),

//CONFIRMAR CONTRASEÑA
              SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.only(right: 160.0),
                child: Text('CONFIRMAR CONTRASEÑA'),
              ),
              //password textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: estiloRecuadro,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextFormField(
                      controller: passwordConfirmationController,
                      obscureText: true,

                      validator: (valor) {
                        if(valor == null || valor.trim().isEmpty){
                          return 'Requerido';
                        }
                        if(valor != passwordController.text){
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },

                      decoration: estiloTexto.copyWith(
                      hintText: 'Confirmar contraseña',
                    ),
                                ),
                  ),
                    
                ),
              ),

//TIPO DE CUENTA
              SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.only(right: 220.0),
                child: Text('TIPO DE CUENTA'),
              ),
              //password textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                 decoration: estiloRecuadro,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                  ),  
                ),
              ),
//CHECKBOX
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: SizedBox(
                  height: 100,
                   child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //checkbox usuarios
                        Expanded(
                          child: GestureDetector(
                            onTap: (){
                              setState(() {
                                errorSeleccion = false;
                                seleccion = 'Usuario';
                              });
                            },
                          
                            child: Card(
                              color: seleccion == 'Usuario' ? const Color.fromARGB(255, 255, 160, 131) : Colors.white,
                              child: SizedBox(
                                height: 180,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.waving_hand, size: 30),
                                    SizedBox(height: 10),
                                    Text('Usuario'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),

    //checkbox profesional/entidad
                        Expanded(
                          child: GestureDetector(
                            onTap: (){
                              setState(() {
                                errorSeleccion = false;
                                seleccion = 'Profesional/Entidad';
                              });
                            },
                            child: Card(
                              color: seleccion == 'Profesional/Entidad' ? const Color.fromARGB(255, 255, 160, 131) : Colors.white,
                              child: SizedBox(
                                height: 180,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.waving_hand, size: 30),
                                    SizedBox(height: 10),
                                    Text('Profesional/Entidad'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 10),
                      ],
                    ),),

                    ),

              if (errorSeleccion || seleccion.isEmpty)
                  Text(
                    'Requerido',
                    style: TextStyle(color: Colors.red),
                  ),

                  SizedBox(height: 20),

//CAMPO ENTIDAD
            Padding(
                padding: const EdgeInsets.only(right: 150.0),
                child: Text('ENTIDAD/ESPECIALIZACIÓN'),
              ),
              //email textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: estiloRecuadro,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      enabled: seleccion == 'Profesional/Entidad',
                      decoration: estiloTexto.copyWith(
                      hintText: 'Escribe el nombre de tu entidad o especialización',
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

 //sign in button
            Padding(
              padding: const EdgeInsetsGeometry.symmetric(horizontal: 25),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                onPressed:authProvider.isLoading ? null : _registroPresionado,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 252, 110, 100),
                  padding: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Registrarse',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18
                  ),)),
              ),),
            
            SizedBox(height: 25),
        ],),
        )
      ),
    ),);
  }
}