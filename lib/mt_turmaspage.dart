// turmas_page.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'mt_turma_info.dart'; // Importe a nova página
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
    final turmas = await _databaseManager.getTurmas();
    setState(() {
      _turmas = turmas;
    });
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
              Color.fromRGBO(0, 0, 0, 0.86),
              Color.fromRGBO(94, 84, 158, 0.635),
              Color.fromRGBO(85, 71, 168, 0.74),
            ],
          ),
        ),
        child: ListView.builder(
          itemCount: _turmas.length,
          itemBuilder: (context, index) {
            final turma = _turmas[index]['turma'];
            final materia = _turmas[index]['materia'];
            final hashImg = _turmas[index]['hashimg'];

            return GestureDetector(
              onTap: () {
                _navigateToTurmaInfoPage(context, turma, materia, hashImg);
              },
              child: FutureBuilder<String>(
                future: _getImageFilePath(hashImg),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final filePath = snapshot.data!;
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    turma,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                  SizedBox(height: 1),
                                  Text(
                                    materia,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
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
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'image_$hashImg.png';
    return '${appDir.path}/$fileName';
  }

 void _navigateToTurmaInfoPage(BuildContext context, String turma, String materia, String hashImg) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TurmaInfoPage(turma: turma, materia: materia, hashImg: hashImg),
    ),
  );
}

}
