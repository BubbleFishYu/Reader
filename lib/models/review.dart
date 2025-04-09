class Review {
  final String id;
  final String bookId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.bookId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  // 从 JSON 创建 Review 对象
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // 将 Review 对象转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // 创建 Review 的副本，允许部分字段更新
  Review copyWith({
    String? id,
    String? bookId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 