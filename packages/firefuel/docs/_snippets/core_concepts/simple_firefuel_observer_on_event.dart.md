```dart
class SimpleFirefuelObserver extends FirefuelObserver {
  @override
  void onEvent(Firefuel firefuel, Object event) {
    print(event);
    super.onEvent(firefuel, event);
  }

  @override
  void onTransition(Firefuel firefuel, Transition transition) {
    print(transition);
    super.onTransition(firefuel, transition);
  }
}
```
