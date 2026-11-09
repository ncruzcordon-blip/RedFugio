
import 'package:flutter/foundation.dart';
import 'package:redfugio_frontend2/features/authentication/models/user_model.dart';
import 'package:redfugio_frontend2/features/authentication/services/api_service.dart';


class UserProvider extends ChangeNotifier {

  final _apiService= ApiService();
  List<UserModel> users=[];

  Future<void> getUsers(String token) async {
    notifyListeners();

    try {
      users = await _apiService.getUsers(token);
      notifyListeners();
    } catch (e) {
      notifyListeners();
    }
  }

  // Activar usuario
  Future<bool> activateUser(int userId, String token) async {
    try {
      final respuesta = await _apiService.activateUser(userId, token);
      if (respuesta['success'] == true) {
        await getUsers(token); // Recarga la lista actualizada
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Desactivar usuario
  Future<bool> deactivateUser(int userId, String token) async {
    try {
      final respuesta = await _apiService.desactivateUser(userId, token);
      if (respuesta['success'] == true) {
        await getUsers(token);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Eliminar usuario
  Future<bool> deleteUser(int userId, String token) async {
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

  // Actualizar usuario
  Future<bool> updateUser(int userId, String newName, String token) async {
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