
enum UserRole{user, professional, admin}

class UserModel{
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? organizationName;
  final bool active;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.organizationName,
    required this.active

  });   

  //Ahora vamos a realizar la conversión de los datos a JSON para que sea más facil 
  //a la hora hacer la petición

  factory FromJson(Map<String, dynamic> json){
    return UserModel(
      id: json['id'], 
      name: json['name'], 
      email: json['email'], 
      role: json['role'], 
      active: json['active']
      );
  }
}