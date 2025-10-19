import 'package:example/models/article.dart';
import 'package:example/repository/articles_repository.dart';
import 'package:example/simple_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auto_pagination/flutter_auto_pagination.dart';

class SimpleExample extends StatefulWidget {
  const SimpleExample({super.key});

  @override
  State<SimpleExample> createState() => _SimpleExampleState();
}

class _SimpleExampleState extends State<SimpleExample> {
  SimpleNotifier notifier = SimpleNotifier(ArticlesRepository());

  @override
  void initState() {
    notifier.load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Example')),
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

              loadMoreType: PaginationAutoLoadMore(
                loadMore: () => notifier.loadMore(),
                loadingMoreBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
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
