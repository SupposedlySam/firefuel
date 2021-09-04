```dart
void main() {
  Firefuel.observer = SimpleFirefuelObserver();
  CounterFirefuel firefuel = CounterFirefuel();

  for (int i = 0; i < 3; i++) {
    firefuel.add(CounterEvent.increment);
  }
}
```