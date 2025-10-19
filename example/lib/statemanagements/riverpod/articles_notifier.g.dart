// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'articles_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$articlesRepositoryHash() =>
    r'0d2e72ce0fdbff9efd5e41deddf91c1b7b3e9ced';

/// See also [articlesRepository].
@ProviderFor(articlesRepository)
final articlesRepositoryProvider =
    AutoDisposeProvider<ArticlesRepository>.internal(
      articlesRepository,
      name: r'articlesRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$articlesRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ArticlesRepositoryRef = AutoDisposeProviderRef<ArticlesRepository>;
String _$articlesNotifierHash() => r'00a3e83825c47a4562513e768541bcfe93a51267';

/// See also [ArticlesNotifier].
@ProviderFor(ArticlesNotifier)
final articlesNotifierProvider =
    AutoDisposeNotifierProvider<
      ArticlesNotifier,
      PaginationState<Article>
    >.internal(
      ArticlesNotifier.new,
      name: r'articlesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$articlesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ArticlesNotifier = AutoDisposeNotifier<PaginationState<Article>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
