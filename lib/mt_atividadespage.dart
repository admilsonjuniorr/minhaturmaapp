import 'dart:math';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'utils/mt_db.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AtividadesPage(),
    );
  }
}

String truncateName(String name, int maxLength) {
  if (name.length > maxLength) {
    return '${name.substring(0, maxLength)}...';
  }
  return name;
}

class AtividadesPage extends StatefulWidget {
  @override
  _AtividadesPageState createState() => _AtividadesPageState();
}

class _AtividadesPageState extends State<AtividadesPage> {
  List<Map<String, dynamic>> atividades = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late MinhaTurmaDatabase _databaseManager;

  @override
  void initState() {
    super.initState();
    _databaseManager = MinhaTurmaDatabase();
    _fetchAtividades();
  }

  Future<void> _fetchAtividades() async {
    try {
      List<Map<String, dynamic>> resultado =
          await _databaseManager.getAtividades();
      setState(() {
        atividades = resultado;
      });
    } catch (error) {
      print('Erro ao carregar atividades: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Atividades'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(94, 84, 158, 1),
              Color.fromRGBO(85, 71, 168, 0.74),
              Color.fromRGBO(0, 0, 0, 1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: atividades.isEmpty
            ? Center(
                child: Text(
                  'Nenhuma atividade adicionada',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: atividades.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> atividade = atividades[index];
                  String codigoArquivo = atividade['codigo_arquivo'];
                  String nomeArquivo = truncateName(
                      path.basename(atividade['nome_arquivo'] ?? ''), 25);

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Row(
                          children: [
                            Icon(Icons.insert_drive_file),
                            SizedBox(width: 8),
                            Text(
                              nomeArquivo,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        trailing: GestureDetector(
                          onTap: () async {
                            bool? removeItem = await _showConfirmationDialog();
                            if (removeItem ?? false) {
                              try {
                                await _databaseManager
                                    .deleteAtividade(codigoArquivo);
                                await _fetchAtividades();
                              } catch (error) {
                                print(
                                    'Erro ao remover ou buscar atividades: $error');
                              }
                              _scaffoldKey.currentState
                                  ?.showBodyScrim(false, 0);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.clear,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var status = await Permission.storage.status;
          if (status.isDenied) {
            await Permission.storage.request();
          }

          String? filePath = await _pickPDFFile();
          if (filePath != null) {
            String nomeArquivo = path.basename(filePath);
            bool arquivoExistente = atividades.any(
              (atividade) => atividade['nome_arquivo'] == nomeArquivo,
            );

            if (arquivoExistente) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Arquivo de atividade já inserido anteriormente!',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              print('Erro: Este arquivo já existe na lista ou banco de dados.');
            } else {
              String codigoArquivo = generateRandomCode();
              String caminhoArquivo = filePath;

              await _databaseManager.insertAtividade(
                nomeArquivo,
                caminhoArquivo,
                codigoArquivo,
              );

              await _fetchAtividades();
            }
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<String?> _pickPDFFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        return result.files.single.path;
      }
    } catch (e) {
      print('Erro ao selecionar o arquivo: $e');
    }

    return null;
  }

  Future<bool?> _showConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmação'),
          content: Text('Tem certeza de que deseja remover esta atividade?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String generateRandomCode() {
    final String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final Random random = Random();
    return String.fromCharCodes(
      List.generate(
        8,
        (index) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
}
