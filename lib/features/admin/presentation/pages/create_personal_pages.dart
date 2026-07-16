import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreatePersonalPages extends StatelessWidget {
  CreatePersonalPages({super.key});
  final _formKey = GlobalKey<FormState>();
  final _nombreApellido = TextEditingController();
  final _carrera = TextEditingController();
  final _experiencia = TextEditingController();
  final _usuario = TextEditingController();
  final _contrasenia = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Personal'),
        actions: [
          Icon(Icons.arrow_back)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.black),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.phone),
                      )
                    ],
                  ),
                )
              ],
            )
          ),
        ),

      ),
    );
  }
}