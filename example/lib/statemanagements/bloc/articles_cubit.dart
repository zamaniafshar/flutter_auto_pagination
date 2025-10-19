import 'package:example/models/article.dart';
import 'package:example/repository/articles_repository.dart';
import 'package:flutter_auto_pagination/flutter_auto_pagination.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArticlesCubit extends Cubit<PaginationState<Article>>
    with AutoPaginationMixin<Article> {
  ArticlesCubit(this._repository) : super(PaginationState.initial());

  final ArticlesRepository _repository;

  @override
  Future<PaginationData<Article>> fetchPageData(int page) {
    return _repository.fetch(page);
  }

  @override
  PaginationState<Article> get paginationState => state;

  @override
  void setPaginationState(PaginationState<Article> newState) {
    emit(newState);
  }
}
