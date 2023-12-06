import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

class MinhaTurmaDatabase with ChangeNotifier {
  late Database _database;
  String _nomeUsuario = '';
  String get nomeUsuario => _nomeUsuario;

  static final MinhaTurmaDatabase _instance = MinhaTurmaDatabase._internal();
  void setNomeUsuario(String novoNomeUsuario) {
    _nomeUsuario = novoNomeUsuario;
    notifyListeners();

    // Agora você pode usar o Locator.context onde precisar dele.
    // Exemplo: ScaffoldMessenger.of(Locator.context).showSnackBar(SnackBar(...));
  }

  factory MinhaTurmaDatabase() {
    return _instance;
  }

  MinhaTurmaDatabase._internal();

  bool _isOpen = false;

  bool get isOpen => _isOpen;

  Future<void> open() async {
    if (!_isOpen) {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'minha_turmadb.db');

      _database = await openDatabase(path,
          version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
      _isOpen = true;

      // Notificar ouvintes sobre a mudança de estado
      notifyListeners();
    }
  }

  Future<void> deleteAtividade(String codigo_arquivo) async {
    try {
      await _database.delete('atividades',
          where: 'codigo_arquivo = ?', whereArgs: [codigo_arquivo]);
      print('Atividade removida com sucesso!');
    } catch (error) {
      print('Erro ao remover atividade: $error');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Lógica de criação de tabelas
    await db.execute('''
  CREATE TABLE atividades (
    id INTEGER PRIMARY KEY,
    nome_arquivo TEXT,
    caminho_arquivo TEXT,
    codigo_arquivo TEXT
  )
''');
    await db.execute('''
CREATE TABLE atividades_alunos (
    id INTEGER PRIMARY KEY,
    id_atividade INTEGER,
    id_aluno INTEGER,
    FOREIGN KEY (id_atividade) REFERENCES atividades(id),
    FOREIGN KEY (id_aluno) REFERENCES alunos(codigo_aluno)
)
  ''');
    await db.execute('''
    CREATE TABLE mt_usuarios (
      id INTEGER PRIMARY KEY,
      nome_usuario TEXT,
      email_usuario TEXT,
      senha_usuario TEXT,
      tipo_usuario TEXT
    )
  ''');
    await db.execute('''
    CREATE TABLE alunos (
      id INTEGER PRIMARY KEY,
      nome_aluno TEXT,
      codigo_aluno TEXT
    )
  ''');
    await db.execute('''
    CREATE TABLE turmas (
      id INTEGER PRIMARY KEY,
      nome_turma TEXT,
      materia TEXT,
      hash_img TEXT
    )
  ''');
    await db.execute('''
    CREATE TABLE notas (
      id INTEGER PRIMARY KEY,
      id_aluno INTEGER,
      id_turma INTEGER,
      nota_leitura REAL,
      nota_escrita REAL,
      nota_raciocinio REAL,
      observacoes TEXT,
      atividades TEXT,
      FOREIGN KEY (id_aluno) REFERENCES alunos (id),
      FOREIGN KEY (id_turma) REFERENCES turmas (id)
    )
  ''');
    await db.execute('''
    CREATE TABLE alunos_turmas (
      id INTEGER PRIMARY KEY,
      id_aluno INTEGER,
      id_turma INTEGER,
      FOREIGN KEY (id_aluno) REFERENCES alunos (id),
      FOREIGN KEY (id_turma) REFERENCES turmas (id)
    )
  ''');
  }

  Future<List<Map<String, dynamic>>> getAtividadesAluno(int? idAluno) async {
    await open();
    return await _database.query('atividades_alunos',
        columns: ['id_atividade'], where: 'id_aluno = ?', whereArgs: [idAluno]);
  }

  Future<List<Map<String, dynamic>>> getNomesAtividades(
      List<int> idsAtividades) async {
    await open();
    return await _database.query('atividades',
        columns: ['id', 'nome_arquivo'],
        where: 'id IN (${idsAtividades.map((id) => '?').join(',')})',
        whereArgs: idsAtividades);
  }

  Future<void> limparAtividades(int idAluno) async {
    try {
      await _database.delete(
        'atividades_alunos',
        where: 'id_aluno = ?',
        whereArgs: [idAluno],
      );
    } catch (error) {
      print('Erro ao LIMPAR/APAGAR atividade do aluno: $error');
    }
  }

  Future<void> insertAtividadeAluno(int idAtividade, int idAluno) async {
    try {
      await _database.insert(
        'atividades_alunos',
        {
          'id_atividade': idAtividade,
          'id_aluno': idAluno,
        },
      );
    } catch (error) {
      print('Erro ao inserir atividade do aluno: $error');
    }
  }

  Future<void> createUser(String nomeUsuario, String emailUsuario,
      String senhaUsuario, String tipoUsuario) async {
    try {
      await _database.insert(
        'mt_usuarios',
        {
          'nome_usuario': nomeUsuario,
          'email_usuario': emailUsuario,
          'senha_usuario': senhaUsuario,
          'tipo_usuario': tipoUsuario,
        },
      );
    } catch (error) {
      print('Erro ao criar usuario: $error');
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Lógica para atualizar a estrutura do banco de dados, se necessário
    if (oldVersion == 1 && newVersion == 2) {
      // Exemplo: Adicionando a coluna hash_img à tabela turmas
      await db.execute('ALTER TABLE turmas ADD COLUMN hash_img TEXT');
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    await open();
    return await _database.query('mt_usuarios');
  }

  Future<List<Map<String, dynamic>>> getAtividades() async {
    await open();
    return await _database.query('atividades');
  }

  Future<List<Map<String, dynamic>>> getAlunos() async {
    await open();
    return await _database.query('alunos');
  }

  Future<List<Map<String, dynamic>>> getTurmas() async {
    await open();
    return await _database.query('turmas');
  }

  Future<List<Map<String, dynamic>>> getNotas() async {
    await open();
    return await _database.query('notas');
  }

  Future<void> insertAluno(String nomeAluno, String codigoAluno) async {
    await open();
    await _database.insert(
      'alunos',
      {'nome_aluno': nomeAluno, 'codigo_aluno': codigoAluno},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // Notificar ouvintes sobre a mudança de estado
    notifyListeners();
  }

  Future<void> insertAtividade(
    String nomeArquivo,
    String caminhoArquivo,
    String codigoArquivo,
  ) async {
    await open();
    await _database.insert(
      'atividades',
      {
        'nome_arquivo': nomeArquivo,
        'caminho_arquivo': caminhoArquivo,
        'codigo_arquivo': codigoArquivo,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifyListeners();
  }

  Future<void> insertTurma(
      String nomeTurma, String materia, String hashImg) async {
    await open();
    await _database.insert(
      'turmas',
      {'nome_turma': nomeTurma, 'materia': materia, 'hash_img': hashImg},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // Notificar ouvintes sobre a mudança de estado
    notifyListeners();
  }

  Future<bool> insertAlunoNaTurma(String nomeAluno, String nomeTurma) async {
    await open();

    // Verifica se o aluno já está associado a outra turma
    final alunoAssociado = await _database.rawQuery('''
    SELECT alunos.id
    FROM alunos
    INNER JOIN alunos_turmas ON alunos.id = alunos_turmas.id_aluno
    INNER JOIN turmas ON alunos_turmas.id_turma = turmas.id
    WHERE alunos.nome_aluno = ? AND turmas.nome_turma <> ?
  ''', [nomeAluno, nomeTurma]);

    if (alunoAssociado.isNotEmpty) {
      print('O aluno $nomeAluno já está associado a outra turma.');
      return false;
    }

    // Verifica se a turma existe
    final turma = await _database.query(
      'turmas',
      where: 'nome_turma = ?',
      whereArgs: [nomeTurma],
    );

    if (turma.isEmpty) {
      print('A turma $nomeTurma não foi encontrada.');
      return false;
    }

    // Verifica se o aluno existe
    final aluno = await _database.query(
      'alunos',
      where: 'nome_aluno = ?',
      whereArgs: [nomeAluno],
    );

    if (aluno.isNotEmpty) {
      await _database.insert(
        'alunos_turmas',
        {
          'id_aluno': aluno.first['id'],
          'id_turma': turma.first['id'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Notificar ouvintes sobre a mudança de estado
      notifyListeners();
      print('Aluno $nomeAluno associado à turma $nomeTurma com sucesso.');
      return true;
    } else {
      print('O aluno $nomeAluno não foi encontrado.');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAlunosDaTurma(String nomeTurma) async {
    await open();
    return await _database.rawQuery('''
      SELECT alunos.id, alunos.nome_aluno, alunos.codigo_aluno
      FROM alunos
      INNER JOIN alunos_turmas ON alunos.id = alunos_turmas.id_aluno
      INNER JOIN turmas ON alunos_turmas.id_turma = turmas.id
      WHERE turmas.nome_turma = ?
    ''', [nomeTurma]);
  }

  Future<List<Map<String, dynamic>>> getAlunosNaoAssociados(
      String nomeTurma) async {
    await open();
    return await _database.rawQuery('''
    SELECT alunos.id, alunos.nome_aluno, alunos.codigo_aluno
    FROM alunos
    WHERE alunos.id NOT IN (
      SELECT alunos.id
      FROM alunos
      INNER JOIN alunos_turmas ON alunos.id = alunos_turmas.id_aluno
      INNER JOIN turmas ON alunos_turmas.id_turma = turmas.id
    )
  ''');
  }

  Future<void> insertNota({
    required int idAluno,
    required int idTurma,
    required double notaLeitura,
    required double notaEscrita,
    required double notaRaciocinio,
    required String observacoes,
  }) async {
    await open();

    // Verifica se já existe um registro para o aluno na tabela notas
    List<Map<String, dynamic>> existingNotes = await _database.query(
      'notas',
      where: 'id_aluno = ?',
      whereArgs: [idAluno],
      limit: 1,
    );

    if (existingNotes.isNotEmpty) {
      // Já existe um registro, então faz o update
      await _database.update(
        'notas',
        {
          'nota_leitura': notaLeitura,
          'nota_escrita': notaEscrita,
          'nota_raciocinio': notaRaciocinio,
          'observacoes': observacoes,
        },
        where: 'id_aluno = ?',
        whereArgs: [idAluno],
      );
    } else {
      // Não existe um registro, então faz a inserção
      await _database.insert(
        'notas',
        {
          'id_aluno': idAluno,
          'id_turma': idTurma,
          'nota_leitura': notaLeitura,
          'nota_escrita': notaEscrita,
          'nota_raciocinio': notaRaciocinio,
          'observacoes': observacoes,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getNotasByAlunoId(int alunoId) async {
    await open();

    return await _database.rawQuery('''
    SELECT * FROM notas WHERE id_aluno = ?
  ''', [alunoId]);
  }

  Future<List<Map<String, dynamic>>> getNotasByCodigoAluno(
      int codigoAluno) async {
    await open();

    var result = await _database.rawQuery('''
    SELECT id FROM alunos WHERE codigo_aluno = ?
  ''', [codigoAluno]);

    if (result.isEmpty) {
      return []; // Código de aluno não encontrado, retorna uma lista vazia
    }

    int alunoId = result.first['id'] as int;

    return await _database.rawQuery('''
    SELECT * FROM notas WHERE id_aluno = ?
  ''', [alunoId]);
  }
}
