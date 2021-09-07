```dart
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: FirefuelProvider<CounterFirefuel>(
        create: (context) => CounterFirefuel(),
        child: CounterPage(),
      ),
    );
  }
}
```
