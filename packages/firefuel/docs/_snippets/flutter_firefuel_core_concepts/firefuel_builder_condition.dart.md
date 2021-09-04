```dart
FirefuelBuilder<FirefuelA, FirefuelAState>(
  buildWhen: (previousState, state) {
    // return true/false to determine whether or not
    // to rebuild the widget with state
  },
  builder: (context, state) {
    // return widget here based on FirefuelA's state
  }
)
```
