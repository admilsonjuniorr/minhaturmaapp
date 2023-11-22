import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'utils/mt_db.dart';

class TurmaInfoPage extends StatefulWidget {
  final String turma;
  final String materia;
  final String hashImg;

  TurmaInfoPage(
      {required this.turma, required this.materia, required this.hashImg});

  @override
  _TurmaInfoPageState createState() => _TurmaInfoPageState();
}

class _TurmaInfoPageState extends State<TurmaInfoPage> {
  String? _selectedAluno;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Turma'),
      ),
      body: Column(
        children: [
          // Header
          FutureBuilder<String>(
            future: _getImageFilePath(widget.hashImg),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(); // Pode exibir um indicador de carregamento aqui
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final filePath = snapshot.data!;
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.0),
                      height: 100, // Ajuste a altura conforme necessário
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: FileImage(File(filePath)),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(
                                0.4), // Ajuste a opacidade conforme necessário
                            BlendMode.dstATop,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Turma: ${widget.turma}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Matéria: ${widget.materia}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Alunos:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getAlunosDaTurma(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Nenhum aluno associado à turma.');
                } else {
                  final alunosDaTurma = snapshot.data!;

                  return ListView.builder(
                    itemCount: alunosDaTurma.length,
                    itemBuilder: (context, index) {
                      final aluno = alunosDaTurma[index];
                      return ListTile(
                        title: Text(aluno['nome_aluno']),
                        subtitle: Text(aluno['codigo']),
                      );
                    },
                  );
                }
              },
            ),
          ),
          // Footer
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    _showUserSelectionPopup(context);
                  },
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _getImageFilePath(String hashImg) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'image_$hashImg.png';
    return '${appDir.path}/$fileName';
  }

  void _showUserSelectionPopup(BuildContext context) async {
    final db = MinhaTurmaDatabase(); // Use a classe MinhaTurmaDatabase
    final alunos = await db.getAlunos();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Selecione o usuário'),
              content: Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Escolha um usuário:'),
                    _buildUserDropdown(alunos, setState),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _associateAlunoToTurma();
                    Navigator.pop(context);
                  },
                  child: Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildUserDropdown(
      List<Map<String, dynamic>> alunos, Function setState) {
    return DropdownButton<String>(
      value: _selectedAluno,
      onChanged: (String? selectedAluno) {
        setState(() {
          _selectedAluno = selectedAluno;
        });
      },
      items: alunos.map<DropdownMenuItem<String>>((aluno) {
        return DropdownMenuItem<String>(
          value: aluno['nome_aluno'],
          child: Text(aluno['nome_aluno']),
        );
      }).toList(),
      isExpanded: true,
      hint: Text(_selectedAluno ?? 'Selecione um aluno'),
    );
  }

  Future<List<Map<String, dynamic>>> _getAlunosDaTurma() async {
    final db = MinhaTurmaDatabase();
    final nomeTurma = widget.turma;
    return await db.getAlunosDaTurma(nomeTurma);
  }

  void _associateAlunoToTurma() async {
    final db = MinhaTurmaDatabase();

    if (_selectedAluno != null) {
      try {
        final idTurma = widget.turma;

        final alunos = await db.getAlunos();
        final alunoList = alunos
            .where((aluno) => aluno['nome_aluno'].toString() == _selectedAluno)
            .toList();

        if (alunoList.isNotEmpty) {
          final aluno = alunoList.first;

          print(
              'Tentando associar aluno: ${aluno['nome_aluno']} à turma: ${widget.turma}');

          await db.insertAlunoNaTurma(aluno['nome_aluno'], idTurma);
          print('Aluno associado à turma com sucesso');

          // Atualiza a lista de alunos associados após adicionar um novo aluno
          setState(() {});
        } else {
          final aluno = alunoList.first;
          print('Aluno ${aluno['nome_aluno']} não encontrado');
        }
      } catch (e) {
        print('Erro ao associar aluno à turma: $e');
      }
    }
  }
}
