import 'package:flutter/material.dart';

import 'pagination_state.dart';

typedef WidgetBuilder = Widget Function(BuildContext context);
typedef LoadMoreButtonBuilder =
    Widget Function(BuildContext context, bool isLoading);
typedef ItemBuilder<T> =
    Widget Function(BuildContext context, int index, T item);
typedef ErrorBuilder = Widget Function(BuildContext context, Object? e);

sealed class PaginationViewType {
  const PaginationViewType();
}

final class PaginationListView extends PaginationViewType {
  const PaginationListView();
}

final class PaginationGridView extends PaginationViewType {
  const PaginationGridView({
    required this.gridDelegate,
  });

  final SliverGridDelegate gridDelegate;
}

sealed class PaginationLoadType {}

final class PaginationManualLoading extends PaginationLoadType {
  final LoadMoreButtonBuilder? loadButtonBuilder;

  PaginationManualLoading({
    this.loadButtonBuilder,
  });
}

final class PaginationAutoLoadMore extends PaginationLoadType {
  final double paginationScrollThreshold;
  final void Function() loadMore;
  final WidgetBuilder loadingMoreBuilder;

  PaginationAutoLoadMore({
    this.paginationScrollThreshold = 250,
    required this.loadMore,
    required this.loadingMoreBuilder,
  });
}

final class PaginationInfiniteLoading extends PaginationLoadType {
  final double paginationScrollThreshold;
  final void Function() loadMore;
  final WidgetBuilder loadingItemBuilder;

  PaginationInfiniteLoading({
    this.paginationScrollThreshold = 250,
    required this.loadMore,
    required this.loadingItemBuilder,
  });
}

class AutoPagination<T> extends StatefulWidget {
  AutoPagination({
    super.key,
    required this.state,
    required this.builder,
    required this.loadType,
    this.viewType = const PaginationListView(),
    this.sliver = false,
    this.padding,
    this.initialLoadingBuilder,
    this.errorBuilder,
    this.emptyListBuilder,
    this.scrollController,
    this.cacheExtent,
  }) {
    assert(
      sliver &&
          (loadType is PaginationAutoLoadMore ||
              loadType is PaginationInfiniteLoading) &&
          scrollController != null,
      'scrollController must not be null when sliver is true and loadType is PaginationAutoLoadMore or PaginationInfiniteLoading',
    );

    assert(
      sliver && cacheExtent == null,
      'cacheExtent can not be used when sliver is true',
    );
  }

  final ItemBuilder builder;
  final PaginationState<T> state;
  final PaginationViewType viewType;
  final PaginationLoadType loadType;
  final WidgetBuilder? initialLoadingBuilder;
  final ErrorBuilder? errorBuilder;
  final WidgetBuilder? emptyListBuilder;
  final EdgeInsets? padding;
  final bool sliver;
  final ScrollController? scrollController;
  final double? cacheExtent;

  @override
  State<AutoPagination<T>> createState() => _AutoPaginationState<T>();
}

class _AutoPaginationState<T> extends State<AutoPagination<T>> {
  late final scrollController = widget.scrollController ?? ScrollController();

  @override
  void initState() {
    attackScrollListener();
    super.initState();
  }

  @override
  void dispose() {
    final isLocalController = widget.scrollController == null;

    scrollController.removeListener(scrollListener);
    if (isLocalController) {
      scrollController.dispose();
    }

    super.dispose();
  }

