/// Immutable snapshot of pagination state for a list of items.
///
/// This is the only state type that `AutoPaginationMixin` and
/// `AutoPagination` care about. You typically hold an instance of this in
/// your own state-management layer and update it in
/// `onPaginationStateChanged`.
class PaginationState<T> {
  final bool hasReachedEnd;
  final List<T> data;
  final PaginationStatus status;
  final int currentPage;

  const PaginationState({
    required this.hasReachedEnd,
    required this.data,
    required this.status,
    required this.currentPage,
  });

  factory PaginationState.initial() {
    return PaginationState<T>(
      hasReachedEnd: false,
      currentPage: 1,
      data: const [],
      status: PaginationLoading(),
    );
  }

  PaginationState<T> copyWith({
    bool? hasReachedEnd,
    List<T>? data,
    PaginationStatus? status,
    int? currentPage,
  }) {
    return PaginationState<T>(
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      data: data ?? this.data,
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginationState<T> &&
          runtimeType == other.runtimeType &&
          hasReachedEnd == other.hasReachedEnd &&
          currentPage == other.currentPage &&
          status == other.status &&
          data == other.data;

  @override
  int get hashCode =>
      hasReachedEnd.hashCode ^
      data.hashCode ^
      status.hashCode ^
      currentPage.hashCode;
}

/// Base type for all pagination status values.
///
/// Use `is` checks (e.g. `state.status is PaginationLoading`) to branch in
/// your UI or business logic.
sealed class PaginationStatus {
  const PaginationStatus();
}

/// Indicates that the first page of data is being loaded.
class PaginationLoading extends PaginationStatus {
  const PaginationLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PaginationLoading;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Indicates that an additional page is being loaded.
class PaginationLoadingMore extends PaginationStatus {
  const PaginationLoadingMore();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PaginationLoadingMore;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Indicates that data has been successfully loaded.
class PaginationLoadSuccess extends PaginationStatus {
  const PaginationLoadSuccess();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PaginationLoadSuccess;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Indicates that loading the first page failed.
///
/// The [error] field contains the original error object so you can surface
/// it in the UI or log it.
class PaginationLoadFailure extends PaginationStatus {
  final Object? error;
  const PaginationLoadFailure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginationLoadFailure && error == other.error;

  @override
  int get hashCode => error.hashCode;
}

/// Indicates that loading an additional page failed.
///
/// The [error] field contains the original error object so you can surface
/// it in the UI or log it. Existing items remain available.
class PaginationLoadMoreFailure extends PaginationStatus {
  final Object? error;
  const PaginationLoadMoreFailure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginationLoadMoreFailure && error == other.error;

  @override
  int get hashCode => error.hashCode;
}
