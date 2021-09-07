```dart
firefuelTest(
    '...',
    build: () => MyFirefuel(),
    act: (firefuel) => firefuel.add(MyEvent()),
    expect: [
        MyStateA(),
        MyStateB(),
    ],
)
```
