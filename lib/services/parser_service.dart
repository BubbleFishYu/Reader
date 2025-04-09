import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ParserService {
  // 解析文件内容
  Future<Map<String, dynamic>> parseFile(File file) async {
    try {
      // 检查文件是否存在
      if (!await file.exists()) {
        throw Exception('File does not exist: ${file.path}');
      }

      // 检查文件是否可读
      if (!await file.exists()) {
        throw Exception('File is not readable: ${file.path}');
      }

      final fileType = path.extension(file.path).toLowerCase().replaceAll('.', '');
      print('Parsing file of type: $fileType');
      
      Map<String, dynamic> result;
      switch (fileType) {
        case 'pdf':
          result = await _parsePdfFile(file);
          break;
        case 'epub':
          result = await _parseEpubFile(file);
          break;
        case 'txt':
          result = await _parseTextFile(file);
          break;
        case 'mobi':
        case 'azw3':
          result = await _parseMobiFile(file);
          break;
        case 'doc':
        case 'docx':
          result = await _parseDocFile(file);
          break;
        default:
          throw Exception('Unsupported file type: $fileType');
      }

      // 确保返回的数据包含必要的内容
      if (result['content'] == null || result['content'].toString().isEmpty) {
        throw Exception('Failed to extract content from file');
      }

      return result;
    } catch (e, stackTrace) {
      print('Error in parseFile: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // 解析 PDF 文件
  Future<Map<String, dynamic>> _parsePdfFile(File file) async {
    try {
      // 使用 Syncfusion PDF 解析 PDF
      final PdfDocument document = PdfDocument(inputBytes: await file.readAsBytes());
      
      // 提取元数据
      final metadata = {
        'title': document.documentInformation.title ?? path.basenameWithoutExtension(file.path),
        'author': document.documentInformation.author ?? 'Unknown',
        'subject': document.documentInformation.subject ?? '',
        'keywords': document.documentInformation.keywords ?? '',
        'creationDate': document.documentInformation.creationDate ?? DateTime.now(),
      };

      // 提取文本内容
      String content = '';
      try {
        final extractor = PdfTextExtractor(document);
        for (int i = 0; i < document.pages.count; i++) {
          try {
            final pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
            if (pageText != null && pageText.isNotEmpty) {
              content += pageText + '\n';
            }
          } catch (e) {
            print('Error extracting text from page $i: $e');
            // 继续处理下一页
            continue;
          }
        }
      } catch (e) {
        print('Error using PdfTextExtractor: $e');
        // 如果文本提取失败，尝试使用备用方法
        content = 'PDF content extraction failed. Please use the PDF viewer to read this file.';
      }

      // 如果内容为空，设置默认内容
      if (content.isEmpty) {
        content = 'PDF content extraction failed. Please use the PDF viewer to read this file.';
      }

      return {
        'metadata': metadata,
        'content': content,
        'pageCount': document.pages.count,
      };
    } catch (e) {
      print('Error parsing PDF file: $e');
      // 返回一个基本的响应，而不是抛出异常
      return {
        'metadata': {
          'title': path.basenameWithoutExtension(file.path),
          'author': 'Unknown',
          'publishDate': DateTime.now(),
        },
        'content': 'PDF content extraction failed. Please use the PDF viewer to read this file.',
        'pageCount': 0,
      };
    }
  }

  // 解析 EPUB 文件
  Future<Map<String, dynamic>> _parseEpubFile(File file) async {
    try {
      // 尝试读取文件内容
      final content = await file.readAsString();
      
      return {
        'metadata': {
          'title': path.basenameWithoutExtension(file.path),
          'author': 'Unknown',
          'publishDate': DateTime.now(),
        },
        'content': content,
        'chapters': [],
      };
    } catch (e) {
      print('Error parsing EPUB file: $e');
      rethrow;
    }
  }

  // 解析文本文件
  Future<Map<String, dynamic>> _parseTextFile(File file) async {
    try {
      final content = await file.readAsString();
      
      return {
        'metadata': {
          'title': path.basenameWithoutExtension(file.path),
          'author': 'Unknown',
          'publishDate': DateTime.now(),
        },
        'content': content,
      };
    } catch (e) {
      print('Error parsing text file: $e');
      rethrow;
    }
  }

  // 解析 MOBI 文件
  Future<Map<String, dynamic>> _parseMobiFile(File file) async {
    // TODO: 实现 MOBI 文件解析
    throw UnimplementedError('MOBI file parsing not implemented yet');
  }

  // 解析 DOC/DOCX 文件
  Future<Map<String, dynamic>> _parseDocFile(File file) async {
    // TODO: 实现 DOC/DOCX 文件解析
    throw UnimplementedError('DOC/DOCX file parsing not implemented yet');
  }

  // 获取文件预览
  Future<String> getPreview(File file, {int maxLength = 500}) async {
    try {
      final parsedData = await parseFile(file);
      final content = parsedData['content'] as String;
      
      if (content.length <= maxLength) {
        return content;
      }
      
      return content.substring(0, maxLength) + '...';
    } catch (e) {
      print('Error getting file preview: $e');
      return 'Error reading file preview';
    }
  }
} 