import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/book.dart';
import 'parser_service.dart';

class FileService {
  final ParserService _parserService = ParserService();
  
  // 支持的文件类型
  static const List<String> supportedFileTypes = [
    'pdf',
    'epub',
    'txt',
    'mobi',
    'azw3',
    'doc',
    'docx',
  ];

  // 选择文件
  Future<File?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: supportedFileTypes,
      );

      if (result != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  // 获取文件类型
  String getFileType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.pdf':
        return 'PDF';
      case '.epub':
        return 'EPUB';
      case '.txt':
        return 'TXT';
      case '.mobi':
      case '.azw3':
        return 'MOBI';
      case '.doc':
      case '.docx':
        return 'DOC';
      default:
        return 'UNKNOWN';
    }
  }

  // 检查文件类型是否支持
  bool isFileTypeSupported(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return [
      '.pdf',
      '.epub',
      '.txt',
      '.mobi',
      '.azw3',
      '.doc',
      '.docx',
    ].contains(extension);
  }

  // 获取应用文档目录
  Future<String> getAppDocumentsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // 复制文件到应用目录
  Future<String> copyFileToAppDirectory(File sourceFile) async {
    try {
      final appDir = await getAppDocumentsPath();
      final fileName = path.basename(sourceFile.path);
      final targetPath = path.join(appDir, 'books', fileName);
      
      // 确保目标目录存在
      await Directory(path.dirname(targetPath)).create(recursive: true);
      
      // 复制文件
      await sourceFile.copy(targetPath);
      return targetPath;
    } catch (e) {
      print('Error copying file: $e');
      rethrow;
    }
  }

  // 从文件创建 Book 对象
  Future<Book?> createBookFromFile(File file) async {
    try {
      final fileType = getFileType(file.path);
      if (!isFileTypeSupported(file.path)) {
        throw Exception('Unsupported file type: $fileType');
      }

      // 解析文件内容
      final parsedData = await _parserService.parseFile(file);
      final metadata = parsedData['metadata'] as Map<String, dynamic>;

      // 复制文件到应用目录
      final savedPath = await copyFileToAppDirectory(file);
      
      // 创建 Book 对象
      return Book(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: metadata['title'] ?? path.basenameWithoutExtension(file.path),
        author: metadata['author'] ?? 'Unknown',
        publisher: metadata['publisher'] ?? 'Unknown',
        publishDate: metadata['publishDate'] ?? DateTime.now(),
        filePath: savedPath,
        fileType: fileType,
        lastRead: DateTime.now(),
      );
    } catch (e) {
      print('Error creating book from file: $e');
      return null;
    }
  }

  // 获取文件预览
  Future<String> getFilePreview(File file, {int maxLength = 500}) async {
    return await _parserService.getPreview(file, maxLength: maxLength);
  }

  // 删除文件
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }
} 