import 'dart:async';

import 'package:example/models/article.dart';
import 'package:example/repository/articles_repository.dart';
import 'package:flutter_auto_pagination/flutter_auto_pagination.dart';
import 'package:flutter/material.dart';

class ComplexNotifier extends ValueNotifier<ComplexState>
    with AutoPaginationMixin<Article> {
  ComplexNotifier(this._repository) : super(ComplexState.initial());

  final ArticlesRepository _repository;

  Timer? _searchDebounce;

  @override
  Future<PaginationData<Article>> fetchPageData(int page) {
    return _repository.fetchWithSearch(page, value.searchQuery);
  }

  @override
  PaginationState<Article> get paginationState => value.paginationState;

  @override
  void setPaginationState(PaginationState<Article> newState) {
    value = value.copyWith(paginationState: newState);
  }

  void search(String searchQuery) {
    value = value.copyWith(searchQuery: searchQuery);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(seconds: 1), () {
      load();
    });
  }

  void toggleLike(int id) {
    final data = value.paginationState.data;
    final article = data.firstWhere((item) => item.id == id);
    final updatedArticle = article.copyWith(isLiked: !article.isLiked);
    final updatedData = data.map((item) {
      if (item.id == id) {
        return updatedArticle;
      }
      return item;
    }).toList();

    value = value.copyWith(
      paginationState: value.paginationState.copyWith(data: updatedData),
    );
  }
}

class ComplexState {
  final PaginationState<Article> paginationState;
  final String searchQuery;

  /// with other data

  const ComplexState({
    required this.paginationState,
    required this.searchQuery,
  });

  ComplexState.initial()
    : this(paginationState: PaginationState.initial(), searchQuery: '');

  ComplexState copyWith({
    PaginationState<Article>? paginationState,
    String? searchQuery,
  }) {
    return ComplexState(
      paginationState: paginationState ?? this.paginationState,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
