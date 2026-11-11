import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redfugio_frontend2/Front-end/sign_up.dart';
import 'package:redfugio_frontend2/features/authentication/models/user_model.dart';
import 'package:redfugio_frontend2/features/authentication/providers/auth_provider.dart';
import 'package:redfugio_frontend2/features/users/providers/user_provider.dart';
import 'Front-end/login_page.dart';
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RedFugio',
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isAuthenticated) {
            return LoginPage(); 
          }
          final UserRole? userRole= authProvider.userActual?.role;
          switch (userRole) {
            case UserRole.admin:
              // Redirige al panel exclusivo de administración
              return Scaffold(
                appBar: AppBar(title: const Text('Gestión de Usuarios (Admin)')),
                body: const Center(child: Text('Panel de Administración')),
              );

            default:
              // Redirige a la vista estándar de usuario
              return Scaffold(
                appBar: AppBar(title: const Text('RedFugio Home')),
                body: Center(
                  child: Text('Bienvenido/a (Rol: ${userRole?.code ?? "u"})'),
                ),
              );
          }
        },
      ),

      routes: {
        '/signUp': (context) => const SignUp()
      }
    );
  }
}