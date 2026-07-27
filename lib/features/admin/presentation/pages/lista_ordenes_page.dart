import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logistics_pro/core/router/app_router.dart';
import 'package:logistics_pro/features/admin/domain/entities/orden_trabajo_entity.dart';
import 'package:logistics_pro/features/admin/presentation/controllers/ordenes_controller.dart';

class ListaOrdenesPage extends StatefulWidget {
  const ListaOrdenesPage({super.key});

  @override
  State<ListaOrdenesPage> createState() => _ListaOrdenesPageState();
}

class _ListaOrdenesPageState extends State<ListaOrdenesPage> {
  final TextEditingController _searchOrdenesController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  String _filtroTexto = '';
  DateTime? _fechaSeleccionada;

  @override
  void dispose() {
    // TODO: implement dispose
    _fechaController.dispose();
    _searchOrdenesController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async{
    final DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(),
      firstDate: DateTime(2020), 
      lastDate: DateTime(2030)
    );
    if(picked != null){
      setState(() {
        _fechaSeleccionada = picked;
        _fechaController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _limpiarFiltroFecha(){
    setState(() {
      _fechaSeleccionada = null;
      _fechaController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OrdenesController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Lista de Órdenes",
          style: TextStyle(
            color: Color(0xFF1E40AF),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.1,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. FILTROS DE FECHA Y BUSCADOR POR NRO DE ORDEN
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: GestureDetector(
                        onTap: () => _seleccionarFecha(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF64748B)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _fechaSeleccionada == null ? "Fecha" : _fechaController.text,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: _fechaSeleccionada == null ? Colors.black38 : const Color(0xFF1E293B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_fechaSeleccionada != null)
                                GestureDetector(
                                  onTap: _limpiarFiltroFecha,
                                  child: const Icon(Icons.close, size: 16, color: Colors.grey),
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: TextField(
                          controller: _searchOrdenesController,
                          onChanged: (val) => setState(() => _filtroTexto = val.trim()),
                          decoration: const InputDecoration(
                            hintText: 'N° Orden (#8821)',
                            hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                            border: InputBorder.none,
                            icon: Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Text(
                  "Lista de órdenes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                
                Expanded(
                  child: StreamBuilder<List<OrdenTrabajoEntity>>(
                    stream: controller.ordenesStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      print(snapshot.error);
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text("No hay órdenes registradas", style: TextStyle(color: Colors.grey)),
                        );
                      }

                      // Filtrado dinámico local por N° Orden o Título
                      final ordenesFiltradas = snapshot.data!.where((orden) {
                        final busqueda = _filtroTexto.toLowerCase();
                        final matchNro = orden.nroOrden.toString().contains(busqueda);
                        final matchTitulo = orden.titulo.toLowerCase().contains(busqueda);
                        
                        bool matchFecha = true;
                        if (_fechaSeleccionada != null) {
                          matchFecha = orden.fechaAsignacionOrden.year == _fechaSeleccionada!.year &&
                              orden.fechaAsignacionOrden.month == _fechaSeleccionada!.month &&
                              orden.fechaAsignacionOrden.day == _fechaSeleccionada!.day;
                        }

                        return (matchNro || matchTitulo) && matchFecha;
                      }).toList();

                      if (ordenesFiltradas.isEmpty) {
                        return const Center(
                          child: Text("No se encontraron coincidencias.", style: TextStyle(color: Colors.grey)),
                        );
                      }

                      return ListView.builder(
                        itemCount: ordenesFiltradas.length,
                        itemBuilder: (context, index) {
                          return _CardOrdenItem(orden: ordenesFiltradas[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 3. BOTÓN INFERIOR PARA REDIRIGIR A CREAR ORDEN
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () => context.push(AppRouter.createOrden),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "AGREGAR ORDEN",
                  style: TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _CardOrdenItem extends StatelessWidget {
  final OrdenTrabajoEntity orden;
  const _CardOrdenItem({super.key, required this.orden});

  @override
  Widget build(BuildContext context) {
    // Cálculo dinámico de Porcentaje a partir de las Entidades
    int completadas = orden.actividades.where((a) => a.estadoCompletado).length;
    double porcentajeFactor = orden.actividades.isEmpty ? 0 : (completadas / orden.actividades.length);
    int porcentajeTexto = (porcentajeFactor * 100).round();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: _buildProgressCircle(porcentajeFactor, porcentajeTexto),
          title: Text(
            orden.titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
          ),
          subtitle: Text(
            "ID: #ORD-${orden.nroOrden}",
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          children: [
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "ACTIVIDADES DE LA ORDEN",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 8),

            if (orden.actividades.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Sin actividades registradas", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              )
            else
              Column(
                children: orden.actividades.map((actividad) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          actividad.estadoCompletado ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: actividad.estadoCompletado ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            actividad.descripcion,
                            style: TextStyle(
                              fontSize: 13,
                              color: actividad.estadoCompletado ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                              fontWeight: actividad.estadoCompletado ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildProgressCircle(double factor, int porcentaje) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: factor,
            strokeWidth: 4,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(
              porcentaje == 100 ? const Color(0xFF16A34A) : const Color(0xFF1D4ED8),
            ),
          ),
          Center(
            child: Text(
              "$porcentaje%",
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }
}