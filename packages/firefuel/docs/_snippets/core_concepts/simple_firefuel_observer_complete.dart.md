```dart
class SimpleFirefuelObserver extends FirefuelObserver {
  @override
  void onEvent(Firefuel firefuel, Object? event) {
    super.onEvent(firefuel, event);
    print(event);
  }

  @override
  void onTransition(Firefuel firefuel, Transition transition) {
    super.onTransition(firefuel, transition);
    print(transition);
  }

  @override
  void onError(FirefuelBase firefuel, Object error, StackTrace stackTrace) {
    print('$error, $stackTrace');
    super.onError(firefuel, error, stackTrace);    
  }
}
```
