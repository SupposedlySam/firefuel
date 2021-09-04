# Frequently Asked Questions

## State Not Updating

❔ **Question**: I'm yielding a state in my firefuel but the UI is not updating. What am I doing wrong?

💡 **Answer**: If you're using Equatable make sure to pass all properties to the props getter.

✅ **GOOD**

[my_state.dart](_snippets/faqs/state_not_updating_good_1.dart.md ':include')

❌ **BAD**

[my_state.dart](_snippets/faqs/state_not_updating_bad_1.dart.md ':include')

[my_state.dart](_snippets/faqs/state_not_updating_bad_2.dart.md ':include')

In addition, make sure you are yielding a new instance of the state in your firefuel.

✅ **GOOD**

[my_firefuel.dart](_snippets/faqs/state_not_updating_good_2.dart.md ':include')

[my_firefuel.dart](_snippets/faqs/state_not_updating_good_3.dart.md ':include')

❌ **BAD**

[my_firefuel.dart](_snippets/faqs/state_not_updating_bad_3.dart.md ':include')

!> `Equatable` properties should always be copied rather than modified. If an `Equatable` class contains a `List` or `Map` as properties, be sure to use `List.from` or `Map.from` respectively to ensure that equality is evaluated based on the values of the properties rather than the reference.

## When to use Equatable

❔**Question**: When should I use Equatable?

💡**Answer**:

[my_firefuel.dart](_snippets/faqs/equatable_yield.dart.md ':include')

In the above scenario if `StateA` extends `Equatable` only one state change will occur (the second yield will be ignored).
In general, you should use `Equatable` if you want to optimize your code to reduce the number of rebuilds.
You should not use `Equatable` if you want the same state back-to-back to trigger multiple transitions.

In addition, using `Equatable` makes it much easier to test firefuels since we can expect specific instances of firefuel states rather than using `Matchers` or `Predicates`.

[my_firefuel_test.dart](_snippets/faqs/equatable_firefuel_test.dart.md ':include')

Without `Equatable` the above test would fail and would need to be rewritten like:

[my_firefuel_test.dart](_snippets/faqs/without_equatable_firefuel_test.dart.md ':include')

## Handling Errors

❔ **Question**: How can I handle an error while still showing previous data?

💡 **Answer**:

This highly depends on how the state of the firefuel has been modeled. In cases where data should still be retained even in the presence of an error, consider using a single state class.

```dart
enum Status { initial, loading, success, failure }

class MyState {
  const MyState({
    this.data = Data.empty,
    this.error = '',
    this.status = Status.initial,
  });

  final Data data;
  final String error;
  final Status status;

  MyState copyWith({Data data, String error, Status status}) {
    return MyState(
      data: data ?? this.data,
      error: error ?? this.error,
      status: status ?? this.status,
    );
  }
}
```

This will allow widgets to have access to the `data` and `error` properties simultaneously and the firefuel can use `state.copyWith` to retain old data even when an error has occurred.

```dart
if (event is DataRequested) {
  try {
    final data = await _repository.getData();
    yield state.copyWith(status: Status.success, data: data);
  } on Exception {
    yield state.copyWith(status: Status.failure, error: 'Something went wrong!');
  }
}
```

## Firefuel vs. Redux

❔ **Question**: What's the difference between Firefuel and Redux?

💡 **Answer**:

BLoC is a design pattern that is defined by the following rules:

1. Input and Output of the BLoC are simple Streams and Sinks.
2. Dependencies must be injectable and Platform agnostic.
3. No platform branching is allowed.
4. Implementation can be whatever you want as long as you follow the above rules.

The UI guidelines are:

1. Each "complex enough" component has a corresponding BLoC.
2. Components should send inputs "as is".
3. Components should show outputs as close as possible to "as is".
4. All branching should be based on simple BLoC boolean outputs.

The Firefuel Library implements the BLoC Design Pattern and aims to abstract RxDart in order to simplify the developer experience.

The three principles of Redux are:

1. Single source of truth
2. State is read-only
3. Changes are made with pure functions

The firefuel library violates the first principle; with firefuel state is distributed across multiple firefuels.
Furthermore, there is no concept of middleware in firefuel and firefuel is designed to make async state changes very easy, allowing you to emit multiple states for a single event.

## Firefuel vs. Provider

❔ **Question**: What's the difference between Firefuel and Provider?

💡 **Answer**: `provider` is designed for dependency injection (it wraps `InheritedWidget`).
You still need to figure out how to manage your state (via `ChangeNotifier`, `Firefuel`, `Mobx`, etc...).
The Firefuel Library uses `provider` internally to make it easy to provide and access firefuels throughout the widget tree.

## Navigation with Firefuel

❔ **Question**: How do I do navigation with Firefuel?

💡 **Answer**: Check out [Flutter Navigation](recipesflutternavigation.md)

## FirefuelProvider.of() Fails to Find Firefuel

❔ **Question**: When using `FirefuelProvider.of(context)` it cannot find the firefuel. How can I fix this?

💡 **Answer**: You cannot access a firefuel from the same context in which it was provided so you must ensure `FirefuelProvider.of()` is called within a child `BuildContext`.

✅ **GOOD**

[my_page.dart](_snippets/faqs/firefuel_provider_good_1.dart.md ':include')

[my_page.dart](_snippets/faqs/firefuel_provider_good_2.dart.md ':include')

❌ **BAD**

[my_page.dart](_snippets/faqs/firefuel_provider_bad_1.dart.md ':include')

## Project Structure

❔ **Question**: How should I structure my project?

💡 **Answer**: While there is really no right/wrong answer to this question, some recommended references are

- [Flutter Architecture Samples - Brian Egan](https://github.com/brianegan/flutter_architecture_samples/tree/main/firefuel_library)
- [Flutter Shopping Card Example](https://github.com/SupposedlySam/firefuel/tree/main/examples/flutter_shopping_cart)
- [Flutter TDD Course - ResoCoder](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)

The most important thing is having a **consistent** and **intentional** project structure.
