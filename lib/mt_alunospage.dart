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
    final alunos = await _databaseManager.getAlunos();
    setState(() {
      _alunos = alunos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alunos Page'),
      ),
      body: ListView.builder(
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
                String codigoAluno = _generateRandomCode();
                await _databaseManager.insertAluno(nomeAluno, codigoAluno);
                _fetchAlunos();
                Navigator.of(context).pop();
              },
              child: Text('Criar'),
            ),
          ],
        );
      },
    );
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
