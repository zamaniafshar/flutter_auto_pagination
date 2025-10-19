part of 'articles_bloc.dart';

sealed class ArticlesEvent {}

final class ArticlesLoadRequested extends ArticlesEvent {}

final class ArticlesRefreshed extends ArticlesEvent {}

final class ArticlesLoadMoreRequested extends ArticlesEvent {}

final class _ArticlesPaginationStateChangedEvent extends ArticlesEvent {
  final PaginationState<Article> state;

  _ArticlesPaginationStateChangedEvent(this.state);
}
