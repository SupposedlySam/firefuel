```dart
class SimpleFirefuelObserver extends FirefuelObserver {
  @override
  void onTransition(Firefuel firefuel, Transition transition) {
    print(transition);
    super.onTransition(firefuel, transition);
  }
}
```
