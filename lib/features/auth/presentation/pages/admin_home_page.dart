import 'package:flutter/material.dart';

/// Panel del administrador: crea y asigna órdenes de trabajo a técnicos.
/// Punto de partida simple — conectar a un AdminBloc/CreateOrderUseCase
/// cuando el backend de asignación esté definido.
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _clientController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedTechnician;

  final _technicians = const ['Técnico 1', 'Técnico 2', 'Técnico 3'];

  @override
  void dispose() {
    _titleController.dispose();
    _clientController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: const Text('Panel de administrador'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nueva orden de trabajo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título de la orden'),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clientController,
                decoration: const InputDecoration(labelText: 'Cliente'),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTechnician,
                decoration: const InputDecoration(labelText: 'Asignar a técnico'),
                items:
                    _technicians.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedTechnician = v),
                validator: (v) => v == null ? 'Selecciona un técnico' : null,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Orden asignada a $_selectedTechnician')),
                      );
                      _formKey.currentState!.reset();
                      setState(() => _selectedTechnician = null);
                    }
                  },
                  child: const Text('Crear y asignar orden'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
