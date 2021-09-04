```dart
firefuelTest(
    '...',
    build: () => MyFirefuel(),
    act: (firefuel) => firefuel.add(MyEvent()),
    expect: [
        isA<MyStateA>(),
        isA<MyStateB>(),
    ],
)
```
