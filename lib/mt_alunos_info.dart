import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/mt_db.dart';
import 'dart:math';

class DetalhesAlunoPage extends StatefulWidget {
  final String nomeAluno;
  final String codigoAluno;
  final String turmaNome;

  DetalhesAlunoPage({
    required this.nomeAluno,
    required this.codigoAluno,
    required this.turmaNome,
  });

  @override
  _DetalhesAlunoPageState createState() => _DetalhesAlunoPageState();
}

class _DetalhesAlunoPageState extends State<DetalhesAlunoPage> {
  TextEditingController _leituraController = TextEditingController();
  TextEditingController _escritaController = TextEditingController();
  TextEditingController _raciocinioController = TextEditingController();
  TextEditingController _observacoesController = TextEditingController();

  late MinhaTurmaDatabase _databaseManager;
  late List<Map<String, dynamic>> _alunos;
  late List<Map<String, dynamic>> _notas;
  List<Map<String, dynamic>> atividades = [];
  String? _selectedAtividade;
  List<Map<String, dynamic>> atividades_selecionadas = [];
  List<String> atividades_espelho = [];

  @override
  void initState() {
    super.initState();
    _databaseManager = MinhaTurmaDatabase();
    _alunos = [];
    _fetchAlunos();
    _notas = [];
    _fetchNotas();
    _fetchAtividades();
  }

