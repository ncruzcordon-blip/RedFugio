
import 'package:flutter/foundation.dart';
import 'package:redfugio_frontend2/core/storage/token_storage.dart';
import 'package:redfugio_frontend2/features/authentication/models/user_model.dart';
import 'package:redfugio_frontend2/features/authentication/services/api_service.dart';


class AuthProvider extends ChangeNotifier{

  final _almacenamientoToken= AlmacenamientoToken();

  String? token;
  UserModel? userActual;
  String? errorMessage;
  bool isLoading= false;

  bool get isAuthenticated => token != null;

  AuthProvider(){
    comprobarToken();
  }

  Future<void> comprobarToken() async{
    token= await _almacenamientoToken.getToken();
    notifyListeners();
  }

  String _detalleError(dynamic respuesta) {
    final data = respuesta is Map ? respuesta['data'] : null;
    final detalle = data is Map ? data['error'] : null;
    switch (detalle) {
      case "Email don't confirmed":
        return 'El correo electrónico todavía no está confirmado.';
      case "User don't activated":
        return 'La cuenta está pendiente de activación por un administrador.';
      case 'User deleted':
        return 'La cuenta ha sido eliminada.';
      case 'Unauthorized':
        return 'Correo electrónico o contraseña incorrectos.';
      default:
        return (detalle ?? (respuesta is Map ? respuesta['message'] : null) ?? 'No se ha podido iniciar sesión.').toString();
    }
  }

  Future<bool> login(String email, String password) async{
    isLoading= true;
    errorMessage = null;
    notifyListeners();

    try {
      final respuesta = await ApiService().login(email, password);

      if ( respuesta is Map<String, dynamic> && respuesta['success'] == true) {
        token = respuesta['data']['token'];
        userActual = UserModel.fromJson(respuesta['data']);

        if (token != null) {
          await _almacenamientoToken.saveToken(token!);
        }

        isLoading = false;
        notifyListeners();

        return true;

      } else {
        errorMessage = _detalleError(respuesta);
        
        isLoading = false;
        notifyListeners();
        
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({required String name, required String email, required String password, required String role, String? organizationName}) async{
    isLoading=true;
    errorMessage=null;
    notifyListeners();

    try{
      final respuesta= await ApiService().register(name, email, password, role, organizationName);
      if(respuesta['success']==true){
        isLoading=false;
        notifyListeners();

        return true;
      }else{
        errorMessage= respuesta['message'] ?? 'Error al registrar al usuario';
        isLoading=false;

        isLoading = false;
        notifyListeners();
        
        return false;
      }
    }catch(e){
      errorMessage = 'No se ha podido completar el registro. Comprueba la conexión e inténtalo de nuevo.';
      isLoading = false;

      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async{
    token = null;
    userActual= null;
    await _almacenamientoToken.deleteToken();
    notifyListeners();
  }

}