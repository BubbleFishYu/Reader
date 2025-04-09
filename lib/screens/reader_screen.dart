import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/reader_provider.dart';
import '../models/book.dart';
import '../models/annotation.dart';
import '../widgets/annotation_dialog.dart';
import '../widgets/annotation_overlay.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;

  const ReaderScreen({
    super.key,
    required this.book,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;
  List<int> _searchResults = [];
  int _currentSearchIndex = -1;
  String? _selectedText;
  int? _selectionStart;
  int? _selectionEnd;
  Annotation? _selectedAnnotation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReaderProvider>().loadBook(widget.book);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _currentSearchIndex = -1;
      });
      return;
    }

    final positions = context.read<ReaderProvider>().searchContent(query);
    setState(() {
      _searchResults = positions;
      _currentSearchIndex = positions.isNotEmpty ? 0 : -1;
    });
  }

  void _showAnnotationDialog({Annotation? annotation}) async {
    if (annotation == null && (_selectedText == null || _selectionStart == null || _selectionEnd == null)) {
      return;
    }

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AnnotationDialog(
        initialText: annotation?.content ?? '',
        initialColor: annotation?.color ?? '#FF0000',
      ),
    );

    if (result != null && mounted) {
      if (annotation != null) {
        // 更新现有标注
        final updatedAnnotation = annotation.copyWith(
          content: result['content']!,
          color: result['color']!,
        );
        context.read<ReaderProvider>().updateAnnotation(updatedAnnotation);
      } else {
        // 创建新标注
        final newAnnotation = Annotation(
          id: const Uuid().v4(),
          bookId: widget.book.id,
          content: result['content']!,
          text: _selectedText!,
          pageNumber: context.read<ReaderProvider>().currentPage,
          position: Offset(0, 0), // 暂时使用默认位置，后续可以根据实际需求计算
          color: result['color']!,
          createdAt: DateTime.now(),
        );
        context.read<ReaderProvider>().addAnnotation(newAnnotation);
      }
    }
  }

  void _handleAnnotationTap(Annotation annotation) {
    setState(() {
      _selectedAnnotation = annotation;
    });
    _showAnnotationDialog(annotation: annotation);
  }

  void _handleAnnotationLongPress(Annotation annotation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除标注'),
        content: const Text('确定要删除这个标注吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<ReaderProvider>().removeAnnotation(annotation.id);
              Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
                if (!_showSearchBar) {
                  _searchController.clear();
                  _searchResults = [];
                  _currentSearchIndex = -1;
                }
              });
            },
          ),
        ],
      ),
      body: Consumer<ReaderProvider>(
        builder: (context, readerProvider, child) {
          if (readerProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              if (_showSearchBar)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: '搜索内容',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _performSearch(),
                        ),
                      ),
                      if (_searchResults.isNotEmpty) ...[
                        IconButton(
                          icon: const Icon(Icons.arrow_upward),
                          onPressed: _currentSearchIndex > 0
                              ? () {
                                  setState(() {
                                    _currentSearchIndex--;
                                  });
                                }
                              : null,
                        ),
                        Text(
                          '${_currentSearchIndex + 1}/${_searchResults.length}',
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_downward),
                          onPressed: _currentSearchIndex < _searchResults.length - 1
                              ? () {
                                  setState(() {
                                    _currentSearchIndex++;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ],
                  ),
                ),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText(
                        readerProvider.content,
                        style: Theme.of(context).textTheme.bodyLarge,
                        onSelectionChanged: (selection, cause) {
                          if (cause == SelectionChangedCause.longPress ||
                              cause == SelectionChangedCause.drag) {
                            final text = readerProvider.content.substring(
                              selection.start,
                              selection.end,
                            );
                            setState(() {
                              _selectedText = text;
                              _selectionStart = selection.start;
                              _selectionEnd = selection.end;
                            });
                          }
                        },
                      ),
                    ),
                    AnnotationOverlay(
                      annotations: readerProvider.annotations,
                      onAnnotationTap: _handleAnnotationTap,
                      onAnnotationLongPress: _handleAnnotationLongPress,
                    ),
                    if (_selectedText != null)
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: FloatingActionButton(
                          onPressed: () => _showAnnotationDialog(),
                          child: const Icon(Icons.edit),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 