import 'package:flutter/material.dart';
import 'package:logistics_pro/core/theme/app_colors.dart';
import 'package:logistics_pro/features/admin/data/models/persona_model.dart';

class PersonaCardWidget extends StatefulWidget {
  const PersonaCardWidget({super.key});

  @override
  State<PersonaCardWidget> createState() => _PersonaCardWidgetState();
}

class _PersonaCardWidgetState extends State<PersonaCardWidget> {
  bool pintar = false;
  PersonaModel person = PersonaModel(
      urlImage: '',
      nombreApellido: 'Isaac Jhon', 
      carrera: 'Sistemas', 
      experienciaAnios: 3, 
      cargo: 'Jefe', 
      usuario: 'jtorres', 
      contrasena: '122334'
    );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBar,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4)
          )
        ]
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: pintar ? Border.all(color: Colors.blue, width: 2) : Border.all(color: AppColors.secundaryColor, width: 2)
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(''),
              ),
            ),
            const SizedBox(height: 8),
            // 2.Nombre
            Text(
              person.nombreApellido, 
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E272C))
            ),
            const SizedBox(height: 8),
            Text(
              person.cargo, 
              style: const TextStyle(fontSize: 15, color: Color(0xFF1E272C))
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.amber,
                  ),
                  child: IconButton(
                    onPressed: (){},
                    icon: Icon(Icons.document_scanner),  
                    highlightColor: Colors.transparent,  
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.amber,
                  ),
                  child: Icon(Icons.edit),
                ),
              ],
            )
          
          ],
        ),
      ),
    );
  }
}