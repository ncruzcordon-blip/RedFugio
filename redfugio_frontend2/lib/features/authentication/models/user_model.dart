
enum UserRole{
  
  user(code: 'u'), 
  professional(code: 'p'),
  admin(code: 'a');

  final String code;
  
  UserRole({required this.code});

  factory UserRole.fromCode(String code) {
    return UserRole.values.firstWhere(
      (e) => e.code == code,
      orElse: () => UserRole.user,
    );
  }
  
  }

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

  factory UserModel.fromJson(Map<String, dynamic> json){
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()), 
      name: json['name'] ?? '', 
      email: json['email'] ?? '', 
      role: UserRole.fromCode(json['role'] ?? ''), 
      active: json['active']
      );
  }
}