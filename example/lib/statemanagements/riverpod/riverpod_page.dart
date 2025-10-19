import 'package:example/statemanagements/provider/articles_provider.dart';
import 'package:example/statemanagements/riverpod/articles_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auto_pagination/flutter_auto_pagination.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/article.dart';
import '../../repository/articles_repository.dart';

class RiverpodExamplePage extends StatelessWidget {
  const RiverpodExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod + AutoPagination')),
      body: Consumer(
        builder: (context, ref, _) {
          return AutoPagination<Article>(
            state: ref.watch(articlesNotifierProvider),
            builder: (context, index, item) => ListTile(
              title: Text(item.title),
              subtitle: Text('ID: ${item.id}'),
            ),
            loadMoreType: PaginationAutoLoadMore(
              loadMore: () =>
                  ref.read(articlesNotifierProvider.notifier).loadMore(),
              loadingMoreBuilder: (context) => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            emptyListBuilder: (context) =>
                const Center(child: Text('No items')),
            errorBuilder: (context, e) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: $e'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(articlesNotifierProvider.notifier).refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
