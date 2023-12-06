import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'utils/mt_db.dart';
import 'mt_alunos_info.dart';

class TurmaInfoPage extends StatefulWidget {
  final String turma;
  final String materia;
  final String hashImg;

  TurmaInfoPage({
    required this.turma,
    required this.materia,
    required this.hashImg,
  });

  @override
  _TurmaInfoPageState createState() => _TurmaInfoPageState();
}

class _TurmaInfoPageState extends State<TurmaInfoPage> {
  String? _selectedAluno;
  List<Map<String, dynamic>> _alunosDaTurma = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1000), () {
      _loadAlunosDaTurma();
    });
  }

  void _loadAlunosDaTurma() async {
    final db = MinhaTurmaDatabase();
    final nomeTurma = widget.turma;
    final alunosDaTurma = await db.getAlunosDaTurma(nomeTurma);
    setState(() {
      _alunosDaTurma = alunosDaTurma;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: EdgeInsets.only(top: 40),
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
      child: Column(
        children: [
          // Header
          FutureBuilder<String>(
            future: _getImageFilePath(widget.hashImg),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final filePath = snapshot.data!;
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.0),
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: FileImage(File(filePath)),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(
                              0.6,
                            ),
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
                                shadows: [
                                  Shadow(
                                    color: Colors.white, // Cor da sombra
                                    offset: Offset(1,
                                        1), // Deslocamento da sombra em relação ao texto
                                    blurRadius: 2, // Raio do desfoque da sombra
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Matéria: ${widget.materia}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                shadows: [
                                  Shadow(
                                    color: Colors.white, // Cor da sombra
                                    offset: Offset(1,
                                        1), // Deslocamento da sombra em relação ao texto
                                    blurRadius: 2, // Raio do desfoque da sombra
                                  ),
                                ],
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
            child: Stack(
              children: [
                // Lista de Alunos
                _alunosDaTurma.isEmpty
                    ? Center(
                        child: Text(
                        'Nenhum aluno associado à turma.',
                        style: TextStyle(color: Colors.white),
                      ))
                    : ListView.builder(
                        itemCount: _alunosDaTurma.length,
                        itemBuilder: (context, index) {
                          final aluno = _alunosDaTurma[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetalhesAlunoPage(
                                    nomeAluno: aluno['nome_aluno'],
                                    codigoAluno: aluno['codigo_aluno'],
                                    turmaNome: widget.turma,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    aluno['nome_aluno'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Código: ${aluno['codigo_aluno']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                // Indicador de Carregamento
                if (_isLoading)
                  Container(
                    color: const Color.fromARGB(255, 14, 9, 9).withOpacity(0.8),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
          // Footer
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: FloatingActionButton(
                onPressed: () {
                  _showUserSelectionPopup(context);
                },
                child: Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Future<String> _getImageFilePath(String hashImg) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '$hashImg';
    return '${appDir.path}/$fileName';
  }

  void _showUserSelectionPopup(BuildContext context) async {
    final db = MinhaTurmaDatabase();
    final alunos = await db.getAlunosNaoAssociados(widget.turma);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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

  Future<void> _associateAlunoToTurma() async {
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
              '[INFO][mt_turmas_info.dart]: Tentando associar aluno: ${aluno['nome_aluno']} à turma: ${widget.turma}');

          await db.insertAlunoNaTurma(aluno['nome_aluno'], idTurma);
          print(
              '[INFO][mt_turmas_info.dart]: [INFO][mt_turmas_info.dart]: Aluno associado à turma com sucesso');

          _loadAlunosDaTurma();

          setState(() {
            _selectedAluno = null;
          });
        } else {
          final aluno = alunoList.first;
          print(
              '[INFO][mt_turmas_info.dart]: [INFO][mt_turmas_info.dart]: Aluno ${aluno['nome_aluno']} não encontrado');
        }
      } catch (e) {
        print(
            '[INFO][mt_turmas_info.dart]: [INFO][mt_turmas_info.dart]: Erro ao associar aluno à turma: $e');
      }
    }
  }
}
