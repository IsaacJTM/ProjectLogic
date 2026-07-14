class PersonaModel {
  final String imageUrl;
  final String nombreApellido;
  final String carrera;
  final int experienciaAnios;
  final String cargo;
  final String usuario;
  final String contrasena;

  const PersonalModel({
    this.imageUrl,
    required this.nombreApellido,
    required this.carrera,
    required this.experienciaAnios,
    required this.cargo,
    required this.usuario,
    required this.contrasena,
  });
}