
import 'package:flutter/foundation.dart';
import 'package:redfugio_frontend2/core/storage/token_storage.dart';
import 'package:redfugio_frontend2/features/authentication/models/user_model.dart';
import 'package:redfugio_frontend2/features/authentication/services/api_service.dart';


class AuthProvider extends ChangeNotifier{

  final _almacenamientoToken= AlmacenamientoToken();

  String? token;
  UserModel? userActual;
  String? errorMessage;

  bool get isAuthenticated => token != null;

  AuthProvider(){
    comprobarToken();
  }

  Future<void> comprobarToken() async{
    token= await _almacenamientoToken.getToken();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async{

    final respuesta = await ApiService().login(email, password);

    if(respuesta.data['success'] == true){
      token= respuesta.data['token'];
      userActual = UserModel.fromJson(respuesta.data);

      if(token != null){
        await _almacenamientoToken.saveToken(token!);
      }
      return true;
    }else{
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