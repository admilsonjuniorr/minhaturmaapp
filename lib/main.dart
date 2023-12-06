import 'package:flutter/material.dart';
import 'mt_homepage.dart';
import 'mt_loginpage.dart';
import 'init.dart'; // Importe a página init.dart
import 'mt_alunospage.dart';
import 'mt_turmaspage.dart';
import 'mt_perfil.dart';
import 'package:provider/provider.dart';
import 'utils/mt_db.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MinhaTurmaDatabase()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Locator.setup(context); // Configura o Locator com o context
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/init',
      routes: {
        '/init': (context) => InitPage(),
        '/home': (context) => HomePage(nomeDoProfessor: '',),
        '/login': (context) => LoginPage(),
        '/alunos': (context) => AlunosPage(),
        '/turmas': (context) => TurmasPage(),
        '/perfil': (context) => PerfilPage(nomeDoProfessor: '',),
      },
    );
  }
}



class Locator {
  static BuildContext? _context;

  static void setup(BuildContext context) {
    _context = context;
  }

  static BuildContext get context => _context!;
}