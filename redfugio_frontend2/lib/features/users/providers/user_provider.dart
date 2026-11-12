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
//   Future<bool> updateUser(String userId, String newName, String token) async {
  Future<bool> updateUser(String userId, String newName, String token, {String? email, String? role, String? organizationName}) async {
    errorMessage = null;
    try {
//       final respuesta = await _apiService.updateUser(userId, newName, token);
      final respuesta = await _apiService.updateUser(userId, newName, token, email: email, role: role, organizationName: organizationName);
      if (respuesta['success'] == true) {
        await getUsers(token); 
        if (errorMessage != null) return false;
        final guardados = users.where((user) => user.id == userId);
        if (guardados.isEmpty) {
          errorMessage = 'No se ha podido verificar el usuario guardado.';
          notifyListeners();
          return false;
        }
        final guardado = guardados.first;
        if (guardado.name != newName ||
            (email != null && guardado.email != email) ||
            (role != null && guardado.role.code != role) ||
            (organizationName != null && (guardado.organizationName ?? '') != organizationName)) {
          errorMessage = 'La API no ha guardado todos los campos. Puede haberse guardado solo parte de los cambios; revisa los datos. Es necesario ampliar el backend para los campos no admitidos.';
          notifyListeners();
          return false;
        }
        return true;
      }
      errorMessage = respuesta['message'] ?? 'No se ha podido actualizar el usuario.';
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'No se ha podido actualizar el usuario. Comprueba la conexión.';
      notifyListeners();
      return false;
    }
  }
}