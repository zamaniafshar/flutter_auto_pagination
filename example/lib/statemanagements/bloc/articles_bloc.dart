import 'package:example/models/article.dart';
import 'package:example/repository/articles_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_auto_pagination/flutter_auto_pagination.dart';

part 'articles_event.dart';

class ArticlesBloc extends Bloc<ArticlesEvent, PaginationState<Article>>
    with AutoPaginationMixin<Article> {
  ArticlesBloc(this._repository) : super(PaginationState.initial()) {
    on<ArticlesLoadRequested>(_onArticlesLoadRequested);
    on<ArticlesRefreshed>(_onArticlesRefreshed);
    on<ArticlesLoadMoreRequested>(_onArticlesLoadMoreRequested);
    on<_ArticlesPaginationStateChangedEvent>(
      _onArticlesPaginationStateChangedEvent,
    );
  }

  final ArticlesRepository _repository;

  @override
  Future<PaginationData<Article>> fetchPageData(int page) {
    return _repository.fetch(page);
  }

  @override
  PaginationState<Article> get paginationState => state;

  @override
  void setPaginationState(PaginationState<Article> newState) {
    add(_ArticlesPaginationStateChangedEvent(newState));
  }

  void _onArticlesLoadRequested(ArticlesLoadRequested event, Emitter emit) {
    load();
  }

  void _onArticlesRefreshed(ArticlesRefreshed event, Emitter emit) {
    refresh();
  }

  void _onArticlesLoadMoreRequested(
    ArticlesLoadMoreRequested event,
    Emitter emit,
  ) {
    loadMore();
  }

  void _onArticlesPaginationStateChangedEvent(
    _ArticlesPaginationStateChangedEvent event,
    Emitter emit,
  ) {
    emit(event.state);
  }
}
