import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistics_pro/core/theme/app_colors.dart';
import 'package:logistics_pro/features/admin/presentation/controllers/persona_controller.dart';
import 'package:logistics_pro/features/admin/presentation/widgets/persona_card_widget.dart';

class PersonaPage extends StatefulWidget {
  const PersonaPage({super.key});

  @override
  State<PersonaPage> createState() => _PersonaPageState();
}

class _PersonaPageState extends State<PersonaPage> {
  TextEditingController _searchController = TextEditingController();
  String _filterPersonal = '';

 
 
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //Ejecutas la consulta a Firebase 
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<PersonaController>().fetchPersonal();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _searchController.dispose(); //liberación de memoria
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PersonaController>();

    //Para la busqueda. (Filtro en memoria)
    final empleadosFiltrados = controller.personaList.where((persona){
      return persona.nombreApellido.toLowerCase().contains(_filterPersonal.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Color(0xFFEFF0FF),
      appBar: AppBar(
        backgroundColor: Color(0xFFEFF0FF),
        leading: Icon(Icons.local_shipping , color: AppColors.primary,),
        title: Text("Logistics Admin", style: Theme.of(context).textTheme.titleMedium
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), 
          child: Container(
            color: Colors.grey[300],
            height: 1,
          )
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsGeometry.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Personal', style: Theme.of(context).textTheme.titleSmall,),
                Text('Lista de pesonal de la empresa', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0))
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (valor) => setState(() => _filterPersonal = valor),
                    decoration: InputDecoration(
                      hintText: 'Buscar personal...',
                      hintStyle: TextStyle(color: Colors.black38),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      prefixIcon: Icon(Icons.search, color: Colors.black38)
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if(controller.state == PersonState.loading)
                  const Expanded(child: Center(child: CircularProgressIndicator()))
                else if (empleadosFiltrados.isEmpty)
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Lista de Personal'),
                        Text('Ingrese su primer personal')
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(4),// Espacio extra para que no tape el botón
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.82
                      ), 
                      itemCount: empleadosFiltrados.length,
                      itemBuilder: (context, index){
                        return PersonaCardWidget(
                          personal: empleadosFiltrados[index],
                          onCarPressed: (){},
                          onEditPressed: (){},
                        );
                      }
                    )
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 50,
            right: 100,
            left: 100,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/edit-person'), 
              label: Text('Nuevo', style: TextStyle(color: Colors.white, fontSize: 16)),
              icon: Icon(Icons.person_add, color: Colors.white,),
              style: ElevatedButton.styleFrom(
                elevation: 4,
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  
                  borderRadius: BorderRadius.circular(14)
                )
              ),
            )
            )
        ],
      ),
    );
  }
}