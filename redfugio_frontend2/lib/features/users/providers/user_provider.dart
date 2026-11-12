import 'package:flutter/foundation.dart';
import 'package:redfugio_frontend2/features/authentication/models/user_model.dart';
import 'package:redfugio_frontend2/features/authentication/services/api_service.dart';

class UserProvider extends ChangeNotifier {
  final _apiService = ApiService();
  
  List<UserModel> users = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> getUsers(String token) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners(); 

    try {
      users = await _apiService.getUsers(token);
      isLoading = false;
      notifyListeners(); 
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

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

  /// Desactivar la cuenta de un usuario
  Future<bool> deactivateUser(String userId, String token) async {
    try {
      // Método corregido: deactivateUser
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

  /// Eliminar un usuario permanentemente
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

  /// Actualizar el nombre de un usuario
  Future<bool> updateUser(String userId, String newName, String token) async {
    try {
      final respuesta = await _apiService.updateUser(userId, newName, token);
      if (respuesta['success'] == true) {
        await getUsers(token); 
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}