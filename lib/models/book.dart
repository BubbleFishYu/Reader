import 'package:flutter/material.dart';
import 'annotation.dart';
import 'review.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String publisher;
  final DateTime publishDate;
  final String filePath;
  final String fileType;
  final DateTime lastRead;
  final List<Annotation> annotations;
  final List<Review> reviews;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.publishDate,
    required this.filePath,
    required this.fileType,
    required this.lastRead,
    this.annotations = const [],
    this.reviews = const [],
  });

  // 从 JSON 创建 Book 对象
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      publisher: json['publisher'] as String,
      publishDate: DateTime.parse(json['publishDate'] as String),
      filePath: json['filePath'] as String,
      fileType: json['fileType'] as String,
      lastRead: DateTime.parse(json['lastRead'] as String),
      annotations: (json['annotations'] as List<dynamic>?)
          ?.map((e) => Annotation.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  // 将 Book 对象转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'publisher': publisher,
      'publishDate': publishDate.toIso8601String(),
      'filePath': filePath,
      'fileType': fileType,
      'lastRead': lastRead.toIso8601String(),
      'annotations': annotations.map((e) => e.toJson()).toList(),
      'reviews': reviews.map((e) => e.toJson()).toList(),
    };
  }

  // 创建 Book 的副本，允许部分字段更新
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? publisher,
    DateTime? publishDate,
    String? filePath,
    String? fileType,
    DateTime? lastRead,
    List<Annotation>? annotations,
    List<Review>? reviews,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      publisher: publisher ?? this.publisher,
      publishDate: publishDate ?? this.publishDate,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      lastRead: lastRead ?? this.lastRead,
      annotations: annotations ?? this.annotations,
      reviews: reviews ?? this.reviews,
    );
  }
} 