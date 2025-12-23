import 'package:example/models/article.dart';
import 'package:example/repository/articles_repository.dart';
import 'package:flutter_auto_pagination/flutter_auto_pagination.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'articles_notifier.g.dart';

@riverpod
ArticlesRepository articlesRepository(Ref ref) {
  return ArticlesRepository();
}

@riverpod
class ArticlesNotifier extends _$ArticlesNotifier
    with AutoPaginationMixin<Article> {
  @override
  PaginationState<Article> build() {
    load();
    return PaginationState.initial();
  }

  @override
  Future<PaginationData<Article>> fetchPageData(int page) {
    return ref.read(articlesRepositoryProvider).fetch(page);
  }

  @override
  PaginationState<Article> get paginationState => state;

  @override
  void onPaginationStateChanged(PaginationState<Article> newState) {
    state = newState;
  }
}
