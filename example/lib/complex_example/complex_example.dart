import 'package:example/complex_example/complex_notifier.dart';
import 'package:example/models/article.dart';
import 'package:example/repository/articles_repository.dart';
import 'package:example/simple_example/simple_example.dart';
import 'package:example/simple_example/simple_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auto_pagination/flutter_auto_pagination.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ComplexExample extends StatefulWidget {
  const ComplexExample({super.key});

  @override
  State<ComplexExample> createState() => _ComplexExampleState();
}

class _ComplexExampleState extends State<ComplexExample> {
  ComplexNotifier notifier = ComplexNotifier(ArticlesRepository());
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    notifier.load();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Example'),
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: ListenableBuilder(
          listenable: notifier,
          builder: (context, _) {
            return CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged: (value) => notifier.search(value),
                      onSubmitted: (value) => notifier.search(value),
                      decoration: InputDecoration(
                        filled: true,
                        labelText: 'Search ...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ),
                ),
                AutoPagination<Article>(
                  sliver: true,
                  scrollController: scrollController,
                  state: notifier.value.paginationState,
                  builder: (context, index, item) => ArticleWidget(
                    article: item,
                    onToggleLike: () => notifier.toggleLike(item.id),
                  ),
                  loadMoreType: PaginationAutoLoadMore(
                    loadMore: () => notifier.loadMore(),
                    loadItemsCount: 10,
                    loadingMoreBuilder: (context) => Skeletonizer(
                      enabled: true,
                      child: Skeleton.leaf(
                        child: ArticleWidget(
                          article: null,
                          onToggleLike: () {},
                        ),
                      ),
                    ),
                  ),
                  initialLoadingBuilder: (context) => SliverToBoxAdapter(
                    child: _InitialSkeletonLoading(),
                  ),
                  emptyListBuilder: (context) => SliverFillRemaining(
                    child: const Center(child: Text('No items')),
                  ),
                  errorBuilder: (context, e) => SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Error: $e'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => notifier.refresh(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ArticleWidget extends StatelessWidget {
  const ArticleWidget({
    super.key,
    required this.article,
    required this.onToggleLike,
  });

  final Article? article;
  final VoidCallback onToggleLike;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: ListTile(
          title: Text(article?.title ?? ""),
          subtitle: Text('ID: ${article?.id}'),
          trailing: IconButton(
            icon: Icon(
              (article?.isLiked ?? false)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () => onToggleLike(),
          ),
        ),
      ),
    );
  }
}

class _InitialSkeletonLoading extends StatelessWidget {
  const _InitialSkeletonLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: [
          ...List.generate(
            8,
            (i) => Skeleton.leaf(
              child: ArticleWidget(
                article: null,
                onToggleLike: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
