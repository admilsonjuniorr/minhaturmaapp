import 'package:flutter/material.dart';

class PerfilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('[INFO] PAG = mt_perfil.dart');
    return Scaffold(
      appBar: AppBar(
        title: Text('PERFIL  Page'),
      ),
      body: Center(
        child: Text(
          'Bem-vindo à página de PERFIL!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}