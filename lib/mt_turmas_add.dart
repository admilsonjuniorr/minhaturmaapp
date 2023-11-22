import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

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

  Future<void> _showImagePickerDialog(BuildContext context) async {
    await Future.delayed(Duration.zero);
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
    final bytes = File(path).readAsBytesSync();
    final image = img.decodeImage(Uint8List.fromList(bytes))!;
    final resizedImage = img.copyResize(image, width: 300, height: 160);

    final hashBytes = Uint8List.fromList(resizedImage.getBytes());
    final hash = hashBytes.hashCode.toUnsigned(20).toRadixString(16);
    setState(() {
      hashImg = hash;
    });

    final fileName = 'image_$hash.png';
    final filePath =
        '/data/user/0/com.example.minha_turma/app_flutter/$fileName';

    File(filePath).writeAsBytesSync(img.encodePng(resizedImage));

    pickedFile = XFile(filePath);
  }

  Future<void> _addToDatabase() async {
    if (turma.isNotEmpty && materia.isNotEmpty && hashImg.isNotEmpty) {
      final databaseManager = MinhaTurmaDatabase.instance;
      await databaseManager.insertTurma(turma, materia, hashImg);
      final turmas = await databaseManager.getTurmas();
      print('Dados no banco: $turmas');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('criarturma.dart');
    return Scaffold(
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
              Color.fromRGBO(85, 71, 168, 0.74),
              Color(0xFF5E549E),
              Color.fromRGBO(0, 0, 0, 0.86),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header (Imagem)
            Container(
              margin: const EdgeInsets.all(16.0),
              height: 180,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.),
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
            // Container Cinza com Margem (Botão Criar e Inputs)
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
                            await _addToDatabase();
                            Navigator.of(context).pop();
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
