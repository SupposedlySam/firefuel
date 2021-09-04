```dart
firefuelTest(
    'emits [1] when CounterEvent.increment is added',
    build: () => counterFirefuel,
    act: (firefuel) => firefuel.add(CounterEvent.increment),
    expect: () => [1],
);

firefuelTest(
    'emits [-1] when CounterEvent.decrement is added',
    build: () => counterFirefuel,
    act: (firefuel) => firefuel.add(CounterEvent.decrement),
    expect: () => [-1],
);
```
