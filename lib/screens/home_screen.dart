import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../widgets/book_card.dart';
import 'reader_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的书架'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 32),
            onPressed: () async {
              final success = await context.read<BookProvider>().importFile();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('导入成功')),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('导入失败')),
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          if (bookProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookProvider.books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.library_books,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '书架空空如也',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final success = await bookProvider.importFile();
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('导入成功')),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('导入失败')),
                        );
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 24),
                    label: const Text('导入书籍'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: bookProvider.books.length,
            itemBuilder: (context, index) {
              final book = bookProvider.books[index];
              return BookCard(
                book: book,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReaderScreen(book: book),
                    ),
                  );
                },
                onDelete: () async {
                  final success = await bookProvider.deleteBook(book.id);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('删除成功')),
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('删除失败')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
} 