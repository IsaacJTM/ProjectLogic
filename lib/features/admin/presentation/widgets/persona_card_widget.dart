import 'package:flutter/material.dart';
import 'package:logistics_pro/core/theme/app_colors.dart';
import 'package:logistics_pro/features/admin/data/models/persona_model.dart';

class PersonaCardWidget extends StatelessWidget {
  final PersonaModel personal;
  final VoidCallback? onCarPressed;
  PersonaCardWidget({super.key, required this.personal, this.onCarPressed});

  @override
  Widget build(BuildContext context) {
    bool pintar = false;
    if( personal.isProject != null){
      pintar = personal.isProject!;
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4)
          ),
        ]
      ),
      child: InkWell(
        onTap: onCarPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: pintar ? Border.all(color: AppColors.secundaryColor, width: 2) : Border.all(color: Colors.blue, width: 2) 
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(personal.imageUrl!),
              ),
            ),
            const SizedBox(height: 8),
            // 2.Nombre
            Text(
              personal.nombreApellido, 
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E272C))
            ),
            Text(
              personal.cargo, 
              style: const TextStyle(fontSize: 15, color: Color(0xFF1E272C))
            ),          
          ],
        ),
      ),
    );
  }
}