  void attackScrollListener() {
    if (widget.loadType is PaginationManualLoading) return;

    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (widget.loadType is PaginationManualLoading) return;

    final threshold = switch (widget.loadType) {
      PaginationAutoLoadMore(:final paginationScrollThreshold) =>
        paginationScrollThreshold,
      PaginationInfiniteLoading(:final paginationScrollThreshold) =>
        paginationScrollThreshold,
      _ => throw Exception('Invalid load type'),
    };

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    final isAtTheEnd = maxScroll - currentScroll <= threshold;

    if (!isAtTheEnd) return;

    final loadMore = switch (widget.loadType) {
      PaginationAutoLoadMore(:final loadMore) => loadMore,
      PaginationInfiniteLoading(:final loadMore) => loadMore,
      _ => throw Exception('Invalid load type'),
    };

    loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.state.status;

    if (status is PaginationLoading) return loadingBuilder(context);
    if (status is PaginationLoadFailure) {
      return errorBuilder(context);
    }

    final isEmpty = widget.state.data.isEmpty;
    if (isEmpty) return emptyListBuilder(context);

    final sliver = buildItemsSliver(context);

    if (widget.sliver) return sliver;

    return CustomScrollView(
      controller: scrollController,
      cacheExtent: widget.cacheExtent,
      slivers: [
        sliver,
      ],
    );
  }

  Widget buildItemsSliver(BuildContext context) {
    return switch (widget.viewType) {
      PaginationListView() => buildItemsSliverList(context),
      PaginationGridView() => buildItemsSliverGrid(context),
    };
  }

  Widget buildItemsSliverList(BuildContext context) {
    final itemsCount = widget.state.data.length;
    final loadType = widget.loadType;
    int? count;
    if (loadType is PaginationInfiniteLoading) {
      count = null;
    } else {
      count = itemsCount + 1;
    }

    return SliverPadding(
      padding: widget.padding ?? EdgeInsets.zero,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < itemsCount) {
              final item = widget.state.data[index];

              return widget.builder(context, index, item);
            }

            if (loadType is PaginationInfiniteLoading) {
              if (index > itemsCount + 20) {
                return null;
              }

              return loadType.loadingItemBuilder(context);
            }

            if (loadType is PaginationAutoLoadMore) {
              return loadType.loadingMoreBuilder(context);
            }

            if (loadType is PaginationManualLoading) {
              return loadType.loadButtonBuilder?.call(
                    context,
                    widget.state.status is PaginationLoadingMore,
                  ) ??
                  SizedBox();
            }

            return SizedBox();
          },
          childCount: count,
        ),
      ),
    );
  }

  Widget buildItemsSliverGrid(BuildContext context) {
    final itemsCount = widget.state.data.length;
    final loadType = widget.loadType;
    int? count;
    if (loadType is PaginationInfiniteLoading) {
      count = null;
    } else {
      count = itemsCount + 1;
    }

    return SliverPadding(
      padding: widget.padding ?? EdgeInsets.zero,
      sliver: SliverGrid(
        gridDelegate: (widget.viewType as PaginationGridView).gridDelegate,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < itemsCount) {
              final item = widget.state.data[index];

              return widget.builder(context, index, item);
            }

            if (loadType is PaginationInfiniteLoading) {
              if (index > itemsCount + 20) {
                return null;
              }

              return loadType.loadingItemBuilder(context);
            }

            if (loadType is PaginationAutoLoadMore) {
              return loadType.loadingMoreBuilder(context);
            }

            if (loadType is PaginationManualLoading) {
              return loadType.loadButtonBuilder?.call(
                    context,
                    widget.state.status is PaginationLoadingMore,
                  ) ??
                  SizedBox();
            }

            return SizedBox();
          },
          childCount: count,
        ),
      ),
    );
  }

  Widget loadingBuilder(BuildContext context) {
    final child = widget.initialLoadingBuilder?.call(context);
    if (child != null) return child;

    return sliverHandler(const SizedBox());
  }

  Widget errorBuilder(BuildContext context) {
    final error = (widget.state.status as PaginationLoadFailure).error;
    final child = widget.errorBuilder?.call(context, error);
    if (child != null) return child;

    return sliverHandler(const SizedBox());
  }

  Widget emptyListBuilder(BuildContext context) {
    final child = widget.emptyListBuilder?.call(context);
    if (child != null) return child;

    return sliverHandler(const SizedBox());
  }

  Widget sliverHandler(Widget child) {
    if (widget.sliver) return SliverToBoxAdapter(child: child);
    return child;
  }
}
