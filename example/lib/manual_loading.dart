import 'package:example/models/article.dart';
import 'package:example/repository/articles_repository.dart';
import 'package:example/simple_example.dart';
import 'package:example/simple_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auto_pagination/flutter_auto_pagination.dart';

class ManualLoadMoreExample extends StatefulWidget {
  const ManualLoadMoreExample({super.key});

  @override
  State<ManualLoadMoreExample> createState() => _ManualLoadMoreExampleState();
}

class _ManualLoadMoreExampleState extends State<ManualLoadMoreExample> {
  SimpleNotifier notifier = SimpleNotifier(ArticlesRepository());

  @override
  void initState() {
    notifier.load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Loading Example'),
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: ListenableBuilder(
          listenable: notifier,
          builder: (context, _) {
            return AutoPagination<Article>(
              state: notifier.paginationState,
              builder: (context, index, item) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    title: Text(item.title),
                    subtitle: Text('ID: ${item.id}'),
                  ),
                ),
              ),

              loadMoreType: PaginationManualLoadMore(
                loadButtonBuilder: (context, isLoading) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        notifier.loadMore();
                      },
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(),
                            )
                          : Text('Load More'),
                    ),
                  );
                },
              ),
              initialLoadingBuilder: (context) =>
                  const Center(child: CircularProgressIndicator()),
              emptyListBuilder: (context) =>
                  const Center(child: Text('No items')),
              errorBuilder: (context, e) => Center(
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
            );
          },
        ),
      ),
    );
  }
}
