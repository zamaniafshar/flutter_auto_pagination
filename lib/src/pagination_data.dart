class PaginationData<T> {
  PaginationData({
    required this.hasReachedEnd,
    required this.data,
  });

  final bool hasReachedEnd;
  final List<T> data;
}
