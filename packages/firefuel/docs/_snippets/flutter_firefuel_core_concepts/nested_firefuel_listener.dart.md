```dart
FirefuelListener<FirefuelA, FirefuelAState>(
  listener: (context, state) {},
  child: FirefuelListener<FirefuelB, FirefuelBState>(
    listener: (context, state) {},
    child: FirefuelListener<FirefuelC, FirefuelCState>(
      listener: (context, state) {},
      child: ChildA(),
    ),
  ),
)
```
