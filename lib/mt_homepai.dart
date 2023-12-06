import 'package:flutter/material.dart';
import 'package:minha_turma/utils/mt_db.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePai extends StatefulWidget {
  const HomePai({Key? key}) : super(key: key);

  @override
  _HomePaiState createState() => _HomePaiState();
}

class _HomePaiState extends State<HomePai> {
  late MinhaTurmaDatabase _databaseManager;
  late List<Map<String, dynamic>> _alunos;
  late List<Map<String, dynamic>> _notas = [];
  List<Map<String, dynamic>> atividades = [];

  TextEditingController codigoAlunoController = TextEditingController();

  bool _showNotas = false;

  @override
  void initState() {
    super.initState();
    _databaseManager = MinhaTurmaDatabase();
    _alunos = [];
    _fetchAlunos();
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

  Future<void> _fetchAlunos() async {
    List<Map<String, dynamic>> alunos = await _databaseManager.getAlunos();
    setState(() {
      _alunos = alunos;
    });
  }

  Future<void> _fetchNotasByCodigo(String codigoAluno) async {
    setState(() {
      _notas = [];
      _showNotas = false;
    });

    try {
      var aluno = _alunos.firstWhere(
        (aluno) => aluno['codigo_aluno'] == codigoAluno,
        orElse: () => {},
      );

      if (aluno.isNotEmpty && aluno.containsKey('id')) {
        int alunoId = aluno['id'];
        List<Map<String, dynamic>> notas =
            await _databaseManager.getNotasByAlunoId(alunoId);

        setState(() {
          _notas = notas;
          _showNotas = true;
        });

        // Navegue para a nova página com as notas
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotasAlunoPage(
              notas: _notas,
              alunoId: alunoId, // Forneça o alunoId aqui
            ),
          ),
        );

        // Para fins de depuração, imprima as notas no console
        print('Notas do aluxno $codigoAluno:');
        for (var nota in _notas) {
          print('Leitura: ${nota['nota_leitura']}');
          print('Escrita: ${nota['nota_escrita']}');
          print('Raciocínio: ${nota['nota_raciocinio']}');
          print('Observações: ${nota['observacoes']}');
          print('---');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Aluno não encontrado ou sem ID. Tente novamente.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Erro ao buscar notas: $error');
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
              Color.fromRGBO(0, 0, 0, 0.99),
              Color.fromRGBO(94, 84, 158, 1),
              Color.fromRGBO(85, 71, 168, 0.80),
            ],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Insira o código do aluno',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 200,
                      child: TextField(
                        controller: codigoAlunoController,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        String codigoAluno = codigoAlunoController.text;
                        await _fetchNotasByCodigo(codigoAluno);
                      },
                      child: Text('Visualizar Notas'),
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
}

class NotasAlunoPage extends StatefulWidget {
  final List<Map<String, dynamic>> notas;
  final int alunoId;

  NotasAlunoPage({required this.notas, required this.alunoId});

  @override
  _NotasAlunoPageState createState() => _NotasAlunoPageState();
}

class _NotasAlunoPageState extends State<NotasAlunoPage> {
  late MinhaTurmaDatabase _databaseManager;
  List<Map<String, dynamic>> atividades = [];

  @override
  void initState() {
    super.initState();
    _databaseManager = MinhaTurmaDatabase();
    _fetchAtividades(widget.alunoId);
  }

  Future<void> _fetchAtividades(int alunoId) async {
    try {
      List<Map<String, dynamic>> resultado =
          await _databaseManager.getAtividadesAluno(alunoId);
      setState(() {
        atividades = resultado;
      });
    } catch (error) {
      print('Erro ao carregar atividades: $error');
    }
  }

  Future<List<String>> getNomesAtividadesVinculadas(int alunoId) async {
    List<Map<String, dynamic>> atividadesAluno =
        await _databaseManager.getAtividadesAluno(alunoId);
    List<int> idsAtividades = atividadesAluno
        .map((atividade) => atividade['id_atividade'] as int)
        .toList();

    List<Map<String, dynamic>> nomesAtividades =
        await _databaseManager.getNomesAtividades(idsAtividades);
    return nomesAtividades
        .map((atividade) => atividade['nome_arquivo'] as String)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        ),
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
          // Aqui você pode usar as notas para exibir as informações na nova página
          child: widget.notas.isEmpty
              ? Center(
                  child: Text(
                    'Nenhuma nota adicionada ao aluno',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: widget.notas.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> nota = widget.notas[index];

                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 1.0),
                      child: ListTile(
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: MediaQuery.of(context).size.height * 0.4,
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        color: Colors.blue,
                                        value:
                                            nota['nota_leitura']?.toDouble() ??
                                                0.0,
                                        title: 'Leitura',
                                        radius: 60,
                                        titleStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      PieChartSectionData(
                                        color: Colors.green,
                                        value:
                                            nota['nota_escrita']?.toDouble() ??
                                                0.0,
                                        title: 'Escrita',
                                        radius: 60,
                                        titleStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      PieChartSectionData(
                                        color: Colors.orange,
                                        value: nota['nota_raciocinio']
                                                ?.toDouble() ??
                                            0.0,
                                        title: 'Raciocínio',
                                        radius: 60,
                                        titleStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                    borderData: FlBorderData(show: false),
                                    centerSpaceRadius: 40,
                                    sectionsSpace: 0,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'Observações sobre o aluno:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                constraints: BoxConstraints(
                                  minHeight:
                                      MediaQuery.of(context).size.height * 0.08,
                                  minWidth: MediaQuery.of(context).size.width *
                                      1, // Defina a altura mínima desejada
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: SingleChildScrollView(
                                  child: Text(
                                    nota['observacoes'] ?? 'Sem observações',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.2,
                              child: atividades.isEmpty
                                  ? Center(
                                      child: Text(
                                        'Nenhuma atividade para o aluno. ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.0,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: 1,
                                      itemBuilder: (context, index) {
                                        return FutureBuilder<List<String>>(
                                          future: getNomesAtividadesVinculadas(
                                              widget.alunoId),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return CircularProgressIndicator(
                                                  color: Colors.white);
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                  'Erro: ${snapshot.error}');
                                            } else if (snapshot.hasData &&
                                                snapshot.data!.isNotEmpty) {
                                              List<String> nomesAtividades =
                                                  snapshot.data!
                                                      .toSet()
                                                      .toList();
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: nomesAtividades
                                                    .map((nome) => Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  bottom: 8.0),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  16.0),
                                                          width:
                                                              double.infinity,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .picture_as_pdf,
                                                                color: Colors
                                                                    .black,
                                                                size: 20.0,
                                                              ),
                                                              SizedBox(
                                                                  width: 8.0),
                                                              Expanded(
                                                                child: Text(
                                                                  nome.length >
                                                                          20
                                                                      ? '${nome.substring(0, 20)}...'
                                                                      : nome,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        12.0,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ))
                                                    .toList(),
                                              );
                                            } else {
                                              return Text(
                                                  'Nenhuma atividade vinculada.');
                                            }
                                          },
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ));
  }
}
