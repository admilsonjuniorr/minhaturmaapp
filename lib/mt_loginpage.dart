import 'package:flutter/material.dart';
import 'mt_homepage.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('[PAGE] => mt_loginpage.dart');

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/mt_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Center(
                child: Image.asset(
                  'assets/mt_logoinit.png',
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.35,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white, // Cor do fundo
                      labelText: 'E-MAIL',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900, // Negrito mais forte
                      ),

                      /// Cor do rótulo
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black), // Cor da borda quando em foco
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .black), // Cor da borda quando não em foco
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900, // Negrito mais forte
                    ), // Cor e fonte do texto dentro do campo
                  ),
                  SizedBox(height: 20),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white, // Cor do fundo
                      labelText: 'SENHA',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900, // Negrito mais forte
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return HomePage();
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
          ],
        ),
      ),
    );
  }
}
