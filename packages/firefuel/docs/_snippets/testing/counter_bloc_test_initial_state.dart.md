```dart
group('CounterFirefuel', () {
    CounterFirefuel counterFirefuel;

    setUp(() {
        counterFirefuel = CounterFirefuel();
    });

    test('initial state is 0', () {
        expect(counterFirefuel.state, 0);
    });
});
```
