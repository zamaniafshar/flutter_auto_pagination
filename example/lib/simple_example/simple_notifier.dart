import 'package:example/models/article.dart';
import 'package:example/repository/articles_repository.dart';
import 'package:flutter_auto_pagination/flutter_auto_pagination.dart';
import 'package:flutter/material.dart';

class SimpleNotifier extends ChangeNotifier with AutoPaginationMixin<Article> {
  SimpleNotifier(this._repository);

  final ArticlesRepository _repository;

  PaginationState<Article> _state = PaginationState.initial();

  @override
  Future<PaginationData<Article>> fetchPageData(int page) {
    return _repository.fetch(page);
  }

  @override
  PaginationState<Article> get paginationState => _state;

  @override
  void onPaginationStateChanged(PaginationState<Article> newState) {
    _state = newState;
    notifyListeners();
  }
}
