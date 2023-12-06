import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Adicione esta importação
import 'init.dart';
import 'utils/mt_db.dart';

class CadastroUserPage extends StatefulWidget {
  @override
  _CadastroUserPageState createState() => _CadastroUserPageState();
}

class _CadastroUserPageState extends State<CadastroUserPage> {
  late MinhaTurmaDatabase _databaseManager;
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  String? _selectedUserType;

  @override
  void initState() {
    super.initState();
    _databaseManager = MinhaTurmaDatabase();
  }

  Future<void> showAlert(String message,
      {Color backgroundColor = Colors.red}) async {
    await Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> cadastrarUsuario() async {
    String nomeUsuario = _nomeController.text;
    print(nomeUsuario);

    bool usuarioJaExiste = await userExists(nomeUsuario);

    if (usuarioJaExiste) {
      showAlert('Usuário informado (e-mail) já se encontra cadastrado.');
    } else {
      await _databaseManager.createUser(nomeUsuario, _emailController.text,
          _senhaController.text, '${_selectedUserType}');
      showAlert('Usuário $nomeUsuario cadastrado com sucesso!',
          backgroundColor: Colors.green);
      print("USUÁRIO NÃO EXISTE!! CADASTRANDO");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                InitPage()), // Substitua 'InitPage' pelo nome da sua página
      );
    }
  }

  Future<bool> userExists(String nomeUsuario) async {
    List<Map<String, dynamic>> users = await _databaseManager.getUsers();
    return users.any((user) => user['email_usuario'] == nomeUsuario);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/mt_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(33.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Center(
                  child: Image.asset(
                    'assets/mt_cadastro.png',
                    width: MediaQuery.of(context).size.width * 2,
                    height: MediaQuery.of(context).size.height * 0.35,
                  ),
                ),
              ),
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Digite o nome',
                  border: OutlineInputBorder(),
                  labelText: 'NOME',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Digite o email',
                  border: OutlineInputBorder(),
                  labelText: 'EMAIL',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'SENHA',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    left: BorderSide(color: Colors.black),
                    top: BorderSide(color: Colors.black),
                    bottom: BorderSide(color: Colors.black),
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4.0),
                    bottomLeft: Radius.circular(4.0),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.arrow_drop_down, color: Colors.black, size: 36),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        underline: Container(),
                        icon: Container(),
                        hint: Text(
                          'USUÁRIO',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.8),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        value: _selectedUserType,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedUserType = newValue;
                          });
                        },
                        items: ['PROFESSOR', 'PAI', 'USUÁRIO COMUM']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Container(
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              ElevatedButton(
                onPressed: cadastrarUsuario,
                child: Text('CRIAR NOVO USUÁRIO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
