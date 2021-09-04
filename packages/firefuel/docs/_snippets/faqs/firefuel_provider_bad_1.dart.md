```dart
@override
Widget build(BuildContext context) {
  FirefuelProvider(
    create: (_) => FirefuelA(),
    child: ElevatedButton(
      onPressed: () {
        final firefuelA = FirefuelProvider.of<FirefuelA>(context);
        ...
      }
    )
  );
}
```
