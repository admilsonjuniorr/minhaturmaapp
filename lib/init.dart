import 'package:flutter/material.dart';
import 'mt_cadastrouser.dart';
import 'mt_loginpage.dart';

class InitPage extends StatelessWidget {
  const InitPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print('[PAGE] => init.dart');
    final teste = MediaQuery.of(context).size.height * 0.15;

    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/mt_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Image.asset(
                'assets/mt_logoinit.png',
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.45,
              ),
            ),
          ),
              SizedBox(height:teste),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return LoginPage();
                    },
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: 
              Text(
                'ENTRAR',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16, // Tamanho da fonte do botão
                  fontWeight: FontWeight.w900, // Negrito mais forte
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    vertical: 16), // Ajuste conforme necessário
                minimumSize: Size(double.infinity, 0), // Largura total
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // Remover o raio
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0), // Espaçamento entre os botões
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return CadastroUserPage();
                    },
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Text(
                'CADASTRAR',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16, // Tamanho da fonte do botão
                  fontWeight: FontWeight.w900, // Negrito mais forte
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    vertical: 16), // Ajuste conforme necessário
                minimumSize: Size(double.infinity, 0), // Largura total
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // Remover o raio
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
