import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redfugio_frontend/features/authentication/providers/auth_provider.dart';
import 'package:redfugio_frontend/features/users/providers/user_provider.dart';
import 'Front-end/login_page.dart';
import 'Front-end/sign_up.dart';

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
  const MyApp({Key? key}) : super(key: key);

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
          return LoginPage();
        },
      ),
    );
  }
}