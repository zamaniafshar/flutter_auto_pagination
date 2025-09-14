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

sealed class PaginationStatus {
  const PaginationStatus();
}

class PaginationLoading extends PaginationStatus {
  const PaginationLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PaginationLoading;

  @override
  int get hashCode => runtimeType.hashCode;
}

class PaginationLoadingMore extends PaginationStatus {
  const PaginationLoadingMore();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PaginationLoadingMore;

  @override
  int get hashCode => runtimeType.hashCode;
}

class PaginationLoadSuccess extends PaginationStatus {
  const PaginationLoadSuccess();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PaginationLoadSuccess;

  @override
  int get hashCode => runtimeType.hashCode;
}

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
