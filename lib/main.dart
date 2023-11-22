import 'package:flutter/material.dart';
import 'mt_homepage.dart';
import 'mt_loginpage.dart';
import 'init.dart'; // Importe a página init.dart
import 'mt_alunospage.dart';
import 'mt_turmaspage.dart';
import 'mt_perfil.dart';


void main() {
  runApp(const MinhaTurma());
}

class MinhaTurma extends StatelessWidget {
  const MinhaTurma({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/init',
      routes: {
        '/init': (context) => InitPage(),
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/alunos': (context) => AlunosPage(),
        '/turmas': (context) => TurmasPage(),
        '/perfil': (context) => PerfilPage(),
      },
    );
  }
}
