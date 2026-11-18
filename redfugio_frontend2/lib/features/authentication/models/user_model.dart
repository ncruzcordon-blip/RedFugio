
enum UserRole{
  
  user(code: 'u',), 
  professional(code: 'p'),
  passerby(code: 'v'),
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

  //Conversión de datos a json
  factory UserModel.fromJson(Map<String, dynamic> json){
    return UserModel( 
      id: json['id'].toString(),
      name: json['name'] ?? '', 
      email: json['email'] ?? '',
      organizationName: json['organization_name'], 
      role: UserRole.fromCode(json['role'] ?? ''), 
      active: json['actived'] == true || json['actived'] == 1 || json['actived'] == '1'
      );
  }
}