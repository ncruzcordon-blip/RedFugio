import 'package:flutter/foundation.dart';
import 'package:redfugio_frontend2/features/authentication/models/user_model.dart';
import 'package:redfugio_frontend2/features/authentication/services/api_service.dart';

class UserProvider extends ChangeNotifier {
  final _apiService = ApiService();
  
  List<UserModel> users = [];
  bool isLoading = false;
  String? errorMessage;
  String? actionErrorMessage;

  Future<void> getUsers(String token) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners(); 

     debugPrint('USER PROVIDER: iniciando petición');

    try {
      users = await _apiService.getUsers(token);

      debugPrint('USUARIOS RECIBIDOS: ${users.length}');

      isLoading = false;
      notifyListeners();

    } catch (e) {
      debugPrint('ERROR AL OBTENER USUARIOS: $e');

      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  //ACTIVAR CUENTA
  Future<bool> activateUser(String userId, String token) async {
    try {
      final respuesta = await _apiService.activateUser(userId, token);
      if (respuesta['success'] == true) {
        await getUsers(token); 
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  //DESACTIVAR CUENTA
  Future<bool> deactivateUser(String userId, String token) async {
    try {
      final respuesta = await _apiService.deactivateUser(userId, token);
      if (respuesta['success'] == true) {
        await getUsers(token); 
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  //ELIMINAR CUENTA
  Future<bool> deleteUser(String userId, String token) async {
    try {
      final respuesta = await _apiService.deleteUser(userId, token);
      if (respuesta['success'] == true) {
        await getUsers(token); 
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  //ACTUALIZAR CUENTA
  Future<bool> updateUser(String userId, String newName, String token) async {
    actionErrorMessage = null;
    try {
      final respuesta = await _apiService.updateUser(userId, newName, token);
      if (respuesta['success'] == true) {
        await getUsers(token); 
        if (errorMessage != null) {
          actionErrorMessage = errorMessage;
          return false;
        }
        final guardados = users.where((user) => user.id == userId);
        if (guardados.isEmpty) {
          actionErrorMessage = 'No se ha podido verificar el usuario guardado.';
          notifyListeners();
          return false;
        }
        final guardado = guardados.first;
        if (guardado.name != newName) {
          actionErrorMessage = 'La API no ha guardado todos los campos';
          notifyListeners();
          return false;
        }
        return true;
      }

      actionErrorMessage = respuesta['message'] ?? 'No se ha podido actualizar el usuario.';
      notifyListeners();
      return false;
    } catch (e) {

      actionErrorMessage = 'No se ha podido actualizar el usuario. Comprueba la conexión.';
      notifyListeners();
      return false;
    }
  }
}
