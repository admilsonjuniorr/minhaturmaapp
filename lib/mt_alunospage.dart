import 'dart:math';

import 'package:flutter/material.dart';
import 'utils/mt_db.dart';

class AlunosPage extends StatefulWidget {
  @override
  _AlunosPageState createState() => _AlunosPageState();
}

class _AlunosPageState extends State<AlunosPage> {
  late MinhaTurmaDatabase _databaseManager;
  late List<Map<String, dynamic>> _alunos;

  @override
  void initState() {
    super.initState();
    _databaseManager = MinhaTurmaDatabase();
    _alunos = [];
    _fetchAlunos();
  }

  Future<void> _fetchAlunos() async {
    try {
      final alunos = await _databaseManager.getAlunos();
      if (alunos.isEmpty) {
        print('[INFO][mt_alunos.dart]: Nenhum aluno cadastrado!');
      } else {
        print('[INFO][mt_alunos.dart]: ALUNOS no banco de dados: $alunos');
      }
      setState(() {
        _alunos = alunos;
      });
    } catch (e) {
      print(
          '[INFO][mt_alunos.dart]: Erro ao obter ALUNOS do banco de dados: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
          true, // Estender o fundo atrás da barra de aplicativos
      extendBody: true,

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color.fromRGBO(0, 0, 0, 1),
              Color.fromRGBO(94, 84, 158, 1),
              Color.fromRGBO(85, 71, 168, 0.74),
            ],
          ),
        ),
        child: Center(
          child: _alunos.isEmpty
              ? Text('Nenhum aluno cadastrado!')
              : ListView.builder(
                  itemCount: _alunos.length,
                  itemBuilder: (context, index) {
                    final nomeAluno = _alunos[index]['nome_aluno'];
                    final codigoAluno = _alunos[index]['codigo_aluno'];

                    return Card(
                      margin: EdgeInsets.all(16.0),
                      child: ListTile(
                        title: Text(nomeAluno),
                        subtitle: Text(codigoAluno),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAlunoDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddAlunoDialog(BuildContext context) {
    String nomeAluno = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar Aluno'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  nomeAluno = value;
                },
                decoration: InputDecoration(labelText: 'Nome do Aluno'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Verifica se o nome do aluno não está vazio
                if (nomeAluno.isNotEmpty) {
                  if (await _isNomeAlunoUnique(nomeAluno)) {
                    String codigoAluno = _generateRandomCode();
                    await _databaseManager.insertAluno(nomeAluno, codigoAluno);
                    _fetchAlunos();
                    Navigator.of(context).pop();
                  } else {
                    // Nome duplicado, exiba uma mensagem para o usuário
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                            'Nome de aluno já existente. Escolha um nome único.',
                          ),
                          backgroundColor: Colors.red),
                    );
                  }
                } else {
                  // Nome vazio, exiba uma mensagem para o usuário
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('O nome do aluno não pode estar vazio.'),
                        backgroundColor: Colors.red),
                  );
                }
              },
              child: Text('Criar'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _isNomeAlunoUnique(String nomeAluno) async {
    final alunos = await _databaseManager.getAlunos();
    return alunos.every((aluno) => aluno['nome_aluno'] != nomeAluno);
  }

  String _generateRandomCode() {
    final random = Random();
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    String randomCode = '';

    for (int i = 0; i < 8; i++) {
      randomCode += characters[random.nextInt(characters.length)];
    }

    return randomCode;
  }
}
