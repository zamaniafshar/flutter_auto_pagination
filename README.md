# flutter_auto_pagination

<!-- TODO: Update badge links -->
[![Pub Version](https://img.shields.io/pub/v/flutter_auto_pagination.svg)](https://pub.dev/packages/flutter_auto_pagination)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

<!-- TODO: Replace with your real screenshot -->
![Package Banner](https://github.com/zamaniafshar/flutter_auto_pagination/blob/0bb820b592f7dbb5d57c8d9149802bb45950d372/resources/banner.png)




<p align="center">
  <img src="https://github.com/zamaniafshar/flutter_auto_pagination/blob/0bb820b592f7dbb5d57c8d9149802bb45950d372/resources/simple_ex.gif" width="30%" />
  <img src="https://github.com/zamaniafshar/flutter_auto_pagination/blob/0bb820b592f7dbb5d57c8d9149802bb45950d372/resources/manual_ex.gif" width="30%" />
  <img src="https://github.com/zamaniafshar/flutter_auto_pagination/blob/0bb820b592f7dbb5d57c8d9149802bb45950d372/resources/complex_ex.gif" width="30%" />
</p>


A lightweight, declarative pagination helper for Flutter that keeps your
pagination logic clean and your UI simple.


`flutter_auto_pagination` gives you:

- **AutoPagination widget** for list/grid pagination (sliver or normal views).
- **AutoPaginationMixin** to seperate logic and state from ui.
- Support for **auto load-more on scroll** or **manual “Load more” button**.
- Clear loading, empty, error and load-more states.
- Very Customaizable
- Works with any State Managements solution (Bloc, Riverpod, Provider, Redux, etc.)
- - **Configurable builders** for diffrent states.

Ideal for feeds, catalogs, search results, and any infinite scrolling list.

<!-- TODO: Replace with real demo GIF -->
![Demo](docs/gifs/demo.gif)

## Basic usage

This package has three main building blocks:

- **AutoPagination widget** – renders a list/grid with pagination UI.
- **AutoPaginationMixin<T>** – encapsulates how data pages are fetched.
- **AutoPaginationState<T>** 

### Define pagination state

Define a `PaginationState<T>` stored in your state management
solution (e.g. `StatefulWidget`, `ChangeNotifier`, `Bloc`, `Riverpod`, etc.).

```dart
PaginationState<MyItem> _paginationState = PaginationState.initial();
```

> Note: `PaginationState` is part of the package (see `src/pagination_state.dart`).

### Use AutoPaginationMixin in your notifier / statemanagement

Create a notifer / view model that mixes in AutoPaginationMixin<T> and
connects it to your state.

```dart

class SimpleNotifier extends ChangeNotifier with AutoPaginationMixin<Article> {
  SimpleNotifier(this._repository);

  final ArticlesRepository _repository;

  PaginationState<Article> _state = PaginationState.initial();

  @override
  Future<PaginationData<Article>> fetchPageData(int page) {
    // Your api call
    return _repository.fetch(page);
  }

  // A getter for getting state from your statemanagement
  @override
  PaginationState<Article> get paginationState => _state;

  // Notify you when state should change
  @override
  void onPaginationStateChanged(PaginationState<Article> newState) {
    _state = newState;
    notifyListeners();
  }
}
```

Then, from your UI, call:

```dart
await notifer.load();    // initial load
await notifer.refresh(); // pull-to-refresh style reload
await notifer.loadMore();
```

> Note: AutoPaginationMixin does not hold state, it’s just a few helper methods and when state should change it just notifies you.
It’s your statemanagements that hold state and updates ui. That’s why this package is customizable.


### Wire AutoPagination widget in UI

Use the AutoPagination widget to render your list or grid.

```dart

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
                      onPressed: () => notifier.load(),
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
```


---

## Load more strategies

AutoPagination supports two load-more strategies via PaginationLoadMoreType:

### 1. Auto load-more

Triggers loadMore automatically when the user scrolls close to the bottom.

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

### 2. Manual load-more PaginationManualLoadMore

Shows a button at the bottom which calls your loadMore method.

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

---

## Examples

This package ships with several runnable examples:

- **Simple list** – basic infinite list using `ChangeNotifier` + `AutoPaginationMixin`.
- **Manual \"Load more\" button** – demonstrates `PaginationManualLoadMore`.
- **Complex search + local state** – uses `ValueNotifier`, debounced search, and per-item like/unlike.

Check the `example/` folder. To run them all:

```bash
cd example
flutter run
```


---

## FAQ

### Why use this instead of writing pagination by hand?

- Reduces boilerplate around paging state and list rendering.
- Encourages a clear separation between **state**, **fetch logic**, and **UI**.
- Handles edge cases (load-more errors, end of list, etc.) in a consistent way.

### Does it support my state management solution?

Yes. The package is agnostic. As long as you can hold a `PaginationState<T>`
and call you can integrate it with your preferred
architecture (Bloc, Riverpod, Provider, Redux, etc.).
See examples/statemanagements folder.

### Does it work with Slivers / CustomScrollView?

Yes. Set `sliver: true` and place AutoPagination inside your scroll view.
Remember that when `sliver` is `true` and `loadMoreType` is
PaginationAutoLoadMore, you **must** provide a `scrollController`.

### Should AutoPaginationMixin manage its own state?

No. By design, `AutoPaginationMixin` is stateless.

It only:

- exposes the `load`, `refresh`, and `loadMore` methods
- calls `onPaginationStateChanged` with a new `PaginationState<T>`

You are responsible for holding `PaginationState<T>` inside your own
state-management solution (`ChangeNotifier`, `Bloc`, `Riverpod`, etc.). This
keeps the package:

- flexible – you can combine pagination with other pieces of state (filters,
  tabs, form values, etc.)
- testable – you fully control how state is stored and compared
- easy to integrate – no opinionated base classes are forced on your app

If you prefer an alternative where the mixin owns its state internally, please
open an issue – we can explore an opt-in helper or a separate mixin.

## Why flutter_auto_pagination?

If you have used other pagination packages like `infinite_scroll_pagination`, you might have noticed they are powerful but often **complex** and **opinionated**. They force you to use their own `Controllers`, which often leads to "State Duplication" (where your data lives in both your Bloc/Provider and the package's Controller).

`flutter_auto_pagination` was built to be **declarative, lightweight, and architecture-friendly.**

### Comparison at a Glance

| Feature | `infinite_scroll_pagination` | `flutter_auto_pagination` |
| :--- | :--- | :--- |
| **State Ownership** | **Opinionated:** Uses `PagingController`. Data is duplicated. | **Agnostic:** Uses a Mixin. Data stays in your State Management. |
| **Setup Complexity** | **High:** Requires manual controller management & listeners. | **Low:** Just add a Mixin to your notifier and you're done. |
| **Manual Load Button** | **Hard:** Requires custom "hacks" using error/empty builders. | **Native:** Built-in `PaginationManualLoadMore` support. |
| **Single Source of Truth** | ❌ Hard to maintain with Bloc/Riverpod. | ✅ Perfect. Your state is the only source of truth. |
| **Boilerplate** | High (Verbose) | Low (Clean & Declarative) |
| **UI Flexibility** | Good, but complex to switch ViewTypes. | High (Switch between List/Grid/Slivers easily). |

---

### Key Advantages

#### 1. No "State Hijacking"
Most libraries "own" your list of items. With our `AutoPaginationMixin`, you keep your items in your own `List<T>`. This makes operations like **deleting an item**, **updating a specific row**, or **local filtering** as easy as working with a standard Flutter list. No need to sync two different states.

#### 2. Native Manual Load More
Sometimes infinite scroll isn't the best UX. Switching from an automatic "load-on-scroll" to a manual "Load More" button is just a matter of changing the `loadMoreType` parameter. No extra logic required.

#### 3. True Clean Architecture
Because it doesn't force a base class or a specific controller on you, it fits perfectly into any architecture. Whether you use **Cubit, Bloc, Riverpod, or simple ChangeNotifiers**, this package acts as a helper, not a manager.


---

## Contributing

Contributions, bug reports, and feature requests are very welcome.❤️

You help with:

- Writing tests.
- Add documentation.
- Add more examples.
- Test it on complex scenarios and edge cases.


Please open a GitHub issue to discuss about design or feature requests.

---

## License

This project is licensed under the MIT License – see the [LICENSE](LICENSE)
file for details.
