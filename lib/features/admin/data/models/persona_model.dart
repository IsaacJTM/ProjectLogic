class PersonaModel {
  final String email;
  final String? imageUrl;
  final String nombreApellido;
  final String carrera;
  final int experienciaAnios;
  final String cargo;
  final String usuario;
  final String? contrasena;
  final bool? isProject;

  const PersonaModel({
    required this.email,
    this.imageUrl,
    required this.nombreApellido,
    required this.carrera,
    required this.experienciaAnios,
    required this.cargo,
    required this.usuario,
    this.contrasena,
    this.isProject
  });

  // Permite convertir el objeto en un Mapa (Json) para los datos guardados en firebase
  Map<String, dynamic> toMap(){
    return{
      'nombreApellido': nombreApellido,
      'carrera': carrera,
      'experienciaAnios': experienciaAnios,
      'cargo': cargo,
      'usuario': usuario,
      'imageUrl': imageUrl,
      'rol': 'worker',
      'isProject': false
    };
  }

  // Crear un objet PerosnalModal a partir de un Mapa (Json) 
  factory PersonaModel.fromMap(Map<String, dynamic> map, String documentoId){
    return PersonaModel(
      email: documentoId,
      nombreApellido: map['nombreApellido'] as String? ?? '',
      carrera: map['carrera'] as String? ?? '',
      experienciaAnios: map['experienciaAnios'] as int? ?? 0,
      cargo: map['cargo'] as String? ?? '',
      usuario: map['usuario'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      isProject: map['isProject'] as bool? ?? false
    );
  }
}
