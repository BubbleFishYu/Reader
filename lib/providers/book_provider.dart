import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../services/file_service.dart';

class BookProvider with ChangeNotifier {
  final FileService _fileService = FileService();
  List<Book> _books = [];
  bool _isLoading = false;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;

  // 导入新文件
  Future<bool> importFile() async {
    try {
      _isLoading = true;
      notifyListeners();

      final file = await _fileService.pickFile();
      if (file == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final book = await _fileService.createBookFromFile(file);
      if (book != null) {
        _books.add(book);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Error importing file: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 删除书籍
  Future<bool> deleteBook(String bookId) async {
    try {
      final book = _books.firstWhere((b) => b.id == bookId);
      final success = await _fileService.deleteFile(book.filePath);
      
      if (success) {
        _books.removeWhere((b) => b.id == bookId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting book: $e');
      return false;
    }
  }

  // 按作者分类
  Map<String, List<Book>> getBooksByAuthor() {
    final Map<String, List<Book>> booksByAuthor = {};
    for (final book in _books) {
      final author = book.author;
      if (!booksByAuthor.containsKey(author)) {
        booksByAuthor[author] = [];
      }
      booksByAuthor[author]!.add(book);
    }
    return booksByAuthor;
  }

  // 按出版社分类
  Map<String, List<Book>> getBooksByPublisher() {
    final Map<String, List<Book>> booksByPublisher = {};
    for (final book in _books) {
      final publisher = book.publisher;
      if (!booksByPublisher.containsKey(publisher)) {
        booksByPublisher[publisher] = [];
      }
      booksByPublisher[publisher]!.add(book);
    }
    return booksByPublisher;
  }

  // 按出版年份分类
  Map<int, List<Book>> getBooksByYear() {
    final Map<int, List<Book>> booksByYear = {};
    for (final book in _books) {
      final year = book.publishDate.year;
      if (!booksByYear.containsKey(year)) {
        booksByYear[year] = [];
      }
      booksByYear[year]!.add(book);
    }
    return booksByYear;
  }
} 