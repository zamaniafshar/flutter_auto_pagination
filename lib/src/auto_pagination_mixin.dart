import 'package:flutter/foundation.dart';

import 'pagination_state.dart';
import 'pagination_data.dart';

abstract mixin class AutoPaginationMixin<T> {
  /// Override this method to define how to fetch a page of data.
  ///
  /// This method should return a [PaginationData<T>] containing the fetched data
  /// and a boolean indicating whether the end of the data set has been reached.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<PaginationData<MyItem>> fetchPageData(int page) async {
  ///   final response = await api.fetchItems(page: page);
  ///   return PaginationData(
  ///     data: response.items,
  ///     hasReachedEnd: response.isLastPage,
  ///   );
  /// }
  /// ```
  ///
  /// Parameters:
  /// - [page]: The page number to fetch (1-based)
  ///
  /// Returns:
  /// - A [PaginationData<T>] containing the fetched data and end-of-list indicator

  @protected
  Future<PaginationData<T>> fetchPageData(int page);

  /// Called when the pagination state changes.
  ///
  /// Override this method to react to pagination state updates in your widget.
  /// This is where you would typically update your state management solution
  /// (Bloc, Riverpod, Provider, etc.) with the new pagination state.
  ///
  /// Parameters:
  /// - [newState]: The new pagination state

  @protected
  void onPaginationStateChanged(PaginationState<T> newState);

  /// Get the current pagination state.
  ///
  /// This property should return the current pagination state managed by the mixin.
  /// It's used internally to track the loading state, data, and pagination progress.
  ///
  /// Returns:
  /// - The current [PaginationState<T>] instance

  @protected
  PaginationState<T> get paginationState;

  /// Internal method to update the pagination state.
  ///
  /// This method calls [onPaginationStateChanged] to notify the widget of the state change.
  ///

  void _setPaginationState(PaginationState<T> newState) {
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
