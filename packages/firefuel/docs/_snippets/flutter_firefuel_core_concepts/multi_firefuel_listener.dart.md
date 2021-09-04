```dart
MultiFirefuelListener(
  listeners: [
    FirefuelListener<FirefuelA, FirefuelAState>(
      listener: (context, state) {},
    ),
    FirefuelListener<FirefuelB, FirefuelBState>(
      listener: (context, state) {},
    ),
    FirefuelListener<FirefuelC, FirefuelCState>(
      listener: (context, state) {},
    ),
  ],
  child: ChildA(),
)
```
