import 'package:flutter/material.dart';
import 'package:hello_world_app/sign_up.dart';
import 'login_page.dart';

void main(){
  
  runApp(MyApp());
}


class MyApp extends StatelessWidget{
 const MyApp({Key? key}) : super(key: key);

 @override
 Widget build(BuildContext context){
  return MaterialApp(
    debugShowCheckedModeBanner: false,
   // home: LoginPage(),

    routes: {
      '/':(context) => LoginPage(),
      '/second':(context) => const SignUp(),
    }
  );
 }
  
}