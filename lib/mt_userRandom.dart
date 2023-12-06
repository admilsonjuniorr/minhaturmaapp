import 'package:flutter/material.dart';

class UsuarioRandomPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color.fromRGBO(0, 0, 0, 0.99),
              Color.fromRGBO(94, 84, 158, 1),
              Color.fromRGBO(85, 71, 168, 0.80),
            ],
          ),
        ),
        child: Center(
          child: Text(
            'Usuário sem permissões',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
