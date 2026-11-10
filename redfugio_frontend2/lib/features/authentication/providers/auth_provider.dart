
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

  Future<bool> login(String email, String password) async{
    isLoading= true;
    final respuesta = await ApiService().login(email, password);

    try {
      final respuesta = await ApiService().login(email, password);

      if (respuesta['success'] == true) {
        token = respuesta['data']['token'];
        userActual = UserModel.fromJson(respuesta['data']);

        if (token != null) {
          await _almacenamientoToken.saveToken(token!);
        }

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = respuesta['message'] ?? 'Error de autenticación';
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
        notifyListeners();
        return false;
      }
    }catch(e){
      token= null;
      userActual=null;
      await _almacenamientoToken.deleteToken();
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