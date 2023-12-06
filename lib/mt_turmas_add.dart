import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'utils/mt_db.dart';

class TurmasAddPage extends StatefulWidget {
  @override
  _TurmasAddPageState createState() => _TurmasAddPageState();
}

class _TurmasAddPageState extends State<TurmasAddPage> {
  String? selectedImage;
  String turma = '';
  String materia = '';
  String hashImg = '';
  XFile? pickedFile;
  late MinhaTurmaDatabase _databaseManager;

  @override
  void initState() {
    super.initState();
    _databaseManager = MinhaTurmaDatabase();
  }

  Future<void> _showImagePickerDialog(BuildContext context) async {
    final picker = ImagePicker();
    pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await _resizeImage(pickedFile!.path);
      setState(() {
        selectedImage = pickedFile!.path;
      });
    }
  }

  Future<void> _resizeImage(String path) async {
    final bytes = await File(path).readAsBytes();
    final image = img.decodeImage(Uint8List.fromList(bytes))!;
    final resizedImage = img.copyResize(image, width: 300, height: 160);

    final hashBytes = Uint8List.fromList(resizedImage.getBytes());
    final hash = hashBytes.hashCode.toUnsigned(20).toRadixString(16);
    setState(() {
      hashImg = hash;
    });

    final appDocumentsDirectory = await getApplicationDocumentsDirectory();
    final fileName = 'image_$hash.png';
    final filePath = '${appDocumentsDirectory.path}/$fileName';

    await File(filePath).writeAsBytes(img.encodePng(resizedImage));

    pickedFile = XFile(filePath);
  }

  Future<void> _addToDatabase() async {
    if (turma.isNotEmpty && materia.isNotEmpty && hashImg.isNotEmpty) {
      final fileName = 'image_$hashImg.png';
      final filePath = await _resizeImage(selectedImage!);
      await _databaseManager.insertTurma(turma, materia, fileName);
      final turmas = await _databaseManager.getTurmas();
      print('[INFO][mt_turmasadd.dart]: Dados no banco: $turmas');
      Navigator.of(context).pop();
    } else {
      print(
          '[INFO][mt_turmasadd.dart]: Erro: Preencha todos os campos antes de criar uma turma.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Criar turma'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.3385, 0.6354, 0.875],
            colors: [
              Color.fromRGBO(85, 71, 168, 0.80),
              Color.fromRGBO(94, 84, 158, 1),
              Color.fromRGBO(0, 0, 0, 0.99),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16.0),
              height: 180,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
                color: Color.fromARGB(255, 73, 72, 72),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Stack(
                children: [
                  if (selectedImage != null)
                    Image.file(
                      File(selectedImage!),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () async {
                        await _showImagePickerDialog(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            print(
                                'Botão "Criar" pressionado'); // Mensagem de depuração
                            await _addToDatabase();

                            print(
                                'Operação _addToDatabase concluída'); // Mensagem de depuração
                          },
                          child: Text(
                            'Criar',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    buildTextField('Nome da Turma', turma),
                    SizedBox(height: 10),
                    buildTextField('Matéria', materia),
                    Expanded(
                      child: SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withOpacity(0.8),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ]),
          child: TextField(
            onChanged: (value) {
              if (label == 'Nome da Turma') {
                turma = value;
              } else if (label == 'Matéria') {
                materia = value;
              }
            },
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
