import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'mt_turma_info.dart';
import 'mt_turmas_add.dart';
import 'utils/mt_db.dart';

class TurmasPage extends StatefulWidget {
  @override
  _TurmasPageState createState() => _TurmasPageState();
}

class _TurmasPageState extends State<TurmasPage> {
  late MinhaTurmaDatabase _databaseManager;
  late List<Map<String, dynamic>> _turmas;

  @override
  void initState() {
    super.initState();
    _databaseManager = MinhaTurmaDatabase();
    _turmas = [];
    _fetchTurmas();
  }

  Future<void> _fetchTurmas() async {
    try {
      final turmas = await _databaseManager.getTurmas();
      if (turmas.isEmpty) {
        print('[INFO][mt_turmaspage.dart]: Nenhuma turma cadastrada!');
      } else {
        print('[INFO][mt_turmaspage.dart]: Turmas no banco de dados: $turmas');
      }
      setState(() {
        _turmas = turmas;
      });
    } catch (e) {
      print(
          '[INFO][mt_turmaspage.dart]: Erro ao obter turmas do banco de dados: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: _turmas.isEmpty
            ? Center(
                child: Text(
                  'Nenhuma turma cadastrada!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: _turmas.length,
                itemBuilder: (context, index) {
                  final turma = _turmas[index]['nome_turma'] ?? '';
                  final materia = _turmas[index]['materia'] ?? '';
                  final hashImg = _turmas[index]['hash_img'] ?? '';
                  print("linha 73");
                  print(turma);
                  return GestureDetector(
                    onTap: () {
                      _navigateToTurmaInfoPage(
                          context, turma, materia, hashImg);
                    },
                    child: FutureBuilder<String>(
                      future: _getImageFilePath(hashImg),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          final filePath = snapshot.data!;
                          print(filePath);
                          return Card(
                            margin: EdgeInsets.all(16.0),
                            child: Container(
                              height: 160,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      image: DecorationImage(
                                        image: FileImage(File(filePath)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          turma,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                color: Colors
                                                    .black, // Cor da sombra
                                                offset: Offset(1,
                                                    1), // Deslocamento da sombra em relação ao texto
                                                blurRadius:
                                                    2, // Raio do desfoque da sombra
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 1),
                                        Text(
                                          materia,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                color: Colors
                                                    .black, // Cor da sombra
                                                offset: Offset(1,
                                                    1), // Deslocamento da sombra em relação ao texto
                                                blurRadius:
                                                    2, // Raio do desfoque da sombra
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TurmasAddPage(),
            ),
          ).then((_) {
            _fetchTurmas();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<String> _getImageFilePath(String hashImg) async {
    print(
        '[INFO][mt_turmaspage.dart]: Valor de hashImg em _getImageFilePath: $hashImg');
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '$hashImg';
    return '${appDir.path}/$fileName';
  }

  void _navigateToTurmaInfoPage(
      BuildContext context, String turma, String materia, String hashImg) {
    print(turma);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TurmaInfoPage(turma: turma, materia: materia, hashImg: hashImg),
      ),
    );
  }
}
