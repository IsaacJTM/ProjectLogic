import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logistics_pro/features/admin/data/models/persona_model.dart';

class AdminRemoteDatasource {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    //Registrar el Firebase Auth y guarda datos en Firestore (Primer método)
    Future<void> createPerson(PersonaModel persona) async{
    try{
       //Para crear el correo en Firebase Auth 
      final String correoVirtual = persona.email;
      final String password = persona.contrasena!;

      final findUser = await _firestore
        .collection('usuarios')
        .doc(persona.email)
        .get();

      if(findUser.exists) throw Exception('El usuario ya se encuentra registrado');

      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: correoVirtual, password: password
      );

      final String? uid = credential.user?.uid;
      if(uid == null) throw Exception("Error al obtener UID de Firebase Auth");

     //Guardar el perfil completo en Firestore
     await _firestore.collection('usuarios').doc(persona.email).set({
         'nombreApellido': persona.nombreApellido,
         'carrera': persona.carrera,
         'experienciaAnios': persona.experienciaAnios,
         'cargo': persona.cargo,
         'usuario': persona.usuario,
         'imageUrl': persona.imageUrl,
         'rol' : 'worker',
         'isProject': false
     }); 
    } on FirebaseAuthException catch(e){
        if (e.code == 'email-already-in-use') {
          throw Exception('Este correo electrónico ya está siendo utilizado por otro usuario.');
        } else if (e.code == 'weak-password') {
          throw Exception('La contraseña proporcionada es muy débil.');
        } else {
          throw Exception('Error en Firebase Auth: ${e.message}');
        }
    }
    catch(e){
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
     
    }

    Future<List<PersonaModel>> obtenerPersonal() async{
      final QuerySnapshot query = await _firestore
            .collection('usuarios')
            .where('rol', isEqualTo: 'worker')
            .get();
      
      return query.docs.map((doc){
        final data = doc.data() as Map<String, dynamic>;
        return PersonaModel.fromMap(data, doc.id);
      }).toList();
    }
}