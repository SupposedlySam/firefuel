```dart
@override
Widget build(BuildContext context) {
  FirefuelProvider(
    create: (_) => FirefuelA(),
    child: MyChild();
  );
}

class MyChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        final firefuelA = FirefuelProvider.of<FirefuelA>(context);
        ...
      },
    )
    ...
  }
}
```
