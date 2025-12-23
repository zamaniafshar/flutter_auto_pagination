import 'package:flutter/foundation.dart';

import 'pagination_state.dart';
import 'pagination_data.dart';

abstract mixin class AutoPaginationMixin<T> {
  @protected
  Future<PaginationData<T>> fetchPageData(int page);

  @protected
  void onPaginationStateChanged(PaginationState<T> newState);



  @protected
  PaginationState<T> get paginationState;

  void _setPaginationState(PaginationState<T> newState){
    onPaginationStateChanged(newState);
  }


  Future<void> load() async {
    _setPaginationState(PaginationState.initial());
    await _fetchInitialData();
  }

  /// will not reset data until new one is fetched
  Future<void> refresh() async {
    _setPaginationState(paginationState.copyWith(currentPage: 1));
    await _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final result = await fetchPageData(paginationState.currentPage);
      _setPaginationState(
        paginationState.copyWith(
          status: const PaginationLoadSuccess(),
          data: result.data,
          hasReachedEnd: result.hasReachedEnd,
        ),
      );
    } catch (e) {
      _setPaginationState(
        paginationState.copyWith(status: PaginationLoadFailure(e)),
      );
    }
  }

  Future<void> loadMore() async {
    if (paginationState.status is! PaginationLoadSuccess &&
        paginationState.status is! PaginationLoadMoreFailure) {
      return;
    }
    if (paginationState.hasReachedEnd) return;

    final currentState = paginationState;

    _setPaginationState(
      paginationState.copyWith(
        status: const PaginationLoadingMore(),
        currentPage: paginationState.currentPage + 1,
      ),
    );

    try {
      final result = await fetchPageData(paginationState.currentPage);
      _setPaginationState(
        paginationState.copyWith(
          status: const PaginationLoadSuccess(),
          data: [...currentState.data, ...result.data],
          hasReachedEnd: result.hasReachedEnd,
        ),
      );
    } catch (e) {
      _setPaginationState(
        paginationState.copyWith(status: PaginationLoadMoreFailure(e)),
      );
    }
  }
}
