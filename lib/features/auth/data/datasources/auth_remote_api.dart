import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_role.dart';
import '../models/user_model.dart';

class AuthRemoteApi {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('No se pudo obtener el usuario de Firebase');
      }

      //Buscamos el rol del usuario desde firebase
      final DocumentSnapshot doc = await _firestore
          .collection('usuarios')
          .doc(firebaseUser.email)
          .get();

      if (!doc.exists) {
        throw Exception('Este Usuario no tiene asigando un perfil');
      }

      final data = doc.data() as Map<String, dynamic>;

      // Mapeo del rol  a nuestro Enum (user_role.dart)
      final String rolString = data['rol'] as String ?? 'worker';
      final UserRole userRole = rolString == 'admin'
          ? UserRole.admin
          : UserRole.worker;

      //Para retornar el modelo de usuario en el controller
      return UserModel.formFirestore(data, doc.id);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception("El correo electrónico no está registrado");
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception("La contraseña es incorrecta");
      } else {
        throw Exception(" Error de autenticacion : ${e.message}");
      }
    } catch (ex) {
      throw Exception("Error de conexion $ex");
    }
  }
}
