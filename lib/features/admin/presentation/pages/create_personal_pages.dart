import 'package:flutter/material.dart';

class CreatePersonalPages extends StatelessWidget {
  const CreatePersonalPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Personal'),
        actions: [
          Icon(Icons.local_shipping)
        ],
      ),
    );
  }
}