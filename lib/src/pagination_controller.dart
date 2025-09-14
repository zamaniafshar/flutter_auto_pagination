import 'package:flutter/foundation.dart';

import 'pagination_state.dart';
import 'pagination_data.dart';

abstract mixin class PaginationController<T> {
  @protected
  Future<PaginationData<T>> fetchPageData(int page);

  @protected
  void setPaginationState(PaginationState<T> state);

  @protected
  PaginationState<T> get getPaginationState;

  Future<void> load() async {
    setPaginationState(PaginationState.initial());
    await _fetchInitialData();
  }

  /// will not reset data until new one is fetched
  Future<void> refresh() async {
    setPaginationState(getPaginationState.copyWith(currentPage: 1));
    await _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final result = await fetchPageData(getPaginationState.currentPage);
      setPaginationState(
        getPaginationState.copyWith(
          status: const PaginationLoadSuccess(),
          data: result.data,
          hasReachedEnd: result.hasReachedEnd,
        ),
      );
    } catch (e) {
      setPaginationState(
        getPaginationState.copyWith(status: PaginationLoadFailure(e)),
      );
    }
  }

  Future<void> loadMore() async {
    if (getPaginationState.status is! PaginationLoadSuccess &&
        getPaginationState.status is! PaginationLoadMoreFailure) {
      return;
    }
    if (getPaginationState.hasReachedEnd) return;

    final currentState = getPaginationState;

    setPaginationState(
      getPaginationState.copyWith(
        status: const PaginationLoadingMore(),
        currentPage: getPaginationState.currentPage + 1,
      ),
    );

    try {
      final result = await fetchPageData(getPaginationState.currentPage);
      setPaginationState(
        getPaginationState.copyWith(
          status: const PaginationLoadSuccess(),
          data: [...currentState.data, ...result.data],
          hasReachedEnd: result.hasReachedEnd,
        ),
      );
    } catch (e) {
      setPaginationState(
        getPaginationState.copyWith(status: PaginationLoadMoreFailure(e)),
      );
    }
  }
}
