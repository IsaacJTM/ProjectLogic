import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistics_pro/core/theme/app_colors.dart';
import 'package:logistics_pro/features/admin/presentation/controllers/persona_controller.dart';
import 'package:logistics_pro/features/admin/presentation/widgets/persona_card_widget.dart';
import 'package:logistics_pro/features/auth/presentation/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class PersonaPage extends StatefulWidget {
  const PersonaPage({super.key});

  @override
  State<PersonaPage> createState() => _PersonaPageState();
}



class _PersonaPageState extends State<PersonaPage> {
  TextEditingController _searchController = TextEditingController();
  String _filterPersonal = '';
  PersonaController? _personaController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //Forzamos la carga del widget para que este en el arbol de widgets
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(!mounted) return;
      context.read<PersonaController>().fetchPersonal();
    });
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    //para escuchar al PersonaController y saber si hay error 
    final controller = context.read<PersonaController>();
    if(_personaController !=  controller){
      _personaController?.removeListener(_onPersonaChanged);
      _personaController = controller;
      _personaController!.addListener(_onPersonaChanged);
    }
  }

  void _onPersonaChanged(){
    //oyente: si falla la comunicación con Firebase
    final state = _personaController!;
    if(state.status == PersonState.error && state.errorMessage != null){
      ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      state.consumeError();
    }
  }

  @override
  void dispose(){
    _personaController?.removeListener(_onPersonaChanged);
    _searchController.dispose(); //liberar memoría del buscador
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF0FF),
      appBar: AppBar(
        backgroundColor: Color(0xFFEFF0FF),
        leading: Icon(Icons.local_shipping , color: AppColors.primary,),
        title: Text("Logistics Admin", style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          IconButton(
            onPressed: () { context.read<AuthController>().logout();}, 
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar sesión',
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), 
          child: Container(
            color: Colors.grey[300],
            height: 1,
          )
        ),
      ),
      body:  Stack(
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
                  Expanded(
                    child: Consumer<PersonaController>
                    (builder: (context, personaState, _){
                      //Cuanda no haya data cargada.
                      if(personaState.status == PersonState.loading && personaState.personaList.isEmpty){
                        return Center(child: CircularProgressIndicator());
                      }

                      //Para el filtro dinámico
                      final empleadosFiltrados = personaState.personaList.where((persona){
                          return persona.nombreApellido.toLowerCase().contains(_filterPersonal.toLowerCase());
                      }).toList();

                      if(empleadosFiltrados.isEmpty){
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.people_outline, size: 48, color: AppColors.primary,),
                              const SizedBox(height: 8),
                              const Text('No se encontraron resultados', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(_filterPersonal.isEmpty
                              ? 'Ingrese su primera pesona'
                              : 'Pruebe buscando oto nombre',
                              style: TextStyle(color: Colors.grey))
                            ],
                          ),
                        );
                      }
                      
                      return GridView.builder(
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
                      );
                    })
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 15,
              right: 10,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/edit-person'), 
                label: Icon(Icons.person_add, color: Colors.white,),
                style: ElevatedButton.styleFrom(
                  elevation: 4,
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)
                  )
                ),
              )
              )
          ],
        )
    );
  }
}