class Article {
  final int id;
  final String title;
  final bool isLiked;

  const Article({
    required this.id,
    required this.title,
    this.isLiked = false,
  });

  Article copyWith({
    int? id,
    String? title,
    bool? isLiked,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