  Future<void> _fetchAlunos() async {
    List<Map<String, dynamic>> alunos = await _databaseManager.getAlunos();
    setState(() {
      _alunos = alunos;
    });
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

  String _generateRandomCode() {
    const int length = 6; // Define o comprimento do código aleatório
    const String characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(List.generate(length,
        (index) => characters.codeUnitAt(random.nextInt(characters.length))));
  }

  Future<void> _fetchNotas() async {
    List<Map<String, dynamic>> notas = await _databaseManager.getNotas();
    setState(() {
      _notas = notas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color.fromRGBO(0, 0, 0, 0.99),
              Color.fromRGBO(94, 84, 158, 1),
              Color.fromRGBO(85, 71, 168, 0.80),
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.person,
                              color: Colors.black,
                              size: 38,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aluno: ${widget.nomeAluno}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              'Código: ${widget.codigoAluno}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _leituraController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Digite a nota de leitura',
                          border: OutlineInputBorder(),
                          labelText: 'Leitura',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _escritaController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Digite a nota de escrita',
                          border: OutlineInputBorder(),
                          labelText: 'Escrita',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _raciocinioController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Digite a nota de raciocínio',
                          border: OutlineInputBorder(),
                          labelText: 'Raciocínio',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _observacoesController,
                        maxLines: null,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Digite as observações',
                          border: OutlineInputBorder(),
                          labelText: 'Observações',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.0),
                              border: Border.all(
                                color: Colors.black,
                              ),
                              color: Colors.white,
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              underline: Container(),
                              icon: Container(),
                              value: _selectedAtividade,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedAtividade = newValue;
                                  _fetchAtividades();

                                  // Verificar se a atividade já está presente em atividades_selecionadas
                                  bool atividadeExistente =
                                      atividades_selecionadas.any((atividade) =>
                                          atividade["codigo_arquivo"] ==
                                          atividades.firstWhere((atividade) =>
                                                  atividade['nome_arquivo'] ==
                                                  _selectedAtividade)[
                                              'codigo_arquivo']);

                                  if (!atividadeExistente) {
                                    String nomeAtividade = _selectedAtividade!;
                                    if (nomeAtividade.length > 20) {
                                      // Limitar o nome a 15 caracteres e adicionar "..."
                                      nomeAtividade =
                                          nomeAtividade.substring(0, 20) +
                                              "...";
                                    }

                                    atividades_selecionadas.add({
                                      "id": atividades.firstWhere((atividade) =>
                                          atividade['nome_arquivo'] ==
                                          _selectedAtividade)['id'],
                                      "nome_arquivo": nomeAtividade,
                                      "codigo_arquivo": atividades.firstWhere(
                                              (atividade) =>
                                                  atividade['nome_arquivo'] ==
                                                  _selectedAtividade)[
                                          'codigo_arquivo'],
                                    });

                                    print(
                                        "ATIVIDADES SELECIONADAS: ${atividades_selecionadas}");
                                    print("aqui temos alunos/");
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Atividade já selecionada!',
                                          style: TextStyle(
                                              color:
                                                  Colors.white), // Cor do texto
                                        ),
                                        backgroundColor: Colors
                                            .red, // Cor de fundo do SnackBar
                                      ),
                                    );
                                  }
                                });
                              },
                              hint: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Text(
                                      'SELECIONE UMA ATIVIDADE DE REFORÇO',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.4),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                              items: atividades
                                  .map((Map<String, dynamic> atividade) {
                                return DropdownMenuItem<String>(
                                  value: atividade['nome_arquivo'],
                                  child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        atividade['nome_arquivo'],
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Text(
                      'ATIVIDADES PARA O ALUNO:',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      padding: EdgeInsets.all(12),
                      height: MediaQuery.of(context).size.height * 0.2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: Colors.black,
                          width: 0.3,
                        ),
                        color: Colors
                            .white, // Remova esta linha se quiser usar apenas a borda
                      ),
                      child: ListView.separated(
                        separatorBuilder: (context, index) => Divider(),
                        itemCount: atividades_selecionadas.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${atividades_selecionadas[index]["nome_arquivo"]}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    atividades_selecionadas.removeAt(index);
                                  });
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.05,
                                  height:
                                      MediaQuery.of(context).size.height * 0.03,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(55),
                                  ),
                                  child: Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(26.0),
              child: ElevatedButton(
                onPressed: () async {
                  String leitura = _leituraController.text;
                  String escrita = _escritaController.text;
                  String raciocinio = _raciocinioController.text;
                  String observacoes = _observacoesController.text;

                  if (leitura.isEmpty ||
                      escrita.isEmpty ||
                      raciocinio.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Preencha todos os campos de notas.',
                          style: TextStyle(color: Colors.white), // Cor do texto
                        ),
                        backgroundColor: Colors.red, // Cor de fundo do SnackBar
                      ),
                    );

                    return;
                  }

                  List<Map<String, dynamic>> turmas =
                      await _databaseManager.getTurmas();
                  Map<String, dynamic>? alunoSelecionado;
                  Map<String, dynamic>? turmaAluno;

                  for (Map<String, dynamic> aluno in _alunos) {
                    if (aluno['nome_aluno'] == widget.nomeAluno) {
                      alunoSelecionado = aluno;
                      break;
                    }
                  }

                  for (Map<String, dynamic> turma in turmas) {
                    if (turma['nome_turma'] == widget.turmaNome) {
                      turmaAluno = turma;
                      break;
                    }
                  }
                  if (alunoSelecionado != null && turmaAluno != null) {
                    Map<String, dynamic> aluno = alunoSelecionado;
                    Map<String, dynamic> turma = turmas.first;
                    print("[INFO]mt_alunos_info.dart264");
                    print(turma);
                    print(leitura);
                    print(escrita);
                    print(raciocinio);
                    print(observacoes);
                    print(_generateRandomCode());
                    try {
                      await _databaseManager.insertNota(
                        idAluno: alunoSelecionado['id'],
                        idTurma: turmaAluno['id'],
                        notaLeitura: double.parse(leitura),
                        notaEscrita: double.parse(escrita),
                        notaRaciocinio: double.parse(raciocinio),
                        observacoes: observacoes,
                      );

                      // Limpar os campos de entrada após a adição das notas (opcional)
                      _leituraController.clear();
                      _escritaController.clear();
                      _raciocinioController.clear();
                      _observacoesController.clear();
                      print("VINCULADO ATIVIDADE ao ALUNO");
                      await _databaseManager
                          .limparAtividades(alunoSelecionado['id']);
                      for (var atividade in atividades_selecionadas) {
                        print("ID_ATIVIDADE: ${atividade['id']}");
                        print("ID_ALUNO: ${alunoSelecionado['id']}");
                        await _databaseManager.insertAtividadeAluno(
                            atividade['id'], alunoSelecionado['id']);
                      }

                      await _fetchNotas();

                      print('Notas inseridas com sucesso!');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Notas inseridas com sucesso para o aluno ${alunoSelecionado['nome_aluno']}',
                            style:
                                TextStyle(color: Colors.white), // Cor do texto
                          ),
                          backgroundColor:
                              Colors.green[600], // Cor de fundo do SnackBar
                        ),
                      );

                      for (var nota in _notas) {
                        print("[INFO]285(mt_alunos_info.dart) -> $nota");
                      }
                    } catch (e) {
                      print('Erro ao adicionar notas: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao adicionar notas: $e'),
                        ),
                      );
                    }
                  } else {
                    print('Não há alunos ou turmas disponíveis.');
                  }
                },
                child: Text(
                  'ADICIONAR NOTAS',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  minimumSize: Size(double.infinity, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
