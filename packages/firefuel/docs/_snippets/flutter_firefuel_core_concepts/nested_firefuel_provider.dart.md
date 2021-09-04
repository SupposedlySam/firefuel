```dart
FirefuelProvider<FirefuelA>(
  create: (BuildContext context) => FirefuelA(),
  child: FirefuelProvider<FirefuelB>(
    create: (BuildContext context) => FirefuelB(),
    child: FirefuelProvider<FirefuelC>(
      create: (BuildContext context) => FirefuelC(),
      child: ChildA(),
    )
  )
)
```
