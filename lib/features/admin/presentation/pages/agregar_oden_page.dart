import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logistics_pro/features/admin/domain/entities/tarea_checklist_entity.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart'; // Recomiendo agregar 'uuid' en pubspec para generar IDs únicos
import '../controllers/ordenes_controller.dart';
import '../../domain/entities/orden_trabajo_entity.dart';
import '../../data/models/persona_model.dart';

class AgregarOrdenPage extends StatefulWidget {
  const AgregarOrdenPage({super.key});

  @override
  State<AgregarOrdenPage> createState() => _AgregarOrdenPageState();
}

class _AgregarOrdenPageState extends State<AgregarOrdenPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _lugarNombreController = TextEditingController();
  final _fechaController = TextEditingController();

  final double _latitud = -12.046374;
  final double _longitud = -77.042793;
  DateTime? _fechaSeleccionada;
  String? _clienteSeleccionadoId; // Guardará el idCliente exacto
  List<Map<String, String>> _actividadesLocales = []; // Listado temporal UI
  OrdenesController? _ordenesController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<OrdenesController>();
    if (_ordenesController != controller) {
      _ordenesController?.removeListener(_onOrdenStateChanged);
      _ordenesController = controller;
      _ordenesController!.addListener(_onOrdenStateChanged);
    }
  }

  void _onOrdenStateChanged() {
    final state = _ordenesController!;
    if (state.status == OrdenState.error && state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
    }
    if (state.status == OrdenState.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Orden de Trabajo enviada con éxito!'), backgroundColor: Colors.green)
      );
      state.resetState();
    }
  }

  @override
  void dispose() {
    _ordenesController?.removeListener(_onOrdenStateChanged);
    _tituloController.dispose();
    _descripcionController.dispose();
    _lugarNombreController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  void _mostrarPopUpMapa() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Falta integrar con Google Maps'),
        content: Text('Coordenadas guardadas en Firebase:\nLat: $_latitud\nLng: $_longitud'),
        actions: [TextButton(onPressed: () => context.pop(), child: const Text('Cerrar'))],
      ),
    );
  }

  void _mostrarDialogoNuevaActividad() {
    final actFormKey = GlobalKey<FormState>();
    final tCtrl = TextEditingController();
    final sCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Actividad'),
        content: Form(
          key: actFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: tCtrl, decoration: const InputDecoration(labelText: 'Título'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              TextFormField(controller: sCtrl, decoration: const InputDecoration(labelText: 'Subtítulo'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (actFormKey.currentState!.validate()) {
                setState(() {
                  _actividadesLocales.add({'titulo': tCtrl.text.trim(), 'subTitulo': sCtrl.text.trim()});
                });
                context.pop();
              }
            },
            child: const Text('Añadir'),
          )
        ],
      ),
    );
  }

  void _guardarOrdenCompleta() {
    if (!_formKey.currentState!.validate() || _clienteSeleccionadoId == null) return;
    if (_actividadesLocales.isEmpty) return;

    final constUuid = const Uuid();
    final String generatedIdOrden = constUuid.v4().substring(0, 8); // Generador simple ID único

    // Mapeamos las actividades temporales a la Entidad limpia
    final listaEntidadesActividades = _actividadesLocales.map((tarea) => TareaChecklistEntity(
      idTarea: constUuid.v4().substring(0, 8),
      idOrden: generatedIdOrden,
      descripcion: tarea['titulo']!,
      notaTarea: tarea['subTitulo']!,
    )).toList();

    // Creamos la Orden de Trabajo como Entidad lista para enviar
    final nuevaOrdenTrabajo = OrdenTrabajoEntity(
      idOrden: generatedIdOrden,
      idCliente: _clienteSeleccionadoId!,
      idUsuario: 'Tecnicao',
      nroOrden: 1001 + (DateTime.now().millisecond), // Número autogenerado para el ejemplo
      estadoFase: 4, // Estado Base de tu captura
      fechaCreacion: DateTime.now(),
      fechaAsignacionOrden: _fechaSeleccionada ?? DateTime.now(),
      titulo: _tituloController.text.trim() + " - " + _descripcionController.text.trim(),
      tiempoEjecucion: 0,
      nombreLugar: _lugarNombreController.text.trim(),
      latitud: _latitud,
      longitud: _longitud,
      actividades: listaEntidadesActividades, 
    );

    context.read<OrdenesController>().createOrden(nuevaOrdenTrabajo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text("Agregar Orden", style: TextStyle(color: Color(0xFF1E40AF), fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel('Cliente Solicitante'),
              _buildDropdownClientes(),
              const SizedBox(height: 16),
              _buildFieldLabel('Título'),
              _buildTextFormField(_tituloController, 'Ej. Revisión de equipos...'),
              const SizedBox(height: 16),
              _buildFieldLabel('Descripción'),
              _buildTextFormField(_descripcionController, 'Detalles de la carga...', maxLines: 3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030)).then((picked) {
                          if (picked != null) {
                            setState(() {
                              _fechaSeleccionada = picked;
                              _fechaController.text = DateFormat('dd/MM/yyyy').format(picked);
                            });
                          }
                        });
                      },
                      child: AbsorbPointer(child: _buildTextFormField(_fechaController, 'dd/mm/aaaa', icon: Icons.calendar_today_outlined)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextFormField(_lugarNombreController, 'Ciudad, Sede', icon: Icons.location_on_outlined, onIconPressed: _mostrarPopUpMapa)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Actividades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: _mostrarDialogoNuevaActividad, icon: const Icon(Icons.add_box, color: Color(0xFF1E40AF), size: 32))
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _actividadesLocales.length,
                itemBuilder: (context, index) {
                  final act = _actividadesLocales[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.assignment_outlined, color: Color(0xFF1E40AF)),
                      title: Text(act['titulo']!),
                      subtitle: Text(act['subTitulo']!),
                      trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => setState(() => _actividadesLocales.removeAt(index))),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: Consumer<OrdenesController>(
                  builder: (context, ordenState, _) {
                    return ElevatedButton(
                      onPressed: ordenState.status == OrdenState.loading ? null : _guardarOrdenCompleta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0044C9),
                        shape: RoundedRectangleBorder(
                          borderRadius:  BorderRadiusGeometry.circular(16)
                        )
                      ),
                      child: ordenState.status == OrdenState.loading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('Guardar', style: TextStyle(color: Colors.white)),
                    );
                  }
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 6.0), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)));
  Widget _buildTextFormField(TextEditingController ctrl, String hint, {int maxLines = 1, IconData? icon, VoidCallback? onIconPressed}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFCBD5E1))),
      child: TextFormField(
        controller: ctrl, maxLines: maxLines, validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.all(16), suffixIcon: icon != null ? IconButton(icon: Icon(icon), onPressed: onIconPressed) : null),
      ),
    );
  }

  Widget _buildDropdownClientes() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('clientes').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFCBD5E1))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _clienteSeleccionadoId,
              hint: const Text('Seleccionar cliente'),
              isExpanded: true,
              onChanged: (val) => setState(() => _clienteSeleccionadoId = val),
              items: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return DropdownMenuItem(value: data['idCliente'].toString(), child: Text(data['nombreEmpresa'] ?? ''));
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}