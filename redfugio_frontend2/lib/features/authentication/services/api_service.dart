
import 'package:dio/dio.dart';
import 'package:redfugio_frontend2/features/authentication/models/user_model.dart';
class ApiService {

  //Conexion API
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

      if(e.response !=null && e.response?.data != null){
        return e.response!.data;
      }
    }
    
    //no ha habido respuesta del servidor
    throw Exception('No se ha podido conectar con el servidor');
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

  //Activar user
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

  //desactivar user
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

  //borrar user
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

 //actualizar campos
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