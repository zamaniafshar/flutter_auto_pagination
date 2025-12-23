import 'dart:async';

import 'package:flutter_auto_pagination/flutter_auto_pagination.dart';

import '../models/article.dart';

class ArticlesRepository {
  final int pageSize = 20;
  final int totalPages = 20;

  Future<PaginationData<Article>> fetch(int page) async {
    // simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (page > totalPages) {
      return PaginationData<Article>(hasReachedEnd: true, data: const []);
    }

    final startId = (page - 1) * pageSize;
    final data = List.generate(
      pageSize,
      (i) => Article(id: startId + i + 1, title: 'Article ${startId + i + 1}'),
    );

    final hasReachedEnd = page >= totalPages;

    return PaginationData<Article>(hasReachedEnd: hasReachedEnd, data: data);
  }

  Future<PaginationData<Article>> fetchWithSearch(
    int page,
    String query,
  ) async {
    final data = await fetch(page);

    if (query.isEmpty) {
      return data;
    }

    final queryLower = query.toLowerCase();

    final filteredData = data.data
        .where(
          (item) => item.title.toLowerCase().contains(
            queryLower,
          ),
        )
        .toList();
    final hasReachedEnd = filteredData.length < pageSize;

    return PaginationData<Article>(
      hasReachedEnd: hasReachedEnd,
      data: filteredData,
    );
  }
}
