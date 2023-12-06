import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:minha_turma/mt_turmaspage.dart';
import 'mt_alunospage.dart';
import 'mt_perfil.dart';
import 'utils/mt_db.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePageContent extends StatefulWidget {
  final String label;

  const HomePageContent({Key? key, required this.label}) : super(key: key);
  @override
  _HomePageContentState createState() => _HomePageContentState();
}

Widget _buildNotaBlock(String categoria, String valorNota, Color cor) {
  return Container(
    color: Colors.grey[300],
    padding: EdgeInsets.all(3.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 20,
          height: 20,
          color: cor,
        ),
        SizedBox(width: 8.0),
        Text(
          '$categoria',
          style: TextStyle(fontSize: 16, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        SizedBox(width: 8.0),
        Text(
          'Nota: $valorNota',
          style: TextStyle(fontSize: 16, color: Colors.black),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _HomePageContentState extends State<HomePageContent> {
  late MinhaTurmaDatabase _databaseManager;
  late List<Map<String, dynamic>> _alunos;
  late List<Map<String, dynamic>> _notas = [];
  List<Map<String, dynamic>> atividades = [];

  int? _selectedAlunoId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _databaseManager = MinhaTurmaDatabase();
    _alunos = [];
    _fetchAlunos();
    _fetchAtividades();
  }

  String truncateName(String name, int maxLength) {
    if (name.length > maxLength) {
      return '${name.substring(0, maxLength)}...';
    }
    return name;
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

  Future<void> _fetchNotas() async {
    if (_selectedAlunoId != null) {
      setState(() {
        _isLoading = true;
      });

      // Aguarde 130 milissegundos antes de chamar _fetchNotas
      await Future.delayed(Duration(milliseconds: 500));

      // Chame _fetchNotas após o atraso
      List<Map<String, dynamic>> notas =
          await _databaseManager.getNotasByAlunoId(_selectedAlunoId!);
      setState(() {
        _notas = notas;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 30,
                color: Colors.white,
                child: DropdownButton<int>(
                  value: _selectedAlunoId,
                  items: _alunos.map((aluno) {
                    return DropdownMenuItem<int>(
                      value: aluno['id'],
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          aluno['nome_aluno'],
                          style: TextStyle(color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    setState(() {
                      _selectedAlunoId = value;
                    });

                    // Ativar o indicador de carregamento durante a busca de notas
                    _fetchNotas();
                  },
                  style: TextStyle(color: Colors.black),
                  hint: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Selecione o aluno',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  isExpanded: true,
                  underline: Container(),
                  dropdownColor: Colors.white,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.005),
              Expanded(
                child: _notas.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhuma nota adicionada',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _notas.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> nota = _notas[index];

                          Map<String, dynamic> notasData = {
                            'nota_leitura': nota['nota_leitura'],
                            'nota_escrita': nota['nota_escrita'],
                            'nota_raciocinio': nota['nota_raciocinio'],
                          };

                          return Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 1.0),
                            child: ListTile(
                              title: Container(
                                padding: EdgeInsets.all(0.5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        _buildNotaBlock(
                                          'Leitura',
                                          nota['nota_leitura'].toString(),
                                          Colors.blue,
                                        ),
                                        SizedBox(height: 16.0),
                                        _buildNotaBlock(
                                          'Escrita',
                                          nota['nota_escrita'].toString(),
                                          Colors.green,
                                        ),
                                        SizedBox(height: 16.0),
                                        _buildNotaBlock(
                                          'Raciocínio',
                                          nota['nota_raciocinio'].toString(),
                                          Colors.orange,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 200,
                                      child: PieChart(
                                        PieChartData(
                                          sections: [
                                            PieChartSectionData(
                                              color: Colors.blue,
                                              value: notasData['nota_leitura']
                                                      ?.toDouble() ??
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
                                              value: notasData['nota_escrita']
                                                      ?.toDouble() ??
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
                                              value:
                                                  notasData['nota_raciocinio']
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
                                            MediaQuery.of(context).size.height *
                                                0.08,
                                        minWidth: MediaQuery.of(context)
                                                .size
                                                .width *
                                            1, // Defina a altura mínima desejada
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Text(
                                          nota['observacoes'] ??
                                              'Sem observações',
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
                                    height: MediaQuery.of(context).size.height *
                                        0.13,
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
                                              return FutureBuilder<
                                                  List<String>>(
                                                future:
                                                    getNomesAtividadesVinculadas(
                                                        _selectedAlunoId ?? 0),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return CircularProgressIndicator(
                                                        color: Colors.white);
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Text(
                                                        'Erro: ${snapshot.error}');
                                                  } else if (snapshot.hasData &&
                                                      snapshot
                                                          .data!.isNotEmpty) {
                                                    List<String>
                                                        nomesAtividades =
                                                        snapshot.data!
                                                            .toSet()
                                                            .toList();
                                                    return Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: nomesAtividades
                                                          .map(
                                                              (nome) =>
                                                                  Container(
                                                                    margin: EdgeInsets.only(
                                                                        bottom:
                                                                            8.0),
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            16.0),
                                                                    width: double
                                                                        .infinity,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0),
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .picture_as_pdf,
                                                                          color:
                                                                              Colors.black,
                                                                          size:
                                                                              20.0,
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                8.0),
                                                                        Expanded(
                                                                          child:
                                                                              Text(
                                                                            nome.length > 20
                                                                                ? '${nome.substring(0, 20)}...'
                                                                                : nome,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 12.0,
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
              ),
            ],
          ),
          // Adicionando o indicador de carregamento
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Container(),
        ],
      ),
    );
  }
}

Widget _legendItem(Color color, String text) {
  return Row(
    children: [
      Container(
        width: 26,
        height: 16,
        color: color,
      ),
      SizedBox(width: 8),
      Text(
        text,
        style: TextStyle(fontSize: 14),
      ),
    ],
  );
}

class HomePage extends StatefulWidget {
  final String nomeDoProfessor;

  HomePage({required this.nomeDoProfessor, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    _pages = [
      HomePageContent(label: 'Home'),
      TurmasPage(),
      AlunosPage(),
      PerfilPage(nomeDoProfessor: widget.nomeDoProfessor),
    ];
  }

  @override
  Widget build(BuildContext context) {
    print('[PAGE] => widget MENU.dart');
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: Color.fromARGB(255, 209, 208, 208),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            backgroundColor: Color.fromARGB(255, 209, 208, 208),
            color: Colors.black,
            tabBackgroundColor: Colors.grey.shade400,
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            tabs: const [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.class_sharp, text: 'Turmas'),
              GButton(icon: Icons.person, text: 'Alunos'),
              GButton(icon: Icons.engineering, text: 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }
}