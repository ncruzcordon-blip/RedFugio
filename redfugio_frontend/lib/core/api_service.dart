
import 'package:dio/dio.dart';

class ApiService {

  //Aqui establecemos la conexión estandar con la API y luego iremos acceciendo a las diferentes
  //conexiones
  final Dio _dio= Dio(
    BaseOptions(
      baseUrl: 'https://redfugioapi.iaknowhow.es/public/api',
      headers:{
        'Accept': 'application/json'
      })
  );

  //PETICIONES 

  //login 
  Future login(String email, String password) async{

    final respuesta= await _dio.post(
      '/login',
      data: {
        'email' : email,
        'password' : password
      }
    );

    //Comprobación de existencia de usuario
    //devuelve el data que contiene todos los datos de dicho usuario 
    if(respuesta.data['succes'] == false){
      return respuesta.data['message'];
    } 
    //devuelve el data que contiene todos los datos de dicho usuario  
    return respuesta.data;
  }

  //register 
  Future register(String name, String email, String password, String role, String nombreOrganizacion) async{
    
    final respuesta= await _dio.post(
      '/register',
      data: {
        'name': name,
        'email' : email,
        'password' : password,
        'role': role,
        'organization_name' : nombreOrganizacion
      }
    );
  }

  //getUsers

}