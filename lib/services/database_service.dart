import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';
import '../models/annotation.dart';
import '../models/review.dart';

class DatabaseService {
  static Database? _database;
  static const String dbName = 'reader_app.db';
  static const int dbVersion = 1;

  // 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 初始化数据库
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), dbName);
    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _createTables,
    );
  }

  // 创建数据库表
  Future<void> _createTables(Database db, int version) async {
    // 创建书籍表
    await db.execute('''
      CREATE TABLE books(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        publisher TEXT NOT NULL,
        publishDate TEXT NOT NULL,
        filePath TEXT NOT NULL,
        fileType TEXT NOT NULL,
        lastRead TEXT NOT NULL
      )
    ''');

    // 创建标注表
    await db.execute('''
      CREATE TABLE annotations(
        id TEXT PRIMARY KEY,
        bookId TEXT NOT NULL,
        text TEXT NOT NULL,
        pageNumber INTEGER NOT NULL,
        positionX REAL NOT NULL,
        positionY REAL NOT NULL,
        color TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (bookId) REFERENCES books (id)
      )
    ''');

    // 创建读后感表
    await db.execute('''
      CREATE TABLE reviews(
        id TEXT PRIMARY KEY,
        bookId TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (bookId) REFERENCES books (id)
      )
    ''');
  }

  // 插入书籍
  Future<void> insertBook(Book book) async {
    final db = await database;
    await db.insert(
      'books',
      book.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 获取所有书籍
  Future<List<Book>> getAllBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('books');
    return List.generate(maps.length, (i) => Book.fromJson(maps[i]));
  }

  // 获取单本书籍
  Future<Book?> getBook(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Book.fromJson(maps.first);
  }

  // 更新书籍
  Future<void> updateBook(Book book) async {
    final db = await database;
    await db.update(
      'books',
      book.toJson(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  // 删除书籍
  Future<void> deleteBook(String id) async {
    final db = await database;
    await db.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 插入标注
  Future<void> insertAnnotation(Annotation annotation) async {
    final db = await database;
    await db.insert(
      'annotations',
      annotation.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 获取书籍的所有标注
  Future<List<Annotation>> getBookAnnotations(String bookId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'annotations',
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
    return List.generate(maps.length, (i) => Annotation.fromJson(maps[i]));
  }

  // 插入读后感
  Future<void> insertReview(Review review) async {
    final db = await database;
    await db.insert(
      'reviews',
      review.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 获取书籍的所有读后感
  Future<List<Review>> getBookReviews(String bookId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reviews',
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
    return List.generate(maps.length, (i) => Review.fromJson(maps[i]));
  }

  // 关闭数据库
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
} 