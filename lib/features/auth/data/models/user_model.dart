import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
  });

  factory UserModel.formFirestore(Map<String, dynamic> json, String documentoId) {
    return UserModel(
      id: documentoId,
      name: json['nombreApellido'] as String,
      email: documentoId.toString(),
      role: json['rol'] == 'admin' ? UserRole.admin : UserRole.worker,
    );
  }
}
