import 'package:flutter/material.dart';

import 'pagination_controller.dart';

const _paginationScrollThreshold = 250.0;

class PaginationListView<T> extends StatefulWidget {
  const PaginationListView({
    super.key,
    required this.state,
    required this.loadMore,
    required this.builder,
    this.padding,
    this.loadingBuilder,
    this.loadingMoreBuilder,
    this.errorBuilder,
    this.emptyListBuilder,
    this.scrollController,
    this.cacheExtent,
  }) : _sliver = false;

  const PaginationListView.sliver({
    super.key,
    required this.scrollController,
    required this.state,
    required this.loadMore,
    required this.builder,
    this.padding,
    this.loadingBuilder,
    this.loadingMoreBuilder,
    this.errorBuilder,
    this.emptyListBuilder,
  }) : _sliver = true,
       cacheExtent = null;

  final Widget Function(int index, T item) builder;
  final void Function() loadMore;
  final PaginationState<T> state;
  final Widget Function()? loadingBuilder;
  final Widget Function()? loadingMoreBuilder;
  final Widget Function(Object? e)? errorBuilder;
  final Widget Function()? emptyListBuilder;
  final EdgeInsets? padding;
  final bool _sliver;
  final ScrollController? scrollController;
  final double? cacheExtent;

  @override
  State<PaginationListView<T>> createState() => _PaginationListViewState<T>();
}

class _PaginationListViewState<T> extends State<PaginationListView<T>> {
  late final scrollController = widget.scrollController ?? ScrollController();

  @override
  void initState() {
    scrollController.addListener(_scrollListener);
    super.initState();
  }

  void _scrollListener() {
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    final isAtTheEnd = maxScroll - currentScroll <= _paginationScrollThreshold;

    if (isAtTheEnd) {
      widget.loadMore();
    }
  }

  @override
  void dispose() {
    final isLocalController = widget.scrollController == null;
    if (isLocalController) {
      scrollController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.state.status;

    if (status is PaginationLoading) return loadingBuilder();
    if (status is PaginationLoadFailure) {
      return errorBuilder(status.e);
    }

    final isEmpty = widget.state.data.isEmpty;
    if (isEmpty) return emptyListBuilder();

    final itemsCount = widget.state.data.length;

    final sliver = SliverPadding(
      padding: widget.padding ?? EdgeInsets.zero,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < itemsCount) {
              final item = widget.state.data[index];

              return widget.builder(index, item);
            }

            return widget.state.status is PaginationLoadingMore
                ? loadingMoreBuilder()
                : const SizedBox();
          },
          childCount: itemsCount + 1,
        ),
      ),
    );

    if (widget._sliver) return sliver;

    return CustomScrollView(
      controller: scrollController,
      cacheExtent: widget.cacheExtent,
      slivers: [
        sliver,
      ],
    );
  }

  Widget loadingBuilder() {
    final child = widget.loadingBuilder?.call();
    return sliverHandler(child ?? const SizedBox());
  }

  Widget loadingMoreBuilder() {
    final child = widget.loadingMoreBuilder?.call();
    return sliverHandler(child ?? const SizedBox());
  }

  Widget errorBuilder(Object? e) {
    final child = widget.errorBuilder?.call(e);
    return sliverHandler(child ?? const SizedBox());
  }

  Widget emptyListBuilder() {
    final child = widget.emptyListBuilder?.call();
    return sliverHandler(child ?? const SizedBox());
  }

  Widget sliverHandler(Widget child) {
    if (widget._sliver) return SliverToBoxAdapter(child: child);
    return child;
  }
}
