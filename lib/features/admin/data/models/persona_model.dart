class PersonaModel {
  final String? id;
  final String? urlImage;
  final String nombreApellido;
  final String carrera;
  final int experienciaAnios;
  final String cargo;
  final String usuario;
  final String contrasena;

  const PersonaModel({
    this.id,
    this.urlImage,
    required this.nombreApellido,
    required this.carrera,
    required this.experienciaAnios,
    required this.cargo,
    required this.usuario,
    required this.contrasena
  });

  // Permite convertir el objeto en un Mapa (Json) para los datos guardados en firebase
  Map<String, dynamic> toMap(){
    return{
      if (id != null) 'id': id,
      'imageUrl': urlImage,
      'nombreApellido': nombreApellido,
      'carrera': carrera,
      'experienciaAnios': experienciaAnios,
      'cargo': cargo,
      'usuario': usuario,
      'contrasena': contrasena,
    };
  }

  // Crear un objet PerosnalModal a partir de un Mapa (Json) 
  factory PersonaModel.fromMap(Map<String, dynamic> map, {String? documentoId}){
    return PersonaModel(
      id: documentoId ?? map['id'] as String?,
      urlImage: map['imageUrl'] as String?,
      nombreApellido: map['nombreApellido'] as String? ?? '',
      carrera: map['carrera'] as String? ?? '',
      experienciaAnios: map['experienciaAnios'] as int? ?? 0,
      cargo: map['cargo'] as String? ?? '',
      usuario: map['usuario'] as String? ?? '',
      contrasena: map['contrasena'] as String? ?? '',
    );
  }
}

  const allPerson = [
    const PersonaModel(
      urlImage: '',
      nombreApellido: 'Isaac Jhon', 
      carrera: 'Sistemas', 
      experienciaAnios: 3, 
      cargo: 'Jefe', 
      usuario: 'jtorres', 
      contrasena: '122334'
    ),
    const PersonaModel(
      urlImage: '',
      nombreApellido: 'Isaac Jhon', 
      carrera: 'Sistemas', 
      experienciaAnios: 3, 
      cargo: 'Jefe', 
      usuario: 'jtorres', 
      contrasena: '122334'
    ),
  ];