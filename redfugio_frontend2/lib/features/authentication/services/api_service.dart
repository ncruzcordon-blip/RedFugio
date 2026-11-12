
import 'package:dio/dio.dart';
import 'package:redfugio_frontend2/features/authentication/models/user_model.dart';
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
    try{
        final respuesta= await _dio.post(
      '/login',
      data: {
        'email' : email,
        'password' : password
      }
    );

    return respuesta.data;

    }on DioException catch(e){
      print('STATUS CODE: ${e.response?.statusCode}');
      print('RESPUESTA API: ${e.response?.data}');

      if(e.response !=null && e.response?.data != null){
        return e.response!.data;
      }
    }
    
    //no ha habido respuesta del servidor
    throw Exception('No se ha podido conectar con el servidor');

    //Comprobación de existencia de usuario
    //devuelve el data que contiene todos los datos de dicho usuario 
    if(respuesta.data['success'] == false){
      return respuesta.data['message'];
    } 
    //devuelve el data que contiene todos los datos de dicho usuario  
    return respuesta.data;*/
  }

  //register 
  Future register(String name, String email, String password, String role, String? nombreOrganizacion) async{
    
    try{
      final respuesta= await _dio.post(
      '/register',
      data: {
        'name': name,
        'email' : email,
        'password' : password,
        'c_password': password,
        'role': role,
        'organization_name' : (role=='p' && nombreOrganizacion != null && nombreOrganizacion.isNotEmpty) ?
        nombreOrganizacion : '',
      }
    );

    return respuesta.data;

    }on DioException catch(e){
      //la API ha respondido con un error
      if(e.response != null && e.response?.data != null){
        return e.response!.data;
      }
    }
    
    throw Exception('No se ha podido conectar con el servidor');

    /*if(respuesta.data['success'] == false){
      return respuesta.data['message'];
    }
    return respuesta.data;*/

  }

  //getUsers
  Future<List<UserModel>> getUsers(String token) async{
    try{
      final respuesta= await _dio.get(
      '/users',
      options: Options(
        headers: {
          'Authorization' : 'Bearer $token',
        },
      ),
    );

    if(respuesta.data['success'] == true){
      final List<dynamic> json = respuesta.data['data'];
      final List<UserModel> usuarios= json.map((p) => UserModel.fromJson(p)).toList();
      return usuarios;
    }else{
      throw Exception(respuesta.data['message'] ?? 'Error al obtener usuarios');
    }
    }on DioException catch (e){
      throw Exception('Error en GET /users: ${e.message}');
    }
  }

  //Activate
  Future activateUser(String idUser, String token) async {
    try{
      final respuesta= await _dio.post(
        '/activate',
        data: {
          'id': idUser,
        },
        options: Options(
          headers: {
            'Authorization' : 'Bearer $token'
          }
          )
        );

        return respuesta.data;

    }on DioException catch (e){
      if (e.response != null && e.response?.data != null) {
        return e.response?.data;
      }
        throw Exception('Error al activar el usuario: ${e.message}');
    }
  }

  Future deactivateUser(String idUser, String token) async{
     try{
      final respuesta= await _dio.post(
        '/deactivate',
        data: {
          'id': idUser,
        },
        options: Options(
          headers: {
            'Authorization' : 'Bearer $token'
          }
          )
        );

        return respuesta.data;

    }on DioException catch (e){
      if (e.response != null && e.response?.data != null) {
        return e.response?.data;
      }
        throw Exception('Error al desactivar el usuario: ${e.message}');
    }
  }

   Future deleteUser(String idUser, String token) async{
     try{
      final respuesta= await _dio.post(
        '/deleteUser',
        data: {
          'id': idUser,
        },
        options: Options(
          headers: {
            'Authorization' : 'Bearer $token'
          }
          )
        );

        return respuesta.data;

    }on DioException catch (e){
      if (e.response != null && e.response?.data != null) {
        return e.response?.data;
      }
        throw Exception('Error al eliminar el usuario: ${e.message}');
    }
  }

  Future updateUser(String idUser, String newName, String token) async {
    try {
      final respuesta = await _dio.post(
        '/updateUser',
        data: {
          'id': idUser,
          'name': newName,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return respuesta.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return e.response?.data;
      }
      throw Exception('Error al actualizar usuario: ${e.message}');
    }
  }

}