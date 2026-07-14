import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.worker,
    );
  }
}
