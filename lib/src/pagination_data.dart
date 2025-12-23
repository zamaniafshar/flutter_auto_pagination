/// Container for a single page of items returned from
/// [AutoPaginationMixin.fetchPageData].
///
/// The [data] list holds only the items for the requested page.
/// [hasReachedEnd] indicates whether there are more pages to load.
class PaginationData<T> {
  PaginationData({
    required this.hasReachedEnd,
    required this.data,
  });

  final bool hasReachedEnd;
  final List<T> data;
}
