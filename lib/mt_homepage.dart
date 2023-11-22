import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:minha_turma/mt_turmaspage.dart';
import 'mt_alunospage.dart';
import 'mt_perfil.dart';
class HomePageContent extends StatelessWidget {
  final String label;

  const HomePageContent({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        ' =>>>>>> Conteúdo da $label',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;
  final List<Widget> _pages = [
    HomePageContent(label: 'Home'),
    TurmasPage(),
    AlunosPage(),
    PerfilPage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    print('[PAGE] => mt_homepage.dart');
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: Color.fromARGB(255, 209, 208, 208),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            backgroundColor: Color.fromARGB(255, 209, 208, 208),
            color: Colors.black,
            tabBackgroundColor: Colors.grey.shade400,
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            tabs: const [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.class_sharp, text: 'Turmas'),
              GButton(icon: Icons.person, text: 'Alunos'),
              GButton(icon: Icons.engineering, text: 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }
}
