import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ckcandr/models/ai_chat_model.dart';

class AiDatabaseService {
  static final AiDatabaseService _instance = AiDatabaseService._internal();
  factory AiDatabaseService() => _instance;
  AiDatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'ai_chat.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tạo bảng chat sessions
    await db.execute('''
      CREATE TABLE chat_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        summary TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        user_id TEXT,
        model TEXT NOT NULL DEFAULT 'gemini-2.5-flash'
      )
    ''');

    // Tạo bảng chat messages
    await db.execute('''
      CREATE TABLE chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        message TEXT NOT NULL,
        is_user INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        user_id TEXT,
        FOREIGN KEY (session_id) REFERENCES chat_sessions (id) ON DELETE CASCADE
      )
    ''');

    // Tạo bảng settings
    await db.execute('''
      CREATE TABLE ai_settings (
        id INTEGER PRIMARY KEY,
        api_key TEXT,
        model TEXT NOT NULL DEFAULT 'gemini-1.5-flash',
        temperature REAL NOT NULL DEFAULT 0.7,
        max_tokens INTEGER NOT NULL DEFAULT 8192
      )
    ''');

    // Insert default settings
    await db.insert('ai_settings', {
      'id': 1,
      'model': 'gemini-1.5-flash',
      'temperature': 0.7,
      'max_tokens': 8192,
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Tạo bảng chat sessions
      await db.execute('''
        CREATE TABLE chat_sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          summary TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          user_id TEXT,
          model TEXT NOT NULL DEFAULT 'gemini-2.5-flash'
        )
      ''');

      // Thêm session_id vào chat_messages
      await db.execute('ALTER TABLE chat_messages ADD COLUMN session_id INTEGER DEFAULT 1');

      // Tạo session mặc định cho messages hiện có
      await db.insert('chat_sessions', {
        'title': 'Chat mặc định',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'model': 'gemini-2.5-flash',
      });
    }
  }

  // Chat Sessions Methods
  Future<int> insertSession(AiChatSession session) async {
    final db = await database;
    return await db.insert('chat_sessions', {
      'title': session.title,
      'summary': session.summary,
      'created_at': session.createdAt.toIso8601String(),
      'updated_at': session.updatedAt.toIso8601String(),
      'user_id': session.userId,
      'model': session.model,
    });
  }

  Future<List<AiChatSession>> getSessions({String? userId}) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'chat_sessions',
      where: userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => AiChatSession(
      id: map['id'],
      title: map['title'],
      summary: map['summary'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      userId: map['user_id'],
      model: map['model'],
    )).toList();
  }

  Future<void> updateSession(AiChatSession session) async {
    final db = await database;
    await db.update(
      'chat_sessions',
      {
        'title': session.title,
        'summary': session.summary,
        'updated_at': session.updatedAt.toIso8601String(),
        'model': session.model,
      },
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<void> deleteSession(int sessionId) async {
    final db = await database;
    await db.delete(
      'chat_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // Chat Messages Methods
  Future<int> insertMessage(AiChatMessage message) async {
    final db = await database;
    return await db.insert('chat_messages', {
      'session_id': message.sessionId,
      'message': message.message,
      'is_user': message.isUser ? 1 : 0,
      'timestamp': message.timestamp.toIso8601String(),
      'user_id': message.userId,
    });
  }

  Future<List<AiChatMessage>> getMessages({int? sessionId, String? userId, int? limit}) async {
    final db = await database;

    List<String> conditions = [];
    List<dynamic> args = [];

    if (sessionId != null) {
      conditions.add('session_id = ?');
      args.add(sessionId);
    }

    if (userId != null) {
      conditions.add('user_id = ?');
      args.add(userId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'chat_messages',
      where: conditions.isNotEmpty ? conditions.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'timestamp ASC',
      limit: limit,
    );

    return maps.map((map) => AiChatMessage(
      id: map['id'],
      sessionId: map['session_id'],
      message: map['message'],
      isUser: map['is_user'] == 1,
      timestamp: DateTime.parse(map['timestamp']),
      userId: map['user_id'],
    )).toList();
  }

  Future<int> getMessageCount({int? sessionId, String? userId}) async {
    final db = await database;

    List<String> conditions = [];
    List<dynamic> args = [];

    if (sessionId != null) {
      conditions.add('session_id = ?');
      args.add(sessionId);
    }

    if (userId != null) {
      conditions.add('user_id = ?');
      args.add(userId);
    }

    final whereClause = conditions.isNotEmpty ? ' WHERE ${conditions.join(' AND ')}' : '';
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM chat_messages$whereClause',
      args.isNotEmpty ? args : null,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> deleteAllMessages({int? sessionId, String? userId}) async {
    final db = await database;

    List<String> conditions = [];
    List<dynamic> args = [];

    if (sessionId != null) {
      conditions.add('session_id = ?');
      args.add(sessionId);
    }

    if (userId != null) {
      conditions.add('user_id = ?');
      args.add(userId);
    }

    if (conditions.isNotEmpty) {
      await db.delete(
        'chat_messages',
        where: conditions.join(' AND '),
        whereArgs: args,
      );
    } else {
      await db.delete('chat_messages');
    }
  }

  Future<void> deleteMessage(int id) async {
    final db = await database;
    await db.delete(
      'chat_messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Settings Methods
  Future<AiSettings> getSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ai_settings',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return AiSettings(
        apiKey: map['api_key'],
        model: map['model'] ?? 'gemini-1.5-flash',
        temperature: map['temperature'] ?? 0.7,
        maxTokens: map['max_tokens'] ?? 8192,
      );
    }

    return const AiSettings();
  }

  Future<void> updateSettings(AiSettings settings) async {
    final db = await database;
    await db.update(
      'ai_settings',
      {
        'api_key': settings.apiKey,
        'model': settings.model,
        'temperature': settings.temperature,
        'max_tokens': settings.maxTokens,
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> updateApiKey(String apiKey) async {
    final db = await database;
    await db.update(
      'ai_settings',
      {'api_key': apiKey},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // Database maintenance
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('chat_messages');
    await db.update(
      'ai_settings',
      {'api_key': null},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<int> getDatabaseSize() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        (SELECT COUNT(*) FROM chat_messages) as message_count,
        (SELECT page_count * page_size FROM pragma_page_count(), pragma_page_size()) as db_size
    ''');
    
    return result.first['db_size'] as int? ?? 0;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
