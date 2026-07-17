import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistics_pro/core/theme/app_colors.dart';
import 'package:logistics_pro/features/admin/data/models/persona_model.dart';
import 'package:logistics_pro/features/admin/presentation/controllers/persona_controller.dart';
import 'package:provider/provider.dart';

class CreatePersonalPages extends StatefulWidget {
  CreatePersonalPages({super.key});

  @override
  State<CreatePersonalPages> createState() => _CreatePersonalPagesState();
}

class _CreatePersonalPagesState extends State<CreatePersonalPages> {
  final _formKey = GlobalKey<FormState>();
  final _nombreApellidoController = TextEditingController();
  final _carreraController = TextEditingController();
  final _experienciaController = TextEditingController();
  final _usuarioController = TextEditingController();
  final _contraseniaController = TextEditingController();

  //estados locales de la interfaz gráfica 
  String? _cargoSeleccionado; 
  bool _obscurePassword = true;
  bool _isSaved = false;
  PersonaController? _personaController;
  final List<String> _cargos = ['Administrador', 'Técnico', 'Supervisor', 'Operador'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<PersonaController>();
  }

  void _onPersonaChanged(){
    final state = _personaController!;
    if(state.status == PersonState.error && state.errorMessage != null){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage!))
      );
      state.consumeError();
    }

    if(state.status == PersonState.success){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Persona registrada exitosamente')
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        )
      );

      //Cambio de estado
      setState(() {
        _isSaved = true;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _personaController?.removeListener(_onPersonaChanged);
    _nombreApellidoController.dispose();
    _carreraController.dispose();
    _experienciaController.dispose();
    _usuarioController.dispose();
    _contraseniaController.dispose();
    super.dispose();
  }

  void _guardarPersona(){
    if(!_formKey.currentState!.validate()){
      return; //Detener si existe campo invalido
    }
    if(_cargoSeleccionado == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, seleccione un cargo'))
      );
      return;
    }



    final nuevaPersona = PersonaModel(
      email: _usuarioController.text.trim().contains('@')
        ? _usuarioController.text.trim()
        : '${_usuarioController.text.trim()}@worker.com', 
      nombreApellido: _nombreApellidoController.text.trim(), 
      carrera: _carreraController.text.trim(), 
      experienciaAnios: int.tryParse(_experienciaController.text) ?? 0, 
      cargo: _cargoSeleccionado!, 
      usuario: _usuarioController.text.trim(),
      contrasena: _contraseniaController.text.trim()
    );

    context.read<PersonaController>().createPersonaUsecase(nuevaPersona);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Color(0xFFEFF0FF),
        title: Text(
          'Nuevo Personal',
          style: TextStyle(
            color: Color(0xFF1E40AF),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          )
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.local_shipping, color: AppColors.primary,),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color:Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.add_a_photo_outlined),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Cargar Foto',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'PNG, JPG',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildFieldLabel('Nombre y Apellido'),
                  _buildTextFormField(
                    controller: _nombreApellidoController, 
                    hint: 'Ej. Juan Pérez',
                    validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa el nombre completo' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildFieldLabel('Carrera / Especialidad'),
                  _buildTextFormField(
                    controller: _carreraController, 
                    hint: 'Ej. Logística Internacional',
                    validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa la especialidad' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildFieldLabel('Experiencia (Años)'),
                  _buildTextFormField(
                    controller: _experienciaController,
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Ingresa los años de experiencia';
                      if (int.tryParse(value) == null) return 'Ingresa un número entero válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFieldLabel('Cargo'),
                  _buildDropdownField(),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDBEAFE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.lock_outline, color: Color(0xFF1D4ED8), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Credenciales de Acceso',
                              style: TextStyle(
                                color: Color(0xFF1D4ED8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Usuario'),
                        _buildTextFormField(
                          controller: _usuarioController, 
                          hint: 'jperez_logistics',
                          validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa un nombre de usuario' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Contraseña'),
                        _buildPasswordField(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Consumer<PersonaController>(
                      builder: (context, personaState, _) {
                        final isLoading = personaState.status == PersonState.loading;

                        // Si ya se guardó, deshabilitamos el botón o cambiamos el diseño a "Completado"
                        if (_isSaved) {
                          return ElevatedButton.icon(
                            onPressed: null, // Deshabilitado porque ya se completó
                            icon: const Icon(Icons.check, color: Colors.green),
                            label: const Text(
                              'Personal Registrado',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          );
                        }

                        return ElevatedButton.icon(
                          onPressed: isLoading ? null : _guardarPersona,
                          icon: isLoading
                              ? const SizedBox.shrink()
                              : const Icon(Icons.save_outlined, color: Colors.white),
                          label: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Guardar Personal',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF475569),
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _isSaved ? const Color(0xFFF1F5F9) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: !_isSaved,
        validator: validator,
        style: TextStyle(color: _isSaved ? Colors.black45 : Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _isSaved ? const Color(0xFFF1F5F9) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _cargoSeleccionado,
          hint: const Text(
            'Seleccionar cargo',
            style: TextStyle(color: Colors.black38, fontSize: 15),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
          isExpanded: true,
          onChanged: _isSaved ? null : (val) => setState(() => _cargoSeleccionado = val),
          items: _cargos.map((cargo) {
            return DropdownMenuItem(
              value: cargo,
              child: Text(
                cargo, 
                style: TextStyle(color: _isSaved ? Colors.black45 : Colors.black87),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: _isSaved ? const Color(0xFFF1F5F9) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: TextFormField(
        controller: _contraseniaController,
        obscureText: _obscurePassword,
        enabled: !_isSaved, // 👑 Bloqueamos la edición de contraseña
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Ingresa una contraseña';
          if (value.length < 6) return 'Debe tener al menos 6 caracteres';
          return null;
        },
        style: TextStyle(color: _isSaved ? Colors.black45 : Colors.black87),
        decoration: InputDecoration(
          hintText: '********',
          hintStyle: const TextStyle(color: Colors.black38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.black45,
            ),
            onPressed: _isSaved 
                ? null 
                : () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }
}

