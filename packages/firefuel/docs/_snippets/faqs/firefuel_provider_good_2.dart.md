```dart
@override
Widget build(BuildContext context) {
  FirefuelProvider(
    create: (_) => FirefuelA(),
    child: Builder(
      builder: (context) => ElevatedButton(
        onPressed: () {
          final firefuelA = FirefuelProvider.of<FirefuelA>(context);
          ...
        },
      ),
    ),
  );
}
```
