```dart
MultiFirefuelProvider(
  providers: [
    FirefuelProvider<FirefuelA>(
      create: (BuildContext context) => FirefuelA(),
    ),
    FirefuelProvider<FirefuelB>(
      create: (BuildContext context) => FirefuelB(),
    ),
    FirefuelProvider<FirefuelC>(
      create: (BuildContext context) => FirefuelC(),
    ),
  ],
  child: ChildA(),
)
```
