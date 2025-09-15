import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_auto_pagination/flutter_auto_pagination.dart';

import '../../models/article.dart';
import '../../repository/articles_repository.dart';
import 'articles_provider.dart';

class ProviderExamplePage extends StatefulWidget {
  const ProviderExamplePage({super.key});

  @override
  State<ProviderExamplePage> createState() => _ProviderExamplePageState();
}

class _ProviderExamplePageState extends State<ProviderExamplePage> {
  late final ArticlesProvider controller;

  @override
  void initState() {
    super.initState();
    controller = context.read<ArticlesProvider>();
    // kick off initial load
    // ignore: discarded_futures
    controller.load();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ArticlesProvider>().paginationState;

    return Scaffold(
      appBar: AppBar(title: const Text('Provider + AutoPagination')),
      body: AutoPagination<Article>(
        state: state,
        builder: (context, index, item) =>
            ListTile(title: Text(item.title), subtitle: Text('ID: ${item.id}')),
        loadType: PaginationAutoLoadMore(
          loadMore: () => controller.loadMore(),
          loadingMoreBuilder: (context) => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
        emptyListBuilder: (context) => const Center(child: Text('No items')),
        errorBuilder: (context, e) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $e'),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: () => controller.refresh(), child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }
}

class ProviderExampleApp extends StatelessWidget {
  const ProviderExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ArticlesProvider(ArticlesRepository()),
      child: const ProviderExamplePage(),
    );
  }
}
