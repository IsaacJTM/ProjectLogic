import 'package:flutter/material.dart';
import 'package:logistics_pro/core/theme/app_colors.dart';
import 'package:logistics_pro/core/theme/app_theme.dart';
import 'package:logistics_pro/features/admin/data/models/persona_model.dart';
import 'package:logistics_pro/features/admin/presentation/widgets/persona_card_widget.dart';

class PersonaPage extends StatefulWidget {
  const PersonaPage({super.key});

  @override
  State<PersonaPage> createState() => _PersonaPageState();
}

class _PersonaPageState extends State<PersonaPage> {
  TextEditingController _searchController = TextEditingController();
  List<PersonaModel> _filterPersonal = [];


  final List<PersonaModel> _allPersonal = [
    const PersonaModel(
      id: '1',
      nombreApellido: 'Carlos Ruiz',
      cargo: 'Jefe de Almacén',
      urlImage: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150',
      carrera: 'Sistemas', 
      experienciaAnios: 3, 
      usuario: 'CarlosR', 
      contrasena: '122334'
    ),
    const PersonaModel(
      id: '2',
      nombreApellido: 'Elena Mendez',
      cargo: 'Gestora de Flotas',
      urlImage: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
      carrera: 'Sistemas',
      experienciaAnios: 3, 
      usuario: 'ElenaM', 
      contrasena: '122334'// Borde verde turquesa de la imagen
    ),
    const PersonaModel(
      id: '3',
      nombreApellido: 'Julian Torres',
      cargo: 'Analista de Datos',
      urlImage: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
      carrera: 'Sistemas',
      experienciaAnios: 3, 
      usuario: 'JulianT', 
      contrasena: '122334'
    ),
    const PersonaModel(
      id: '4',
      nombreApellido: 'Mateo Gomez',
      cargo: 'Técnico Operativo',
      urlImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      carrera: 'Sistemas',
      experienciaAnios: 3, 
      usuario: 'MateoG', 
      contrasena: '122334'
    ),
    const PersonaModel(
      id: '5',
      nombreApellido: 'Sofia Valles',
      cargo: 'Coordinadora SC',
      urlImage: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
      carrera: 'Sistemas',
      experienciaAnios: 3, 
      usuario: 'SofiaV', 
      contrasena: '122334'
    ),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchController = TextEditingController();
    _filterPersonal = _allPersonal;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _searchController.dispose(); //liberación de memoria
    super.dispose();
  }

  void _onSearchPeronal(String filtro){
    setState(() {
      if(filtro.isEmpty){
        _filterPersonal = _allPersonal;
      }else{
        _filterPersonal = _allPersonal.
        where((p) => p.nombreApellido.toLowerCase().contains(filtro.toLowerCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    onChanged: _onSearchPeronal,
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
                  child: GridView.builder(
                    padding: const EdgeInsets.all(4),// Espacio extra para que no tape el botón
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.82
                    ), 
                    itemCount: _filterPersonal.length,
                    itemBuilder: (context, index){
                      return PersonaCardWidget(
                        personal: _filterPersonal[index],
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
              onPressed: (){}, 
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