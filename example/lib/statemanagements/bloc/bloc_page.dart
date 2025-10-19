import 'package:example/statemanagements/bloc/articles_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_auto_pagination/flutter_auto_pagination.dart';

import '../../models/article.dart';
import '../../repository/articles_repository.dart';

class BlocExamplePage extends StatelessWidget {
  const BlocExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ArticlesBloc(ArticlesRepository())..add(ArticlesLoadRequested()),
      child: const _BlocExamplePage(),
    );
  }
}

class _BlocExamplePage extends StatelessWidget {
  const _BlocExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bloc + AutoPagination')),
      body: BlocBuilder<ArticlesBloc, PaginationState<Article>>(
        builder: (context, state) {
          return AutoPagination<Article>(
            state: state,
            builder: (context, index, item) => ListTile(
              title: Text(item.title),
              subtitle: Text('ID: ${item.id}'),
            ),
            loadMoreType: PaginationAutoLoadMore(
              loadMore: () =>
                  context.read<ArticlesBloc>().add(ArticlesLoadMoreRequested()),
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
                        context.read<ArticlesBloc>().add(ArticlesRefreshed()),
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
