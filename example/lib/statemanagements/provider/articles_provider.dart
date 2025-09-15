import 'package:flutter/foundation.dart';
import 'package:flutter_auto_pagination/flutter_auto_pagination.dart';

import '../../models/article.dart';
import '../../repository/articles_repository.dart';

class ArticlesProvider extends ChangeNotifier with PaginationController<Article> {
  final ArticlesRepository _repo;

  ArticlesProvider(this._repo) : _state = PaginationState<Article>.initial();

  PaginationState<Article> _state;

  @override
  PaginationState<Article> get paginationState => _state;

  @override
  void setPaginationState(PaginationState<Article> newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  Future<PaginationData<Article>> fetchPageData(int page) {
    return _repo.fetch(page);
  }
}
