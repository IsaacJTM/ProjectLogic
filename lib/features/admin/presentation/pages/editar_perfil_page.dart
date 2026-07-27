import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:logistics_pro/features/admin/data/models/persona_model.dart';
import 'package:logistics_pro/features/admin/presentation/controllers/persona_controller.dart';

class EditarPerfilPage extends StatefulWidget {
  final PersonaModel personaModel;
  const EditarPerfilPage({super.key, required this.personaModel});

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreApellidoController;
  late TextEditingController _carreraController;
  late TextEditingController _experienciaController;
  String? _cargoSeleccionado;
  PersonaController? _personaController;
  final List<String> _cargos = [
    'Administrador',
    'Técnico',
    'Supervisor',
    'Operador',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nombreApellidoController = TextEditingController(
      text: widget.personaModel.nombreApellido,
    );
    _carreraController = TextEditingController(
      text: widget.personaModel.carrera,
    );
    _experienciaController = TextEditingController(
      text: widget.personaModel.experienciaAnios.toString(),
    );
    _cargoSeleccionado = _cargos.contains(widget.personaModel.cargo)
        ? widget.personaModel.cargo
        : _cargos.first;
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final controller = context.read<PersonaController>();
    if (_personaController != controller) {
      _personaController?.removeListener(_onPersonaChanged);
      _personaController = controller;
      _personaController!.addListener(_onPersonaChanged);
    }
  }

  void _onPersonaChanged() {
    final state = _personaController!;
    if (state.status == PersonState.error && state.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
    }

    if (state.status == PersonState.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perfil actualizado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
      state.resetState();
      //context.pop();
    }
  }

  @override
  void dispose() {
    _personaController?.removeListener(_onPersonaChanged);
    _tabController.dispose();
    _nombreApellidoController.dispose();
    _carreraController.dispose();
    _experienciaController.dispose();
    super.dispose();
  }

  //Método para actualizar, envio al controller
  void _guardarCambios() {
    if (!_formKey.currentState!.validate() || _cargoSeleccionado == null)
      return;
    final personaActualizada = PersonaModel(
      email: widget.personaModel.email,
      nombreApellido: _nombreApellidoController.text.trim(),
      carrera: _carreraController.text.trim(),
      experienciaAnios: int.tryParse(_experienciaController.text) ?? 0,
      cargo: _cargoSeleccionado!,
      usuario: widget.personaModel.usuario,
      imageUrl: widget.personaModel.imageUrl,
    );
    context.read<PersonaController>().updatePerson(personaActualizada);
  }

  @override
  Widget build(BuildContext context) {
    final bool tieneFoto =
        widget.personaModel.imageUrl != null &&
        widget.personaModel.imageUrl!.isNotEmpty &&
        widget.personaModel.imageUrl!.startsWith('http');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2563EB)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Logistics Pro",
          style: TextStyle(
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
            child: Consumer<PersonaController>(
              builder: (context, controller, _) {
                final isLoading = controller.status == PersonState.loading;
                return ElevatedButton(
                  onPressed: isLoading ? null : _guardarCambios,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Guardar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: tieneFoto
                      ? NetworkImage(widget.personaModel.imageUrl!)
                      : null,
                  child: !tieneFoto
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.personaModel.nombreApellido,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            'ID: ${widget.personaModel.usuario} • ${widget.personaModel.cargo}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF2563EB),
            tabs: const [
              Tab(text: 'Datos Personal'),
              Tab(text: 'Lista de Órdenes'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFormularioDatosPersonal(),
                _buildListaOrdenesTecnico(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormularioDatosPersonal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputLabel('Nombre Completo'),
              _buildTextField(_nombreApellidoController, 'Nombre completo'),
              const SizedBox(height: 16),
              _buildInputLabel('Especialidad / Carrera'),
              _buildTextField(_carreraController, 'Especialidad'),
              const SizedBox(height: 16),
              _buildInputLabel('Años de Experiencia'),
              _buildTextField(_experienciaController, '0', isNumber: true),
              const SizedBox(height: 16),
              _buildInputLabel('Rol Actual'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _cargoSeleccionado,
                    isExpanded: true,
                    onChanged: (val) =>
                        setState(() => _cargoSeleccionado = val),
                    items: _cargos
                        .map(
                          (cargo) => DropdownMenuItem(
                            value: cargo,
                            child: Text(cargo),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListaOrdenesTecnico() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ordenes_trabajo')
          // Filtramos usando el email, tal como descubrimos en Firebase
          .where('idUsuario', isEqualTo: widget.personaModel.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Este personal no tiene órdenes asignadas.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;

            // 1. Extraemos las variables básicas
            final String nroOrden =
                data['nroOrden']?.toString() ??
                data['idOrden']?.toString() ??
                'N/A';
            final String notas = data['notasGenerales'] ?? 'Sin descripción';
            final String idCliente = data['idCliente']?.toString() ?? 'N/A';

            // 2. Extraemos el estado/fase leyendo el campo 'estadoFase' como número
            final int numeroFase = data['estadoFase'] as int? ?? 0;

            String estadoStr;
            List<Color> gradientEstado;
            IconData iconoEstado;

            // 3. Lógica para asignar Gradientes, Ícono y Texto según el número
            switch (numeroFase) {
              case 1: // En Ruta
                gradientEstado = const [Color(0xFF3B6FF0), Color(0xFF17318F)];
                iconoEstado = Icons.local_shipping_rounded;
                estadoStr = 'EN RUTA';
                break;
              case 2: // En Sitio
                gradientEstado = const [Color(0xFF2F55E0), Color(0xFF17318F)];
                iconoEstado = Icons.location_on_rounded;
                estadoStr = 'EN SITIO';
                break;
              case 3: // Ejecución
                gradientEstado = const [Color(0xFF5B4FE0), Color(0xFF3B31A8)];
                iconoEstado = Icons.build_rounded;
                estadoStr = 'EJECUCIÓN';
                break;
              case 4: // Finalizado
                gradientEstado = const [Color(0xFF2FA972), Color(0xFF1F8256)];
                iconoEstado = Icons.verified_rounded;
                estadoStr = 'FINALIZADO';
                break;
              case 0: // Asignado
              default:
                gradientEstado = const [Color(0xFF9AA3B8), Color(0xFF7C8499)];
                iconoEstado = Icons.badge_rounded;
                estadoStr = 'ASIGNADO';
                break;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF16213A).withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    // Chorri aqui falta ver detalle
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: gradientEstado,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: gradientEstado.first.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            iconoEstado,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Orden #$nroOrden',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF16213A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: gradientEstado,
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                                child: Text(
                                  estadoStr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                notas,
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Cliente ID: $idCliente',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 🌟 FLECHA DERECHA
                        const Padding(
                          padding: EdgeInsets.only(top: 12.0),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF7B849A),
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569),
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (v) =>
            v == null || v.trim().isEmpty ? 'Campo requerido' : null,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
