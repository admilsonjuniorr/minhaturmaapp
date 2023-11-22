// No arquivo mt_db.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MinhaTurmaDatabase {
  late Database _database;
  
  static final MinhaTurmaDatabase _instance = MinhaTurmaDatabase._internal();

  factory MinhaTurmaDatabase() {
    return _instance;
  }

  MinhaTurmaDatabase._internal();


  Future<void> open() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'minha_turma.db');

    _database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // Criação das tabelas
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
            nome_turma TEXT
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
    });
  }

  Future<List<Map<String, dynamic>>> getAlunos() async {
    await open();
    return await _database.query('alunos');
  }

  Future<List<Map<String, dynamic>>> getTurmas() async {
    await open();
    return await _database.query('turmas');
  }

  Future<void> insertAluno(String nomeAluno, String codigoAluno) async {
    await open();
    await _database.insert(
      'alunos',
      {'nome_aluno': nomeAluno, 'codigo_aluno': codigoAluno},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertTurma(String nomeTurma) async {
    await open();
    await _database.insert(
      'turmas',
      {'nome_turma': nomeTurma},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertAlunoNaTurma(String nomeAluno, String nomeTurma) async {
    await open();
    final aluno = await _database.query(
      'alunos',
      where: 'nome_aluno = ?',
      whereArgs: [nomeAluno],
    );

    final turma = await _database.query(
      'turmas',
      where: 'nome_turma = ?',
      whereArgs: [nomeTurma],
    );

    if (aluno.isNotEmpty && turma.isNotEmpty) {
      await _database.insert(
        'alunos_turmas',
        {
          'id_aluno': aluno.first['id'],
          'id_turma': turma.first['id'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
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

  Future<List<Map<String, dynamic>>> getAlunosNaoAssociados(String nomeTurma) async {
    await open();
    return await _database.rawQuery('''
      SELECT alunos.id, alunos.nome_aluno, alunos.codigo_aluno
      FROM alunos
      WHERE alunos.id NOT IN (
        SELECT alunos.id
        FROM alunos
        INNER JOIN alunos_turmas ON alunos.id = alunos_turmas.id_aluno
        INNER JOIN turmas ON alunos_turmas.id_turma = turmas.id
        WHERE turmas.nome_turma = ?
      )
    ''', [nomeTurma]);
  }
}
