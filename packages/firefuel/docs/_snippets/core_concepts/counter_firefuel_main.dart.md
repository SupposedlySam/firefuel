```dart
void main() {
    CounterFirefuel firefuel = CounterFirefuel();

    for (int i = 0; i < 3; i++) {
        firefuel.add(CounterEvent.increment);
    }
}
```