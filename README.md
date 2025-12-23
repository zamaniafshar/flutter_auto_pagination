Here’s a complete [README.md](cci:7://file:///Users/mac/StudioProjects/flutter_auto_pagination/README.md:0:0-0:0) you can copy‑paste into your file.  
You can later replace the image/GIF paths in `docs/images/...` and `docs/gifs/...`.

```markdown
# flutter_auto_pagination

<!-- TODO: Update badge links -->
[![Pub Version](https://img.shields.io/pub/v/flutter_auto_pagination.svg)](https://pub.dev/packages/flutter_auto_pagination)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

<!-- TODO: Replace with your real screenshot -->
![Package Banner](docs/images/banner.png)

A lightweight, declarative pagination helper for Flutter that keeps your
pagination logic clean and your UI simple.

`flutter_auto_pagination` gives you:

- **[AutoPagination](cci:2://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination.dart:48:0-89:1) widget** for list/grid pagination (sliver or normal views).
- **[AutoPaginationMixin](cci:2://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination_mixin.dart:5:0-74:1)** to encapsulate page loading logic and state.
- Support for **auto load-more on scroll** or **manual “Load more” button**.
- Clear loading, empty, error and load-more states.

Ideal for feeds, catalogs, search results, and any infinite scrolling list.

<!-- TODO: Replace with real demo GIF -->
![Demo](docs/gifs/demo.gif)

---

## Table of contents

- **[Features](#features)**
- **[Getting started](#getting-started)**
- **[Basic usage](#basic-usage)**
  - [Define pagination state](#define-pagination-state)
  - [Use [AutoPaginationMixin](cci:2://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination_mixin.dart:5:0-74:1) in your controller](#use-autopaginationmixin-in-your-controller)
  - [Wire [AutoPagination](cci:2://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination.dart:48:0-89:1) widget in UI](#wire-autopagination-widget-in-ui)
- **[Load more strategies](#load-more-strategies)**
- **[Customization](#customization)**
- **[Examples](#examples)**
- **[FAQ](#faq)**
- **[License](#license)**

---

## Features

- **List or grid pagination** using [PaginationListView](cci:2://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination.dart:16:0-18:1) or [PaginationGridView](cci:2://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination.dart:20:0-24:1).
- **Auto load-more** when the user approaches the bottom of the list.
- **Manual load-more** via a custom button.
- **Sliver support** for use inside `CustomScrollView` / `NestedScrollView`.
- **Configurable builders** for:
  - Initial loading
  - Error state
  - Empty list state
  - Load-more indicator or button
- **Strongly-typed data model** via [PaginationData<T>](cci:2://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/pagination_data.dart:0:0-8:1) and `PaginationState<T>`.

---

## Getting started

Add the dependency in your [pubspec.yaml](cci:7://file:///Users/mac/StudioProjects/flutter_auto_pagination/pubspec.yaml:0:0-0:0):

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_auto_pagination: ^0.0.1 # or latest
```

Import the package:

```dart
import 'package:flutter_auto_pagination/flutter_auto_pagination.dart';
```

---

## Basic usage

This package has two main building blocks:

- **[AutoPagination](cci:2://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination.dart:48:0-89:1) widget** – renders a list/grid with pagination UI.
- **[AutoPaginationMixin<T>](cci:2://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination_mixin.dart:5:0-74:1)** – encapsulates how data pages are fetched.

### Define pagination state

You will typically have a `PaginationState<T>` stored in your state management
solution (e.g. `StatefulWidget`, `ChangeNotifier`, `Bloc`, `Riverpod`, etc.).

```dart
PaginationState<MyItem> _paginationState = PaginationState.initial();
```

> Note: `PaginationState` is part of the package (see `src/pagination_state.dart`).

### Use [AutoPaginationMixin](cci:2://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination_mixin.dart:5:0-74:1) in your controller

Create a controller / view model that mixes in [AutoPaginationMixin<T>](cci:2://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination_mixin.dart:5:0-74:1) and
connects it to your state.

```dart
class MyItemsController with AutoPaginationMixin<MyItem> {
  MyItemsController(this._setState, this._state);

  PaginationState<MyItem> _state;
  final void Function(PaginationState<MyItem>) _setState;

  @override
  PaginationState<MyItem> get paginationState => _state;

  @override
  void setPaginationState(PaginationState<MyItem> newState) {
    _state = newState;
    _setState(newState);
  }

  @override
  Future<PaginationData<MyItem>> fetchPageData(int page) async {
    // TODO: replace with your API / repository call
    final response = await repository.fetchItems(page: page);
    return PaginationData<MyItem>(
      data: response.items,
      hasReachedEnd: response.isLastPage,
    );
  }
}
```

Then, from your UI, call:

```dart
await controller.load();    // initial load
await controller.refresh(); // pull-to-refresh style reload
await controller.loadMore();
```

### Wire [AutoPagination](cci:2://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination.dart:48:0-89:1) widget in UI

Use the [AutoPagination](cci:2://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination.dart:48:0-89:1) widget to render your list or grid.

```dart
class MyItemsPage extends StatefulWidget {
  const MyItemsPage({super.key});

  @override
  State<MyItemsPage> createState() => _MyItemsPageState();
}

class _MyItemsPageState extends State<MyItemsPage> {
  late PaginationState<MyItem> _state;
  late MyItemsController _controller;

  @override
  void initState() {
    super.initState();
    _state = PaginationState<MyItem>.initial();
    _controller = MyItemsController((s) => setState(() => _state = s), _state);
    _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My items')),
      body: AutoPagination<MyItem>(
        state: _state,
        builder: (context, index, item) {
          return ListTile(title: Text(item.title));
        },
        viewType: const PaginationListView(),
        loadMoreType: PaginationAutoLoadMore(
          paginationScrollThreshold: 250,
          loadMore: _controller.loadMore,
          loadingMoreBuilder: (context) => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          loadItemsCount: 1,
        ),
        initialLoadingBuilder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
        emptyListBuilder: (context) => const Center(
          child: Text('No items found'),
        ),
        errorBuilder: (context, error) => Center(
          child: Text('Something went wrong: $error'),
        ),
      ),
    );
  }
}
```

<!-- TODO: Replace with real screenshot -->
![List Example](docs/images/list_example.png)

---

## Load more strategies

[AutoPagination](cci:2://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination.dart:48:0-89:1) supports two load-more strategies via [PaginationLoadMoreType](cci:2://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination.dart:26:0-26:38):

### 1. Auto load-more ([PaginationAutoLoadMore](cci:2://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination.dart:34:0-46:1))

Triggers [loadMore](cci:1://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination_mixin.dart:43:2-73:3) automatically when the user scrolls close to the bottom.

```dart
loadMoreType: PaginationAutoLoadMore(
  loadMore: _controller.loadMore,
  loadingMoreBuilder: (context) => const Center(
    child: CircularProgressIndicator(),
  ),
  paginationScrollThreshold: 250, // px before bottom
  loadItemsCount: 1, // how many loading widgets are appended
),
```

### 2. Manual load-more ([PaginationManualLoadMore](cci:2://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination.dart:28:0-32:1))

Shows a button at the bottom which calls your [loadMore](cci:1://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination_mixin.dart:43:2-73:3) method.

```dart
loadMoreType: PaginationManualLoadMore(
  loadButtonBuilder: (context, isLoading) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _controller.loadMore,
        child: const Text('Load more'),
      ),
    );
  },
),
```

---

## Customization

- **View type**

  ```dart
  viewType: const PaginationListView(),
  // or
  viewType: PaginationGridView(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.75,
    ),
  ),
  ```

- **Sliver vs non-sliver**

  ```dart
  sliver: true, // when used inside an existing CustomScrollView
  ```

- **Padding & cache extent**

  ```dart
  padding: const EdgeInsets.all(8),
  cacheExtent: 500,
  ```

- **Custom builders**

  ```dart
  initialLoadingBuilder: (context) => const Center(
    child: CircularProgressIndicator(),
  ),

  emptyListBuilder: (context) => const Center(
    child: Text('Nothing here yet'),
  ),

  errorBuilder: (context, error) => Center(
    child: Text('Error: $error'),
  ),
  ```

<!-- TODO: Replace with customization screenshot -->
![Grid Example](docs/images/grid_example.png)

---

## Examples

Check the `example/` folder for a complete, runnable app that demonstrates:

- **Basic list pagination**
- **Grid pagination**
- **Auto vs manual load-more**
- Handling **empty**, **error**, and **load-more error** states

You can run it with:

```bash
cd example
flutter run
```

<!-- TODO: Replace with real example GIF -->
![Example App](docs/gifs/example_app.gif)

---

## FAQ

### Why use this instead of writing pagination by hand?

- Reduces boilerplate around paging state and list rendering.
- Encourages a clear separation between **state**, **fetch logic**, and **UI**.
- Handles edge cases (load-more errors, end of list, etc.) in a consistent way.

### Does it support my state management solution?

Yes. The package is agnostic. As long as you can hold a `PaginationState<T>`
and call [setPaginationState](cci:1://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination_mixin.dart:10:2-10:54), you can integrate it with your preferred
architecture (Bloc, Riverpod, Provider, Redux, etc.).

### Does it work with Slivers / CustomScrollView?

Yes. Set `sliver: true` and place [AutoPagination](cci:2://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination.dart:48:0-89:1) inside your scroll view.
Remember that when `sliver` is `true` and `loadMoreType` is
[PaginationAutoLoadMore](cci:2://file:///Users/mac/StudioProjects/flutter_auto_pagination/lib/src/auto_pagination.dart:34:0-46:1), you **must** provide a `scrollController`.

---

## License

This project is licensed under the MIT License – see the [LICENSE](LICENSE)
file for details.
```

### Summary

- You can paste this into [README.md](cci:7://file:///Users/mac/StudioProjects/flutter_auto_pagination/README.md:0:0-0:0) in your repo.
- Later, replace `docs/images/*.png` and `docs/gifs/*.gif` with actual assets and paths.
- If you want, I can also help you trim this down or add sections like “Contributing” or “Roadmap”.