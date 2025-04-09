import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/annotation.dart';
import '../services/file_service.dart';
import '../services/parser_service.dart';

class ReaderProvider with ChangeNotifier {
  final ParserService _parserService = ParserService();
  Book? _currentBook;
  String _content = '';
  int _currentPage = 0;
  List<Annotation> _annotations = [];
  bool _isLoading = false;

  Book? get currentBook => _currentBook;
  String get content => _content;
  int get currentPage => _currentPage;
  List<Annotation> get annotations => _annotations;
  bool get isLoading => _isLoading;

  // 加载书籍内容
  Future<void> loadBook(Book book) async {
    try {
      _isLoading = true;
      notifyListeners();

      _currentBook = book;
      
      // 检查文件是否存在
      final file = File(book.filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: ${book.filePath}');
      }

      print('Loading book from path: ${book.filePath}');
      final parsedData = await _parserService.parseFile(file);
      
      if (parsedData['content'] == null) {
        throw Exception('Failed to parse book content');
      }

      _content = parsedData['content'] as String;
      _currentPage = 0;
      _annotations = book.annotations;

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      print('Error loading book: $e');
      print('Stack trace: $stackTrace');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // 添加标注
  void addAnnotation(Annotation annotation) {
    _annotations.add(annotation);
    notifyListeners();
  }

  // 更新标注
  void updateAnnotation(Annotation annotation) {
    final index = _annotations.indexWhere((a) => a.id == annotation.id);
    if (index != -1) {
      _annotations[index] = annotation;
      notifyListeners();
    }
  }

  // 删除标注
  void removeAnnotation(String annotationId) {
    _annotations.removeWhere((a) => a.id == annotationId);
    notifyListeners();
  }

  // 更新当前页码
  void updateCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  // 搜索内容
  List<int> searchContent(String query) {
    if (query.isEmpty) return [];
    
    final List<int> positions = [];
    int index = 0;
    while (index != -1) {
      index = _content.indexOf(query, index);
      if (index != -1) {
        positions.add(index);
        index += query.length;
      }
    }
    return positions;
  }
} 