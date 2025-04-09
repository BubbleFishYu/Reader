import 'package:flutter/material.dart';

class Annotation {
  final String id;
  final String bookId;
  final String text;
  final String content;
  final int pageNumber;
  final Offset position;
  final String color;
  final DateTime createdAt;

  Annotation({
    required this.id,
    required this.bookId,
    required this.text,
    required this.content,
    required this.pageNumber,
    required this.position,
    required this.color,
    required this.createdAt,
  });

  // 创建 Annotation 的副本，可选更新某些字段
  Annotation copyWith({
    String? id,
    String? bookId,
    String? text,
    String? content,
    int? pageNumber,
    Offset? position,
    String? color,
    DateTime? createdAt,
  }) {
    return Annotation(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      text: text ?? this.text,
      content: content ?? this.content,
      pageNumber: pageNumber ?? this.pageNumber,
      position: position ?? this.position,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 从 JSON 创建 Annotation 对象
  factory Annotation.fromJson(Map<String, dynamic> json) {
    return Annotation(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      text: json['text'] as String,
      content: json['content'] as String,
      pageNumber: json['pageNumber'] as int,
      position: Offset(
        json['position']['dx'] as double,
        json['position']['dy'] as double,
      ),
      color: json['color'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // 将 Annotation 对象转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'text': text,
      'content': content,
      'pageNumber': pageNumber,
      'position': {
        'dx': position.dx,
        'dy': position.dy,
      },
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }
} 